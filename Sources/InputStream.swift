//
//  Stream.swift
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

Delegate for event reporting of an input stream.

Reports, if new data is available or if the stream was closed.

*/
public protocol InputStreamDelegate
{
	
	/**

	Notifies, that new data is available and can be read from the given stream.
	
	The received data can be obtained by calling the `read`-function
	
	- parameter inputStream: Stream, which did receive data which can be read.
	
	*/
	func canRead(from inputStream: InputStream)
	
	
	/**

	Notifies, that the stream was closed an no data can be read from it anymore.
	
	Subsequent calls to the `read`-function of the given stream will throw an error.
	
	- parameter inputStream: Stream, which was closed.
	
	*/
	func didClose(_ inputStream: InputStream)
}


/**

Input stream for reading from an underlying source.

**Implementation notes:**

The delegate should be notified, when new data comes available or the stream is closed.

If the stream implementation relies on an underlying stream, the delegate of the underlying
stream should be set to this stream.

The delegate of this stream implementation should then be notified about delegate
notifications from the underlying stream.

*/
public protocol InputStream : class
{
	
	/**

	True, if the stream is open and data can be read.
	
	False, if the stream is closed and data cannot be read.
	Any calls to the read function will fail with an error.
	
	If the state of the stream changes, the delegate is notified
	by a call of the `didClose`-Method.
	
	*/
	var open:Bool { get }
	
	
	/**
	
	Delegate for state change notifications.
	
	Reports, if new data is available or if the stream was closed.

	*/
	var delegate: InputStreamDelegate? { get set }
	
	
	/**

	Read data from the stream.
	
	The length of the returned array has a maximum length of `maxByteCount`.
	
	If an error occurred, an IOError will be thrown.
	
	The thrown IOError may be `IOError.WouldBlock`, `IOError.Again`
	or `IOError.Interrupted`. This occurs, if no data is available and 
	the read-operation should be tried again. 
	To avoid `IOError.WouldBlock` or `IOError.Again`, use the delegate
	to receive notifications about incoming data or use blocking I/O.
	
	- parameter maxByteCount: Maximum number of bytes to read.
	
	- returns: An array of bytes which were read as CChar (Int8)
	
	- throws: An IOError if the read operation failed.
	
	*/
	func read(_ maxByteCount: Int) throws -> [CChar]
	
	
	/**
	
	Reads data from the stream until a line break is encountered.
	
	If an error occurred, an IOError will be thrown.
	
	The thrown IOError may be `IOError.WouldBlock`, `IOError.Again`
	or `IOError.Interrupted`. This occurs, if no data is available and
	the read-operation should be tried again.
	To avoid `IOError.WouldBlock` or `IOError.Again`, use the delegate
	to receive notifications about incoming data or use blocking I/O.
	
	- returns: A string containing a single line read from the stream
	
	*/
	func readLine(_ encoding: String.Encoding) throws -> String?
	
	
	/**

	Closes the input stream and any associated ressources.
	
	Any subsequent attempts to read from this stream should fail.
	
	If the stream reads from a socket, the socket should be notified
	of this operation so it can be closed automatically if both streams
	are closed.
	
	*/
	func close()
	
}


public extension InputStream
{
	
	
	/**
	
	Reads data from the stream until a line break is encountered.
	
	If an error occurred, an IOError will be thrown.
	
	The thrown IOError may be `IOError.WouldBlock`, `IOError.Again`
	or `IOError.Interrupted`. This occurs, if no data is available and
	the read-operation should be tried again.
	To avoid `IOError.WouldBlock` or `IOError.Again`, use the delegate
	to receive notifications about incoming data or use blocking I/O.
	
	- returns: A string containing a single line read from the stream
	
	*/
	func readLine(_ encoding: String.Encoding = String.Encoding.utf8) throws -> String?
	{
		var buffer:[CChar] = []
		
		repeat
		{
			buffer += try read(1)
		}
		while buffer.isEmpty || [0x0, 0x4, 0xA, 0xD].contains(buffer.last!)
		
		buffer[buffer.count-1] = 0
		
		return String(cString: buffer, encoding: encoding)
	}
	
}


/**

Protocol for a class which supports writing to a stream
for custom network protocols.

*/
public protocol StreamReadable
{
	/**

	Initialize an object implementing this protocol by reading data
	from the given stream.
	
	- parameter stream: Stream from which the data should be read.
	
	- throws: An IOError if reading from the stream fails.
	
	*/
	init(byReadingFrom stream: InputStream) throws
}


/**

Implementation of the InputStream protocol
for reading from a POSIX-socket

*/
internal class SocketInputStreamImpl : InputStream
{
	
	/**

	The posix socket handle for network reading.
	
	*/
	fileprivate let handle: Int32
	
	
	/**

	Buffer for read operations.
	
	Reading data from the stream will fill the buffer which is then copied to
	a char-array.
	
	The buffer has a size of `bufferSize`
	
	*/
	fileprivate let buffer: UnsafeMutablePointer<CChar>
	
	
	/**

	Size of the read buffer in bytes.
	
	*/
	fileprivate let bufferSize: Int
	
	
	/**

	Pointer to the insert position of the read buffer relative
	to the read buffer start pointer.
	
	*/
	fileprivate var buffer_count: Int
	
	
	/**

	Dispatch source for event handling.
	
	Handles events of incoming data or connection updates.
	
	*/
	fileprivate let dispatch_source: DispatchSource
	
	
	/**

	Socket, from which this stream reads data.
	
	If the stream is closed, the socket will be notified of this
	and close itself, if both streams are closed.
	
	*/
	internal weak var socket: Socket?
	
	
	/**

	Specifies, if this stream is open and data can be read from it.
	
	If the stream is closed and a read operation is initiated, 
	an IOError will be thrown.
	
	*/
	internal fileprivate(set) var open:Bool = false
	
	
	/**

	The delegate of this stream will be notified
	if new data is available or the stream was closed.
	
	*/
	internal var delegate: InputStreamDelegate?
	
	
	/**

	Initializes the stream with the socket to write to,
	the POSIX-socket handle for read operations and
	the size of a buffer for read operations.
	
	The array returned from the read-function has a maximum
	length equal to the size of the read buffer.
	
	- parameter socket: The socket from which this stream reads.
	
	- parameter handle: The POSIX-socket handle for read operations.
	
	- parameter bufferSize: (Default: 4096) Buffer size in bytes
	for read operations.
	
	*/
	internal init(socket: Socket, handle: Int32, bufferSize: Int = 4096)
	{
		self.socket = socket
		self.handle = handle
		buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)
		buffer_count = 0
		self.bufferSize = bufferSize
		
		dispatch_source = DispatchSource.makeReadSource(fileDescriptor: handle, queue: DispatchQueue.global()) /*Migrator FIXME: Use DispatchSourceRead to avoid the cast*/ as! DispatchSource
		dispatch_source.setEventHandler
		{
			self.delegate?.canRead(from: self)
		}
		dispatch_source.setCancelHandler
		{
			DEBUG ?-> print("Closing input stream...")
			self.open = false
			self.buffer.deallocate(capacity: bufferSize)
			shutdown(handle, SHUT_RD)
			self.socket?.checkStreams()
			self.delegate?.didClose(self)
		}
		dispatch_source.resume()
		open = true
	}
	
	/**

	Reads from the socket.
	
	The number of elements in the returned array
	is equal to or less than the minumum of
	maxByteCount and bufferSize.
	
	If the operation fails, an IOError is thrown.
	
	The error may be .WouldBlock or .Again, which indicates
	that the read operation failed because no data is available
	and non-blocking I/O is used.
	In this case, the read operation has to be repeated.
	
	For this reason, a delegate can be used,
	which will be notified, if new data becomes available.
	
	After the delegate is notified, a call of this function
	will most likely not throw these errors.
	
	If an .Interrupted error is thrown, the operation 
	has to be tried again.
	
	If an .EndOfFile error is thrown, the end of the data
	has been reached and no more data will be available.
	Subsequent calls to this function will fail.
	The stream will automatically be closed.
	
	- parameter maxByteCount: Maximum number of bytes to read.
	
	- throws: An IOError indicating that the read operation failed.
	
	- returns: An array of chars containing the data which was read.
	
	*/
	internal func read(_ maxByteCount: Int) throws -> [CChar]
	{
		if !open
		{
			throw IOError.notConnected
		}
		
		let dataCount = Darwin.read(handle, buffer, min(bufferSize, maxByteCount))
		
		if dataCount > 0
		{
			DEBUG ?-> print("Reading \(dataCount) bytes from socket...")
			var data = [CChar](repeating: 0, count: dataCount)
			memcpy(&data, buffer, dataCount)
			DEBUG_HEXDUMP ?-> print("Read:\n\(hex(data))")
			return data
		}
		else if dataCount == 0
		{
			DEBUG ?-> print("End of file.")
			dispatch_source.cancel()
			throw IOError.endOfFile
		}
		else if errno == EWOULDBLOCK || errno == EAGAIN || errno == EINTR
		{
			throw IOError.FromCurrentErrno()
		}
		else
		{
			DEBUG ?-> print(String(cString: strerror(errno)))
			DEBUG ?-> print("Error. Closing.")
			socket?.close()
			throw IOError.FromCurrentErrno()
		}
	}
	
	
	/**

	Closes the stream manually and shuts down the socket
	so no more read calls are possible.
	
	Subsequent calls to the read-function function will fail.
	
	The delegate will be notified of this operation.
	
	*/
	internal func close()
	{
		guard open else { return }
		dispatch_source.cancel()
	}
	
	
	/**

	When deinitialized, the stream will be closed.
	
	*/
	deinit
	{
		close()
	}
	
}

/**

An input stream which wraps around a 
system stream.

*/
internal class SystemInputStream : NSObject, InputStream, StreamDelegate
{
	
	/**
	
	True, if the stream is open and data can be read.
	
	False, if the stream is closed and data cannot be read.
	Any calls to the read function will fail with an error.
	
	If the state of the stream changes, the delegate is notified
	by a call of the `didClose`-Method.
	
	*/
	var open: Bool
	
	
	/**
	
	Delegate for state change notifications.
	
	Reports, if new data is available or if the stream was closed.
	
	*/
	var delegate: InputStreamDelegate?
	
	
	/**
	
	Buffer for read operations.
	
	Reading data from the stream will fill the buffer which is then copied to
	a char-array.
	
	The buffer has a size of `bufferSize`
	
	*/
	fileprivate let buffer: UnsafeMutableRawPointer
	
	
	/**
	
	Size of the read buffer in bytes.
	
	*/
	fileprivate let bufferSize: Int
	
	
	/**
	
	Pointer to the insert position of the read buffer relative
	to the read buffer start pointer.
	
	*/
	fileprivate var buffer_count: Int
	
	
	/**
	
	Socket, from which this stream reads data.
	
	If the stream is closed, the socket will be notified of this
	and close itself, if both streams are closed.
	
	*/
	internal unowned var socket: Socket
	
	
	fileprivate let underlyingStream: Foundation.InputStream
	
	init(underlyingStream: Foundation.InputStream, socket: Socket, bufferSize: Int = 4096)
	{
		open = true
		self.underlyingStream = underlyingStream
		self.socket = socket
		buffer = UnsafeMutableRawPointer.allocate(bytes: bufferSize, alignedTo: MemoryLayout<UInt8>.alignment)
		self.bufferSize = bufferSize
		buffer_count = 0
		
		super.init()
		
		underlyingStream.delegate = self
	}
	
	
	/**
	
	Read data from the stream.
	
	The length of the returned array has a maximum length of `maxByteCount`.
	
	If an error occurred, an IOError will be thrown.
	
	The thrown IOError may be `IOError.WouldBlock`, `IOError.Again`
	or `IOError.Interrupted`. This occurs, if no data is available and
	the read-operation should be tried again.
	To avoid `IOError.WouldBlock` or `IOError.Again`, use the delegate
	to receive notifications about incoming data or use blocking I/O.
	
	- parameter maxByteCount: Maximum number of bytes to read.
	
	- returns: An array of bytes which were read as CChar (Int8)
	
	- throws: An IOError if the read operation failed.
	
	*/
	func read(_ maxByteCount: Int) throws -> [CChar]
	{
		if !open
		{
			throw IOError.notConnected
		}
		let dataCount = underlyingStream.read(buffer.assumingMemoryBound(to: UInt8.self), maxLength: bufferSize)
		if dataCount > 0
		{
			DEBUG ?-> print("Reading \(dataCount) bytes from socket...")
			var data = [CChar](repeating: 0, count: dataCount)
			memcpy(&data, buffer, dataCount)
			DEBUG_HEXDUMP ?-> print("Read:\n\(hex(data))")
			return data
		}
		else if dataCount == 0
		{
			DEBUG ?-> print("End of file.")
			throw IOError.endOfFile
		}
		else if let error = underlyingStream.streamError
		{
			close()
			throw error
		}
		else
		{
			throw IOError.unknown
		}
	}
	
	
	/**
	
	Closes the stream manually and shuts down the socket
	so no more read calls are possible.
	
	Subsequent calls to the read-function function will fail.
	
	The delegate will be notified of this operation.
	
	*/
	func close()
	{
		underlyingStream.close()
	}
	
	@objc func stream(_ aStream: Stream, handle eventCode: Stream.Event)
	{
		guard aStream === underlyingStream else { return }
		
		switch eventCode
		{
		case Stream.Event.hasBytesAvailable:
			delegate?.canRead(from: self)
			break
		case Stream.Event.errorOccurred:
			delegate?.didClose(self)
			break
		default:
			break
		}
	}
	
}

