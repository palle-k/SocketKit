//
//  ServerSocket.swift
//  SocketKit
//
//  Created by Palle Klewitz on 11.04.16.
//  Copyright © 2016 Palle Klewitz.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished
//  to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


import CoreFoundation
import Darwin
import Foundation


/**

Delegate for a server socket.

The delegate of a server socket will receive notifications
about new connections or errors.

*/
public protocol ServerSocketDelegate
{
	
	/**

	The delegate is notified that the server accepted a new connection by 
	getting a call to this method.
	
	- parameter serverSocket: The server socket which received the connection.
	
	- paramerer socket: Socket of the new connection.
	
	*/
	func serverSocket(_ serverSocket: ServerSocket, didAcceptConnectionWithSocket socket: Socket)
	
	
	/**

	The delegate is notified about an error which occurred by getting a
	call to this method.
	
	- parameter serverSocket: The server socket which is affected by the error.
	
	- parameter error: The error which was encountered.
	
	*/
	func serverSocket(_ serverSocket: ServerSocket, didFailToAcceptConnectionWithError error: SocketError)
}


/**

A server socket which accepts TCP/IP connections coming to 
the device on the specified port.

A server socket automatically listens for IPv4 and IPv6 connections.

The server socket listens asynchronously in the background and
will notify the delegate about new connections.

*/
public class ServerSocket : CustomStringConvertible
{
	
	/**

	The handle of the IPv4 server socket
	
	*/
	fileprivate let socket_ipv4:Int32
	
	
	/**

	The handle of the IPv6 server socket
	
	*/
	fileprivate let socket_ipv6:Int32
	
	
	/**

	The address of the IPv4 server socket.
	
	The address contains the port on which the server socket listens.
	
	*/
	fileprivate var address_in_ipv4:sockaddr_in
	
	
	/**
	
	The address of the IPv6 server socket.
	
	The address contains the port on which the server socket listens.
	
	*/
	fileprivate var address_in_ipv6:sockaddr_in6
	
	
	/**

	Dispatch source which listens for new connections
	on the IPv4 server socket.
	
	*/
	fileprivate var dispatch_source_ipv4:DispatchSource!
	
	
	/**

	Dispatch source which listens for new connections
	on the IPv6 server socket.
	
	*/
	fileprivate var dispatch_source_ipv6:DispatchSource!
	
	
	/**

	Delegate, which is notified about new connections
	and errors which occurred on this server socket
	
	*/
	open var delegate:ServerSocketDelegate?
	
	
	open var description: String
	{
		return "ServerSocket (listening on port \(self.address_in_ipv4.sin_port))"
	}
	
	
	/**

	Initializes a new server socket which listens on the specified port.
	
	This method may throw a SocketError, if the server socket could not be opened.
	If this happens, make sure that no other service already listens on this port.
	
	A server socket automatically listens for IPv4 and IPv6 connections.

	**If a port below 1024 is used, the process has to be launched with root permissions.**
	
	For HTTP port 80 should be used.
	
	For HTTPS port 443 should be used.
	
	- parameter port: Port on which the server socket should listen.
	
	- throws: A SocketError indicating that the server socket could not be opened
	
	*/
	public init(port: UInt16) throws
	{
		signal(SIGPIPE, SIG_IGN)
		
		socket_ipv4 = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)
		socket_ipv6 = socket(PF_INET6, SOCK_STREAM, IPPROTO_TCP)
		
		guard socket_ipv4 >= 0
			else
		{
			_ = Darwin.close(socket_ipv4)
			throw SocketError.open
		}
		
		guard socket_ipv6 >= 0
			else
		{
			_ = Darwin.close(socket_ipv6)
			throw SocketError.open
		}
		
		var reuse:Int32 = 1
		
		let succes_reuse_ipv4 = setsockopt(socket_ipv4, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int32>.size))
		let succes_reuse_ipv6 = setsockopt(socket_ipv6, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int32>.size))
		
		guard succes_reuse_ipv4 >= 0 && succes_reuse_ipv6 >= 0
			else
		{
			_ = Darwin.close(socket_ipv4)
			_ = Darwin.close(socket_ipv6)
			throw SocketError.reuse
		}
		
		let flags_ipv4 = fcntl(socket_ipv4, F_GETFL, 0)
		let flags_ipv6 = fcntl(socket_ipv6, F_GETFL, 0)
		
		guard flags_ipv4 >= 0 && flags_ipv6 >= 0
		else
		{
			_ = Darwin.close(socket_ipv4)
			_ = Darwin.close(socket_ipv6)
			throw SocketError.flags
		}
		
		let success_nonblocking_ipv4 = fcntl(socket_ipv4, F_SETFL, flags_ipv4 | O_NONBLOCK)
		let success_nonblocking_ipv6 = fcntl(socket_ipv6, F_SETFL, flags_ipv6 | O_NONBLOCK)
		
		guard success_nonblocking_ipv4 >= 0 && success_nonblocking_ipv6 >= 0
		else
		{
			_ = Darwin.close(socket_ipv4)
			_ = Darwin.close(socket_ipv6)
			throw SocketError.nonblocking
		}
		
		address_in_ipv4 = sockaddr_in()
		address_in_ipv6 = sockaddr_in6()
		
		address_in_ipv4.sin_len = __uint8_t(MemoryLayout<sockaddr_in>.size)
		address_in_ipv6.sin6_len = __uint8_t(MemoryLayout<sockaddr_in6>.size)
		
		address_in_ipv4.sin_family = sa_family_t(AF_INET)
		address_in_ipv6.sin6_family = sa_family_t(AF_INET6)
		
		address_in_ipv4.sin_addr.s_addr = UInt32(0x00000000)
		address_in_ipv6.sin6_addr = in6addr_any
		
		address_in_ipv4.sin_port = htons(port)
		address_in_ipv6.sin6_port = htons(port)
		
		address_in_ipv4.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
		
		let success_ipv4 = bind(socket_ipv4, [sockaddr_in_cast(&address_in_ipv4)], socklen_t(MemoryLayout<sockaddr_in>.size))
		let success_ipv6 = bind(socket_ipv6, [sockaddr_in_cast(&address_in_ipv6)], socklen_t(MemoryLayout<sockaddr_in6>.size))
		
		guard success_ipv4 >= 0 && success_ipv6 >= 0
		else
		{
			_ = Darwin.close(socket_ipv4)
			_ = Darwin.close(socket_ipv6)
			throw SocketError.bind
		}
		
		let success_listen_ipv4 = listen(socket_ipv4, SOMAXCONN)
		let success_listen_ipv6 = listen(socket_ipv6, SOMAXCONN)
		
		guard success_listen_ipv4 >= 0 && success_listen_ipv6 >= 0
			else
		{
			_ = Darwin.close(socket_ipv4)
			_ = Darwin.close(socket_ipv6)
			throw SocketError.listen
		}
		
		dispatch_source_ipv4 = DispatchSource.makeReadSource(fileDescriptor: socket_ipv4, queue: DispatchQueue.global()) /*Migrator FIXME: Use DispatchSourceRead to avoid the cast*/ as! DispatchSource
		dispatch_source_ipv4.setEventHandler
		{
			self.acceptConnection(self.socket_ipv4)
		}
		dispatch_source_ipv4.resume()
		
		dispatch_source_ipv6 = DispatchSource.makeReadSource(fileDescriptor: socket_ipv6, queue: DispatchQueue.global()) /*Migrator FIXME: Use DispatchSourceRead to avoid the cast*/ as! DispatchSource
		dispatch_source_ipv6.setEventHandler
		{
			self.acceptConnection(self.socket_ipv6)
		}
		dispatch_source_ipv6.resume()
	}
	
	
	/**

	The server socket is closed when 
	it is released.
	
	*/
	deinit
	{
		close()
	}
	
	
	/**

	Accepts a new connection and tries to create a socket
	object for it.
	
	On success, the delegate is notified and the created socket is
	passed to the delegate.
	
	On failure, the delegate is notified and the error
	is passed to the delegate.
	
	- parameter server_socket: The server socket which received a new connection
	
	*/
	fileprivate func acceptConnection(_ server_socket: Int32)
	{
		var address = sockaddr()
		var address_length = socklen_t(MemoryLayout<sockaddr>.size)
		let socketHandle = accept(server_socket, &address, &address_length)
		guard socketHandle >= 0
			else
		{
			delegate?.serverSocket(self, didFailToAcceptConnectionWithError: SocketError.accept)
			return
		}
		
		let socket = TCPSocket(handle: socketHandle, address: address)
		DispatchQueue.global().async
		{
			self.delegate?.serverSocket(self, didAcceptConnectionWithSocket: socket)
		}
	}
	
	
	/**

	Closes the server socket so no more connections can be made to it.
	
	After the server socket was closed, other server sockets may be opened on the same port.
	
	*/
	public func close()
	{
		_ = Darwin.close(socket_ipv4)
		_ = Darwin.close(socket_ipv6)
		
		if dispatch_source_ipv4 != nil
		{
			dispatch_source_ipv4.cancel()
		}
		if dispatch_source_ipv6 != nil
		{
			dispatch_source_ipv6.cancel()
		}
	}
}
