//
//  OutputStream.swift
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

public protocol OutputStream
{
	var open:Bool { get }
	func write(data: NSData) throws
	func write(string: String, encoding: UInt) throws
	func write(data: UnsafePointer<Void>, lengthInBytes byteCount: Int) throws
	func write(streamWritable: StreamWritable) throws
	func writeln(string: String, encoding: UInt) throws
	func flush() throws
	func close()
}

public extension OutputStream
{
	public func write(data: NSData) throws
	{
		try write(data.bytes, lengthInBytes: data.length)
	}
	
	public func write(string: String, encoding: UInt = NSUTF8StringEncoding) throws
	{
		guard let data = string.dataUsingEncoding(encoding)
		else
		{
			throw DataError.StringConversion
		}
		try write(data)
	}
	
	public func writeln(string: String = "", encoding: UInt = NSUTF8StringEncoding) throws
	{
		guard let data = "\(string)\r\n".dataUsingEncoding(encoding)
			else
		{
			throw DataError.StringConversion
		}
		try write(data)
	}
	
	public func write(streamWritable: StreamWritable) throws
	{
		try streamWritable.write(toStream: self)
	}
}

public protocol StreamWritable
{
	func write(toStream outputStream: OutputStream) throws
}

internal class SocketOutputStreamImpl : OutputStream
{
	private let handle: Int32
	private let buffer: UnsafeMutablePointer<CChar>
	private let bufferSize: Int
	private var buffer_count: Int
	private weak var socket: Socket?
	internal private(set) var open = false
	
	internal init(socket: Socket, handle: Int32, bufferSize: Int = 2048)
	{
		self.socket = socket
		self.handle = handle
		buffer = UnsafeMutablePointer<CChar>.alloc(bufferSize)
		buffer_count = 0
		self.bufferSize = bufferSize
		self.open = true
	}
	
	internal func write(data: UnsafePointer<Void>, lengthInBytes byteCount: Int) throws
	{
		assert(byteCount >= 0, "Byte count must be greater than or equal to zero.")
		
		DEBUG_HEXDUMP ?-> print("Write:\n\(hex(data, length: byteCount))")
		
		
//		var bytePosition = 0
//		while bytePosition < byteCount
//		{
//			print("Copying from input buffer at offset \(bytePosition)")
//			print("Copying into write buffer at offset \(buffer_count)")
//			let offsetTarget = buffer.advancedBy(buffer_count)
//			let offsetSource = data.advancedBy(bytePosition)
//			let numBytes = min(bufferSize - buffer_count, byteCount - bytePosition)
//			print("Copying \(numBytes) bytes")
//			bytePosition += numBytes
//			buffer_count = (buffer_count + numBytes) % bufferSize
//			print("Advancing buffer count to \(buffer_count)")
//			memcpy(offsetTarget, offsetSource, numBytes)
//			if buffer_count == 0
//			{
//				print("Flushing buffer.")
//				try flush()
//			}
//		}
//		try flush()
//		
		
		var advance = 0
		repeat
		{
			let maxBytes = byteCount - advance
			
			DEBUG ?-> print("Writing into socket... (left: \(maxBytes), written: \(advance))")
			
			let written = Darwin.write(handle, data.advancedBy(advance), maxBytes)
			
			DEBUG ?-> print("\(written) bytes written.")
			
			if written < 0 && !(errno == EAGAIN || errno == EINTR)
			{
				DEBUG ?-> print("An error occurred while writing. Check thrown IOError.")
				DEBUG ?-> print(String.fromCString(strerror(errno)))
				throw IOError.FromCurrentErrno()
			}
			else
			{
				advance += max(written, 0)
			}
		}
		while advance < byteCount
	}
	
	internal func flush() throws
	{
//		var data_count = 0
//		var advance = 0
//		
//		repeat
//		{
//			let maxCount = (buffer_count == 0 ? bufferSize : buffer_count) - advance
//			data_count = Darwin.write(handle, buffer.advancedBy(advance), maxCount)
//			advance += max(data_count, 0)
//		}
//		while /*data_count < 0 && (errno == EAGAIN || errno == EINTR) &&*/ advance < buffer_count
//		
//		print("Flushed buffer.")
//		
//		buffer_count = 0
//		
//		if data_count < 0
//		{
//			switch errno
//			{
//			case EBADF:
//				throw IOError.InvalidSocket
//			case EBADMSG:
//				throw IOError.BadMessage
//			case EINVAL:
//				throw IOError.Invalid
//			case EIO:
//				throw IOError.Physical
//			case EOVERFLOW:
//				throw IOError.Overflow
//			case ECONNRESET:
//				throw IOError.ConnectionReset
//			case ENOTCONN:
//				throw IOError.NotConnected
//			case ETIMEDOUT:
//				throw IOError.TimedOut
//			case ENOBUFS:
//				throw IOError.InsufficientRessources
//			case ENOMEM:
//				throw IOError.OutOfMemory
//			case EFBIG:
//				throw IOError.TooBig
//			case ENXIO:
//				throw IOError.NonexistentDevice
//			default:
//				throw IOError.Unknown
//			}
//		}
	}
	
	internal func close()
	{
		guard open else { return }
		open = false
		buffer.dealloc(bufferSize)
		shutdown(handle, SHUT_WR) < 0
		socket?.checkStreams()
	}
	
	deinit
	{
		close()
	}
}

