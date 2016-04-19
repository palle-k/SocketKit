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


public class Socket : CustomStringConvertible, Equatable
{
	private let handle: Int32
	private var address: sockaddr
	public private(set) var hostAddress: String?
	
	public private(set) var inputStream: InputStream!
	public private(set) var outputStream: OutputStream!
	
	public var nonblocking: Bool
	{
		get
		{
			let flags = fcntl(handle, F_GETFL, 0)
			return (flags & O_NONBLOCK) != 0
		}
		set (new)
		{
			var flags = fcntl(handle, F_GETFL, 0)
			if new
			{
				flags |= O_NONBLOCK
			}
			else
			{
				flags &= ~O_NONBLOCK
			}
			_ = fcntl(handle, F_SETFL, flags)
		}
	}
	
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
	
	public var open:Bool
	{
		return inputStream.open || outputStream.open
	}
	
	public var description: String
	{
		return "Socket (host: \(self.hostAddress ?? "unknown"), ip: \(self.peerIP ?? "unknown"), \(self.open ? "open" : "closed"))\n\t-> \(self.inputStream)\n\t<- \(self.outputStream)"
	}
	
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
	
	deinit
	{
		close()
	}
	
	public func close()
	{
		DEBUG ?-> print("Closing socket...")
		inputStream.close()
		outputStream.close()
		Darwin.close(handle)
	}
	
	internal func checkStreams()
	{
		DEBUG ?-> print("Checking streams. input stream: \(inputStream.open ? "open" : "closed"), output stream: \(outputStream.open ? "open" : "closed")")
		if !inputStream.open && !outputStream.open
		{
			close()
		}
	}
}

public func == (left: Socket, right: Socket) -> Bool
{
	return left.handle == right.handle
}

