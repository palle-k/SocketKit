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

public protocol ServerSocketDelegate
{
	func serverSocket(serverSocket: ServerSocket, didAcceptConnectionWithSocket socket: Socket)
	func serverSocket(serverSocket: ServerSocket, didFailToAcceptConnectionWithError error: SocketError)
}

public class ServerSocket
{
	private let socket_ipv4:Int32
	private let socket_ipv6:Int32
	
	private var address_in_ipv4:sockaddr_in
	private var address_in_ipv6:sockaddr_in6
	
	private var dispatch_source_ipv4:dispatch_source_t!
	private var dispatch_source_ipv6:dispatch_source_t!
	
	public var delegate:ServerSocketDelegate?
	
	public init(port: UInt16) throws
	{
		signal(SIGPIPE, SIG_IGN)
		
		socket_ipv4 = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)
		socket_ipv6 = socket(PF_INET6, SOCK_STREAM, IPPROTO_TCP)
		
		//Separated into two guard-statements because of compiler issue: Error when using both in a guard statement
		
		guard socket_ipv4 >= 0
			else
		{
			Darwin.close(socket_ipv4)
			throw SocketError.Open
		}
		
		guard socket_ipv6 >= 0
			else
		{
			Darwin.close(socket_ipv6)
			throw SocketError.Open
		}
		
		var reuse:Int32 = 1
		
		let succes_reuse_ipv4 = setsockopt(socket_ipv4, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(sizeof(reuse.dynamicType)))
		let succes_reuse_ipv6 = setsockopt(socket_ipv6, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(sizeof(reuse.dynamicType)))
		
		guard succes_reuse_ipv4 >= 0 && succes_reuse_ipv6 >= 0
			else
		{
			Darwin.close(socket_ipv4)
			Darwin.close(socket_ipv6)
			throw SocketError.Reuse
		}
		
		let flags_ipv4 = fcntl(socket_ipv4, F_GETFL, 0)
		let flags_ipv6 = fcntl(socket_ipv6, F_GETFL, 0)
		
		guard flags_ipv4 >= 0 && flags_ipv6 >= 0
		else
		{
			Darwin.close(socket_ipv4)
			Darwin.close(socket_ipv6)
			throw SocketError.Flags
		}
		
		let success_nonblocking_ipv4 = fcntl(socket_ipv4, F_SETFL, flags_ipv4 | O_NONBLOCK)
		let success_nonblocking_ipv6 = fcntl(socket_ipv6, F_SETFL, flags_ipv6 | O_NONBLOCK)
		
		guard success_nonblocking_ipv4 >= 0 && success_nonblocking_ipv6 >= 0
		else
		{
			Darwin.close(socket_ipv4)
			Darwin.close(socket_ipv6)
			throw SocketError.Nonblocking
		}
		
		address_in_ipv4 = sockaddr_in()
		address_in_ipv6 = sockaddr_in6()
		
		address_in_ipv4.sin_len = __uint8_t(sizeof(address_in_ipv4.dynamicType))
		address_in_ipv6.sin6_len = __uint8_t(sizeof(address_in_ipv6.dynamicType))
		
		address_in_ipv4.sin_family = sa_family_t(AF_INET)
		address_in_ipv6.sin6_family = sa_family_t(AF_INET6)
		
		address_in_ipv4.sin_addr.s_addr = UInt32(0x00000000)
		address_in_ipv6.sin6_addr = in6addr_any
		
		address_in_ipv4.sin_port = htons(port)
		address_in_ipv6.sin6_port = htons(port)
		
		address_in_ipv4.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
		
		let success_ipv4 = withUnsafePointer(&address_in_ipv4)
		{
			bind(socket_ipv4, UnsafePointer<sockaddr>($0), socklen_t(sizeof(address_in_ipv4.dynamicType)))
		}
		
		let success_ipv6 = withUnsafePointer(&address_in_ipv6)
		{
			bind(socket_ipv6, UnsafePointer<sockaddr>($0), socklen_t(sizeof(address_in_ipv6.dynamicType)))
		}
		
		guard success_ipv4 >= 0 && success_ipv6 >= 0
		else
		{
			Darwin.close(socket_ipv4)
			Darwin.close(socket_ipv6)
			throw SocketError.Bind
		}
		
		let success_listen_ipv4 = listen(socket_ipv4, SOMAXCONN)
		let success_listen_ipv6 = listen(socket_ipv6, SOMAXCONN)
		
		guard success_listen_ipv4 >= 0 && success_listen_ipv6 >= 0
			else
		{
			Darwin.close(socket_ipv4)
			Darwin.close(socket_ipv6)
			throw SocketError.Listen
		}
		
		dispatch_source_ipv4 = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, UInt(socket_ipv4), 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
		dispatch_source_set_event_handler(dispatch_source_ipv4)
		{
			self.acceptConnection(self.socket_ipv4)
		}
		dispatch_resume(dispatch_source_ipv4)
		
		dispatch_source_ipv6 = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, UInt(socket_ipv6), 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
		dispatch_source_set_event_handler(dispatch_source_ipv6)
		{
			self.acceptConnection(self.socket_ipv6)
		}
		dispatch_resume(dispatch_source_ipv6)
	}
	
	deinit
	{
		close()
	}
	
	func acceptConnection(server_socket: Int32)
	{
		var address = sockaddr()
		var address_length = socklen_t(sizeof(address.dynamicType))
		let socketHandle = accept(server_socket, &address, &address_length)
		guard socketHandle >= 0
			else
		{
			delegate?.serverSocket(self, didFailToAcceptConnectionWithError: SocketError.Accept)
			return
		}
		
		let socket = Socket(handle: socketHandle, address: address)
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
		{
			self.delegate?.serverSocket(self, didAcceptConnectionWithSocket: socket)
		}
	}
	
	public func close()
	{
		Darwin.close(socket_ipv4)
		Darwin.close(socket_ipv6)
		
		if dispatch_source_ipv4 != nil
		{
			dispatch_source_cancel(dispatch_source_ipv4)
		}
		if dispatch_source_ipv6 != nil
		{
			dispatch_source_cancel(dispatch_source_ipv6)
		}
	}
}