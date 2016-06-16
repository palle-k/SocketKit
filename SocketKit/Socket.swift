//
//  Socket.swift
//  SocketKit
//
//  Created by Palle Klewitz on 10.04.16.
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

The Socket protocol provides an interface for a network socket,
which is an endpoint in network communication.

The user can communicate through the streams provided by the socket.
Incoming data can be retrieved through the input stream and data can be written
to the network with the output stream.

*/
public protocol Socket : class
{
	/**
	
	Host address of the peer.
	
	Only used for outgoing connections.
	
	*/
	var hostAddress: String? { get }
	
	/**
	
	The input stream of the socket.
	
	Incoming data can be read from it.
	
	If the socket uses non-blocking I/O,
	a delegate should be used to receive notifications about
	incoming data.
	
	
	*/
	var inputStream: InputStream! { get }
	
	/**
	
	The output stream of the socket.
	
	Can write data to the socket.
	
	If the socket uses non-blocking I/O,
	the operation may fail and a
	.WouldBlock or .Again IOError may be thrown.
	The operation must then be tried again.
	
	*/
	var outputStream: OutputStream! { get }
	
	
	/**
	
	Indicates, if non-blocking I/O is used
	or en-/disables non-blocking I/O.
	
	If non-blocking I/O is used, reading
	from the socket may not return any data
	and writing may fail because it would otherwise
	block the current thread.
	
	In this case, a .WouldBlock or .Again
	IOError will be thrown.
	
	The operation must be repeated until it was successful.
	
	For read operations, the delegate of the stream should be used
	for efficient reading.
	
	- parameter new: Specifies, if the socket should be non-blocking or not.
	A value of true sets the socket to nonblocking mode, false to blocking mode.
	
	- returns: true, if the socket is nonblocking, false if it is blocking.
	
	*/
	var nonblocking: Bool { get set }
	
	/**
	
	Checks if the socket is open.
	
	The socket is open if at least one of the streams associated with this socket is open.
	
	*/
	var open:Bool { get }
	
	
	/**
	
	Manually closes the socket
	and releases any ressources related to it.
	
	Subsequent calls of the streams' read and write
	functions will fail.
	
	*/
	func close()
	
	
	/**
	
	Checks the status of the streams which read and write from and to this socket.
	
	If both streams are closed, the socket will be closed.
	
	*/
	func checkStreams()
}


/**

Extension for stream checking.

*/
public extension Socket
{
	
	/**
	
	Checks the status of the streams which read and write from and to this socket.
	
	If both streams are closed, the socket will be closed.
	
	*/
	func checkStreams()
	{
		if !inputStream.open && !outputStream.open
		{
			close()
		}
	}
	
}

/**

A socket which internally uses POSIX APIs

This may include UDP, TCP or RAW sockets.

*/
internal protocol POSIXSocket : Socket
{
	
	/**
	
	The POSIX-socket handle of this socket.
	
	Input and output streams use this for read
	and write operations.
	
	*/
	var handle: Int32 { get }
	
	
	/**
	
	The address of the socket.
	
	Contains port and ip information
	
	*/
	var address: sockaddr { get }
	
}


/**

Socket: Endpoint of a TCP/IP connection.

Data can be read from the socket with the input stream
provided as a property of a socket instance.

Data can be written to the socket with the output stream
provided as a property of a socket instance.

*/
public class TCPSocket : POSIXSocket, CustomStringConvertible
{
	
	/**

	The POSIX-socket handle of this socket.
	
	Input and output streams use this for read
	and write operations.
	
	*/
	internal let handle: Int32
	
	
	/**

	The address of the socket.
	
	Contains port and ip information
	
	*/
	internal var address: sockaddr
	
	
	/**

	Host address of the peer.
	
	Only used for outgoing connections.
	
	*/
	public private(set) var hostAddress: String?
	
	
	/**
	
	Indicates, if non-blocking I/O is used
	or en-/disables non-blocking I/O.
	
	If non-blocking I/O is used, reading
	from the socket may not return any data
	and writing may fail because it would otherwise
	block the current thread.
	
	In this case, a .WouldBlock or .Again
	IOError will be thrown.
	
	The operation must be repeated until it was successful.
	
	For read operations, the delegate of the stream should be used
	for efficient reading.
	
	- parameter new: Specifies, if the socket should be non-blocking or not.
	A value of true sets the socket to nonblocking mode, false to blocking mode.
	
	- returns: true, if the socket is nonblocking, false if it is blocking.
	
	*/
	public var nonblocking: Bool
	{
		get
		{
			let flags = fcntl(handle, F_GETFL, 0)
			return (flags & O_NONBLOCK) != 0
		}
		set (new)
		{
			let flags = fcntl(handle, F_GETFL, 0)
			_ = fcntl(handle, F_SETFL, new ? (flags | O_NONBLOCK) : (flags & ~O_NONBLOCK))
		}
	}
	
	
	/**

	The input stream of the socket.
	
	Incoming data can be read from it.
	
	If the socket uses non-blocking I/O,
	a delegate should be used to receive notifications about
	incoming data.
	
	
	*/
	public private(set) var inputStream: InputStream!
	
	
	/**
	
	The output stream of the socket.
	
	Can write data to the socket.
	
	If the socket uses non-blocking I/O,
	the operation may fail and a 
	.WouldBlock or .Again IOError may be thrown.
	The operation must then be tried again.
	
	*/
	public private(set) var outputStream: OutputStream!
	
	
	/**

	Returns the IP address of the peer
	to which this socket is connected to.
	
	The result is a IPv4 or IPv6 address
	depending on the IP protocol version used.
	
	*/
	public var peerIP:String?
	{
		if address.sa_family == sa_family_t(AF_INET)
		{
			let ptr = UnsafeMutablePointer<CChar>.alloc(Int(INET_ADDRSTRLEN))
			var address_in = sockaddr_cast(&address)
			inet_ntop(AF_INET, &address_in.sin_addr, ptr, socklen_t(INET_ADDRSTRLEN))
			return String.fromCString(ptr)
		}
		else if address.sa_family == sa_family_t(AF_INET6)
		{
			let ptr = UnsafeMutablePointer<CChar>.alloc(Int(INET6_ADDRSTRLEN))
			var address_in = sockaddr_cast(&address)
			inet_ntop(AF_INET, &address_in.sin_addr, ptr, socklen_t(INET6_ADDRSTRLEN))
			return String.fromCString(ptr)
		}
		
		return nil
	}
	
	
	/**

	Checks if the socket is open.
	
	The socket is open if at least one of the streams associated with this socket is open.
	
	*/
	public var open:Bool
	{
		return inputStream.open || outputStream.open
	}
	
	
	/**

	A textual representation of self.
	
	*/
	public var description: String
	{
		return "Socket (host: \(self.hostAddress ?? "unknown"), ip: \(self.peerIP ?? "unknown"), \(self.open ? "open" : "closed"))\n\t-> \(self.inputStream)\n\t<- \(self.outputStream)"
	}
	
	
	/**

	Initializes the socket and connects to the address specified in `host`.
	
	The `host` address must be an IPv4 address.
	
	- parameter host: IPv4 peer address string
	
	- parameter port: Port to which the socket should connect.
	
	- throws: A SocketError if the socket could not be connected.
	
	*/
	public convenience init(ipv4host host: String, port: UInt16) throws
	{
		let handle = Darwin.socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)
		guard handle >= 0
		else
		{
			Darwin.close(handle)
			throw SocketError.Open
		}
		
		var address = sockaddr_in()
		
		address.sin_len = __uint8_t(sizeof(address.dynamicType))
		address.sin_family = sa_family_t(AF_INET)
		address.sin_port = htons(port)
		address.sin_addr = in_addr(s_addr: inet_addr(host))
		
		let success = withUnsafePointer(&address)
		{
			connect(handle, UnsafePointer<sockaddr>($0), socklen_t(sizeof(address.dynamicType)))
		}
		
		guard success >= 0
		else
		{
			Darwin.close(handle)
			throw SocketError.Open
		}
		
		self.init(handle: handle, address: sockaddr())
		hostAddress = host
	}
	
	
	/**

	Initializes a socket with a given host address and TCP port
	
	The socket will automatically connect to the given host.
	
	- parameter address: The host address of the server to connect to.
	
	- parameter port: The TCP port on which the server should be connected.
	
	*/
	public init?(address: String, port: UInt16) throws
	{
		var readStreamRef:Unmanaged<CFReadStream>?
		var writeStreamRef:Unmanaged<CFWriteStream>?
		CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, address, UInt32(port), &readStreamRef, &writeStreamRef)
		guard
		let readStream = readStreamRef?.takeRetainedValue(),
		let writeStream = writeStreamRef?.takeRetainedValue()
			else { return nil }
		
		CFReadStreamOpen(readStream)
		CFWriteStreamOpen(writeStream)
		
		guard let handle = CFReadStreamCopyProperty(readStream, kCFStreamPropertySocketNativeHandle) as? Int32 else { return nil }
		self.handle = handle
		
		var sockaddress = sockaddr()
		var sockaddrlen = socklen_t(sizeof(sockaddr.self))
		getpeername(handle, &sockaddress, &sockaddrlen)
		self.address = sockaddress
	}
	
	
	/**

	Initializes a socket with the given handle and address.
	
	The handle must be the value of a POSIX-socket.
	
	The socket address should contain information about the
	peer to which this socket is connected.
	
	- parameter handle: The POSIX-socket handle.
	
	- parameter address: The peer address.
	
	*/
	internal init(handle: Int32, address: sockaddr)
	{
		self.handle = handle
		self.address = address
		
		var one:Int32 = 1
		
		setsockopt(self.handle, SOL_SOCKET, SO_NOSIGPIPE, &one, UInt32(sizeof(one.dynamicType)))
		
		nonblocking = false
		
//		let success_nodelay = setsockopt(handle, IPPROTO_TCP, TCP_NODELAY, &one, socklen_t(sizeof(Int32)))
//		DEBUG && success_nodelay < 0 ?-> print("Failed to set TCP_NODELAY.")
		
		inputStream = SocketInputStreamImpl(socket: self, handle: handle)
		outputStream = SocketOutputStreamImpl(socket: self, handle: handle)
	}
	
	
	/**

	The socket is closed when deallocated.
	
	*/
	deinit
	{
		close()
	}
	
	
	/**

	Manually closes the socket
	and releases any ressources related to it.
	
	Subsequent calls of the streams' read and write
	functions will fail.
	
	*/
	public func close()
	{
		DEBUG ?-> print("Closing socket...")
		inputStream.close()
		outputStream.close()
		Darwin.close(handle)
	}
	
	
	/**

	Checks the status of the streams which read and write from and to this socket.
	
	If both streams are closed, the socket will be closed.
	
	*/
	public func checkStreams()
	{
		DEBUG ?-> print("Checking streams. input stream: \(inputStream.open ? "open" : "closed"), output stream: \(outputStream.open ? "open" : "closed")")
		if !inputStream.open && !outputStream.open
		{
			close()
		}
	}
}


//public class RawSocket : POSIXSocket
//{
//	
//	/**
//	
//	The POSIX-socket handle of this socket.
//	
//	Input and output streams use this for read
//	and write operations.
//	
//	*/
//	private(set) var handle: Int32
//	
//	
//	/**
//	
//	The address of the socket.
//	
//	Contains port and ip information
//	
//	*/
//	private (set) var address: sockaddr
//	
//	
//	/**
//	
//	The address of the host to which this socket is connected.
//	
//	Will always be nil because a raw socket does not work on a connection.
//	
//	*/
//	public let hostAddress: String? = nil
//	
//	
//	/**
//	
//	Checks if the socket is open.
//	
//	The socket is open if at least one of the streams associated with this socket is open.
//	
//	*/
//	public private(set) var open: Bool
//	
//	
//	/**
//	
//	Indicates, if non-blocking I/O is used
//	or en-/disables non-blocking I/O.
//	
//	If non-blocking I/O is used, reading
//	from the socket may not return any data
//	and writing may fail because it would otherwise
//	block the current thread.
//	
//	In this case, a .WouldBlock or .Again
//	IOError will be thrown.
//	
//	The operation must be repeated until it was successful.
//	
//	For read operations, the delegate of the stream should be used
//	for efficient reading.
//	
//	- parameter new: Specifies, if the socket should be non-blocking or not.
//	A value of true sets the socket to nonblocking mode, false to blocking mode.
//	
//	- returns: true, if the socket is nonblocking, false if it is blocking.
//	
//	*/
//	public var nonblocking: Bool
//	{
//		get
//		{
//			let flags = fcntl(handle, F_GETFL, 0)
//			return (flags & O_NONBLOCK) != 0
//		}
//		set (new)
//		{
//			let flags = fcntl(handle, F_GETFL, 0)
//			_ = fcntl(handle, F_SETFL, new ? (flags | O_NONBLOCK) : (flags & ~O_NONBLOCK))
//		}
//	}
//	
//	
//	/**
//	
//	The input stream of the socket.
//	
//	Incoming data can be read from it.
//	
//	If the socket uses non-blocking I/O,
//	a delegate should be used to receive notifications about
//	incoming data.
//	
//	*/
//	public private(set) var inputStream: InputStream!
//	
//	
//	/**
//	
//	The output stream of the socket.
//	
//	Can write data to the socket.
//	
//	If the socket uses non-blocking I/O,
//	the operation may fail and a
//	.WouldBlock or .Again IOError may be thrown.
//	The operation must then be tried again.
//	
//	*/
//	public private(set) var outputStream: OutputStream!
//	
//	
//	public init() throws
//	{
//		handle = socket(PF_INET, SOCK_RAW, IPPROTO_ICMP)
//		
//		guard handle >= 0 else
//		{
//			throw SocketError.Open
//		}
//		
//		//simulating undeclared sockaddr_ll struct
//		var ll_addr = [UInt8](count: 13, repeatedValue: 0)
//		ll_addr[0] = UInt8(AF_LINK)
//		ll_addr[1] = UInt8(AF_LINK >> 8)
//		
//		address = sockaddr()
//		memcpy(&address, &ll_addr, 13)
//		
//		guard bind(handle, &address, socklen_t(sizeof(ll_addr.dynamicType))) >= 0
//		else
//		{
//			throw SocketError.Bind
//		}
//		
//		open = true
//		
//		inputStream = nil
//		outputStream = nil
//		inputStream = SocketInputStreamImpl(socket: self, handle: handle)
//		outputStream = SocketOutputStreamImpl(socket: self, handle: handle)
//		nonblocking = true
//	}
//	
//	
//	/**
//	
//	The socket is closed when deallocated.
//	
//	*/
//	deinit
//	{
//		close()
//	}
//	
//	
//	/**
//	
//	Manually closes the socket
//	and releases any ressources related to it.
//	
//	Subsequent calls of the streams' read and write
//	functions will fail.
//	
//	*/
//	public func close()
//	{
//		DEBUG ?-> print("Closing socket...")
//		inputStream.close()
//		outputStream.close()
//		Darwin.close(handle)
//	}
//}

/**

Compares two sockets.

If the handles of the left and right socket are
equal, true is returned, otherwise falls will be returned.

- parameter left: First socket to compare

- parameter right: Second socket to compare

- returns: The comparison result from the comparison of the two sockets.

*/
internal func == (left: POSIXSocket, right: POSIXSocket) -> Bool
{
	return left.handle == right.handle
}



