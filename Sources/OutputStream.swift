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

/**

Output stream for writing to an underlying target.

**Implementation notes:**

Only the function `write(data: UnsafePointer<Void>, lengthInBytes byteCount: Int) throws`
should be implemented. Other `write`/`writeln` functions should not be implemented
as they are already implemented as an extension which will call the 
`write(data: UnsafePointer<Void>, lengthInBytes byteCount: Int) throws`
function.

*/
public protocol OutputStream
{
	
	/**
	
	True, if the stream is open and data can be written.
	
	False, if the stream is closed and data cannot be written.
	Any calls of the write-function will fail and an IOError will
	be thrown.
	
	If the state of the stream changes, the delegate is notified
	by a call of the `didClose`-Method.
	
	*/
	var open:Bool { get }
	
	
	/**
	
	Writes the given data into the underlying ressource.
	
	The error may be .WouldBlock or .Again, which indicates
	that the read operation failed because no data is available
	and non-blocking I/O is used.
	In this case, the write operation has to be repeated.
	
	- parameter data: Data which should be written.
	
	- throws: An IOError indicating that the operation failed.
	
	*/
	func write(_ data: Data) throws
	
	
	/**
	
	Writes the given string encoded by the given encoding
	into the underlying ressource.
	
	The error may be .WouldBlock or .Again, which indicates
	that the read operation failed because no data is available
	and non-blocking I/O is used.
	In this case, the write operation has to be repeated.
	
	- parameter string: String which should be written
	
	- parameter encoding: Encoding to be used to convert the 
	string to bytes. By default the string will be encoded
	using UTF-8 encoding.
	
	- throws: An IOError indicating that the operation failed.
	
	*/
	func write(_ string: String, encoding: String.Encoding) throws
	
	
	/**

	Writes the data at the given pointer into the underlying
	target. The byteCount specifies that
	
	The error may be .WouldBlock or .Again, which indicates
	that the read operation failed because no data is available
	and non-blocking I/O is used.
	In this case, the write operation has to be repeated.
	
	- parameter data: Pointer to the data to be written
	
	- parameter byteCount: Number of bytes to be written
	
	- throws: An IOError indicating that the operation failed.
	
	*/
	func write(_ data: UnsafeRawPointer, lengthInBytes byteCount: Int) throws
	
	
	/**

	Writes the given StreamWritable-object into the underlying
	target.
	
	The error may be .WouldBlock or .Again, which indicates
	that the read operation failed because no data is available
	and non-blocking I/O is used.
	In this case, the write operation has to be repeated.
	
	- parameter streamWritable: The object to be written.
	
	- throws: An IOError indicating that the operation failed.
	
	*/
	func write(_ streamWritable: StreamWritable) throws
	
	
	/**
	
	Writes the given string followed by a newline
	encoded by the given encoding into the underlying ressource.
	
	The error may be .WouldBlock or .Again, which indicates
	that the read operation failed because no data is available
	and non-blocking I/O is used.
	In this case, the write operation has to be repeated.
	
	- parameter string: String which should be written. If no string
	is specified, only a newline will be written.
	
	- parameter encoding: Encoding to be used to convert the
	string to bytes. By default the string will be encoded
	using UTF-8 encoding.
	
	- throws: An IOError indicating that the operation failed.
	
	*/
	func writeln(_ string: String, encoding: String.Encoding) throws
	
	
	/**

	Closes the stream and releases any associated ressources.
	
	Subsequent calls to the write-function should fail with
	an IOError.
	
	If the stream writes into a socket, the socket should be notified
	of this operation so it can be closed automatically if both streams
	are closed.
	
	*/
	func close()
	
}


/**

Extension of the OutputStream protocol
for the default implementation of write-function
overloads.

*/
public extension OutputStream
{

	/**
	
	Writes the given data into the underlying ressource.
	
	The error may be .WouldBlock or .Again, which indicates
	that the read operation failed because no data is available
	and non-blocking I/O is used.
	In this case, the write operation has to be repeated.
	
	- parameter data: Data which should be written.
	
	- throws: An IOError indicating that the operation failed.
	
	*/
	public func write(_ data: Data) throws
	{
		try write((data as NSData).bytes, lengthInBytes: data.count)
	}
	
	
	/**
	
	Writes the data at the given pointer into the underlying
	target. The byteCount specifies that
	
	The error may be .WouldBlock or .Again, which indicates
	that the read operation failed because no data is available
	and non-blocking I/O is used.
	In this case, the write operation has to be repeated.
	
	- parameter data: Pointer to the data to be written
	
	- parameter byteCount: Number of bytes to be written
	
	- throws: An IOError indicating that the operation failed.
	
	*/
	public func write(_ string: String, encoding: String.Encoding = String.Encoding.utf8) throws
	{
		guard let data = string.data(using: encoding)
		else
		{
			throw DataError.stringConversion
		}
		try write(data)
	}
	
	
	/**
	
	Writes the given string followed by a newline
	encoded by the given encoding into the underlying ressource.
	
	The error may be .WouldBlock or .Again, which indicates
	that the read operation failed because no data is available
	and non-blocking I/O is used.
	In this case, the write operation has to be repeated.
	
	- parameter string: String which should be written. If no string
	is specified, only a newline will be written.
	
	- parameter encoding: Encoding to be used to convert the
	string to bytes. By default the string will be encoded
	using UTF-8 encoding.
	
	- throws: An IOError indicating that the operation failed.
	
	*/
	public func writeln(_ string: String = "", encoding: String.Encoding = String.Encoding.utf8) throws
	{
		guard let data = "\(string)\r\n".data(using: encoding)
			else
		{
			throw DataError.stringConversion
		}
		try write(data)
	}
	
	
	/**
	
	Writes the given StreamWritable-object into the underlying
	target.
	
	The error may be .WouldBlock or .Again, which indicates
	that the read operation failed because no data is available
	and non-blocking I/O is used.
	In this case, the write operation has to be repeated.
	
	- parameter streamWritable: The object to be written.
	
	- throws: An IOError indicating that the operation failed.
	
	*/
	public func write(_ streamWritable: StreamWritable) throws
	{
		try streamWritable.write(to: self)
	}
	
}


/**

Protocol for stream-serialization
of objects.

A type implementing this protocol
can write itself into an OutputStream.

If an object should also 
be stream-deserializable, it must implement the
StreamReadable-protocol.

*/
public protocol StreamWritable
{
	
	/**

	Writes the object into the given stream.
	
	If any write operation fails,
	this method may throw an IOError.
	
	- parameter outputStream: Stream to write this object to
	
	- throws: An IOError indicating that the operation failed.
	
	*/
	func write(to outputStream: OutputStream) throws
	
}


/**

Implementation of the OutputStream protocol for 
writing into a POSIX-socket.

*/
internal class SocketOutputStreamImpl : OutputStream
{
	
	/**
	
	The posix socket handle for network writing.
	
	*/
	fileprivate let handle: Int32
	
	
	/**
	
	Socket, to which this stream writes data.
	
	If the stream is closed, the socket will be notified of this
	and close itself, if both streams are closed.
	
	*/
	fileprivate weak var socket: Socket?
	
	
	/**
	
	Specifies, if this stream is open and data can be written to it.
	
	If the stream is closed and a write operation is initiated,
	an IOError will be thrown.
	
	*/
	internal fileprivate(set) var open = false
	
	
	/**
	
	Initializes the stream with the socket to write to
	and the POSIX-socket handle for write operations.
	
	- parameter socket: The socket to which this stream writes.
	
	- parameter handle: The POSIX-socket handle for write operations.
	
	*/
	internal init(socket: Socket, handle: Int32)
	{
		self.socket = socket
		self.handle = handle
		self.open = true
	}
	
	
	/**

	Writes the given data of the specified length into
	the underlying POSIX-socket.
	
	If the operation fails, an IOError is thrown.
	
	If an .Interrupted error is thrown, the operation
	has to be repeated.
	
	- parameter data: Pointer to the data to be written.
	
	- parameter byteCount: Number of bytes to be written.
	
	- throws: An IOError indicating that the write operation failed.
	
	*/
	internal func write(_ data: UnsafeRawPointer, lengthInBytes byteCount: Int) throws
	{
		assert(byteCount >= 0, "Byte count must be greater than or equal to zero.")
		
		DEBUG_HEXDUMP ?-> print("Write:\n\(hex(data, length: byteCount))")
		
		var advance = 0
		repeat
		{
			let maxBytes = byteCount - advance
			
			DEBUG ?-> print("Writing into socket... (left: \(maxBytes), written: \(advance))")
			
			let written = Darwin.write(handle, data.advanced(by: advance), maxBytes)
			
			DEBUG ?-> print("\(written) bytes written.")
			
			if written < 0 && !(errno == EAGAIN || errno == EINTR)
			{
				DEBUG ?-> print("An error occurred while writing. Check thrown IOError.")
				DEBUG ?-> print(String(cString: strerror(errno)))
				let error = IOError.FromCurrentErrno()
				if error != .wouldBlock
				{
					socket?.close()
				}
				throw error
			}
			else
			{
				advance += max(written, 0)
			}
		}
		while advance < byteCount
	}
	
	
	/**
	
	Closes the stream manually and shuts down the socket
	so no more write calls are possible.
	
	Subsequent calls to the write-function function will fail.
	*/
	internal func close()
	{
		guard open else { return }
		open = false
		shutdown(handle, SHUT_WR)
		socket?.checkStreams()
	}
	
	
	/**
	
	When deinitialized, the stream will be closed.
	
	*/
	deinit
	{
		close()
	}
}


internal class SystemOutputStream : NSObject, OutputStream, StreamDelegate
{
	fileprivate(set) var open: Bool
	
	fileprivate let underlyingStream: Foundation.OutputStream
	
	internal init(underlyingStream: Foundation.OutputStream)
	{
		self.underlyingStream = underlyingStream
		open = true
		
		super.init()
		
		self.underlyingStream.delegate = self
		self.underlyingStream.open()
	}
	
	func write(_ data: UnsafeRawPointer, lengthInBytes byteCount: Int) throws
	{
		guard open else { throw underlyingStream.streamError ?? IOError.notConnected }
		
		var offset = 0;
		
		repeat
		{
			let written = underlyingStream.write(data.advanced(by: offset).assumingMemoryBound(to: UInt8.self), maxLength: byteCount - offset)
			if written < 0
			{
				throw underlyingStream.streamError ?? IOError.unknown
			}
			offset += written
		}
		while offset < byteCount
	}
	
	func close()
	{
		underlyingStream.close()
	}
	
	@objc func stream(_ aStream: Stream, handle eventCode: Stream.Event)
	{
		switch eventCode
		{
		case Stream.Event.endEncountered, Stream.Event.errorOccurred:
			open = false
			break
		default:
			break
		}
	}
}

