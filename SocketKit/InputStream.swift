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

//TODO: rewrite in parts:
//New initializer: Init with Socket
//New InputStreams: Non-blocking, delegate based: read function does not block, delegate notified, when new data available
//Secure Streams:
//Init directly with socket using non-blocking I/O

public protocol InputStreamDelegate
{
	func canRead(fromStream inputStream: InputStream)
	func didClose(inputStream: InputStream)
}

public protocol InputStream : class
{
	var open:Bool { get }
	var delegate: InputStreamDelegate? { get set }
	func read(maxByteCount: Int) throws -> [CChar]
	func close()
}

public protocol StreamReadable
{
	init(byReadingFromStream stream: InputStream)
}

internal class SocketInputStreamImpl : InputStream
{
	private let handle: Int32
	private let buffer: UnsafeMutablePointer<CChar>
	private let bufferSize: Int
	private var buffer_count: Int
	private let dispatch_source: dispatch_source_t
	private let readSemaphore: dispatch_semaphore_t
	private let handleSemaphore: dispatch_semaphore_t
	private var error:IOError?
	internal weak var socket: Socket?
	
	internal private(set) var open:Bool = false
	
	internal var delegate: InputStreamDelegate?
	
	internal init(socket: Socket, handle: Int32, bufferSize: Int = 4096)
	{
		self.socket = socket
		self.handle = handle
		buffer = UnsafeMutablePointer<CChar>.alloc(bufferSize)
		buffer_count = 0
		self.bufferSize = bufferSize
		
		readSemaphore = dispatch_semaphore_create(0)
		handleSemaphore = dispatch_semaphore_create(0)
		dispatch_source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, UInt(handle), 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
		dispatch_source_set_event_handler(dispatch_source, hasDataAvailable)
		dispatch_source_set_cancel_handler(dispatch_source)
		{
			DEBUG ?-> print("Closing input stream...")
			self.open = false
			self.buffer.dealloc(bufferSize)
			dispatch_semaphore_signal(self.readSemaphore)
			dispatch_semaphore_signal(self.handleSemaphore)
			shutdown(handle, SHUT_RD)
			self.socket?.checkStreams()
		}
		dispatch_resume(dispatch_source)
		open = true
	}
	
	internal func read(maxByteCount: Int) throws -> [CChar]
	{
		if !open
		{
			throw IOError.NotConnected
		}
		
		let dataCount = Darwin.read(handle, buffer, min(bufferSize, maxByteCount))
		
		if dataCount > 0
		{
			DEBUG ?-> print("Reading \(dataCount) bytes from socket...")
			var data = [CChar](count: dataCount, repeatedValue: 0)
			memcpy(&data, buffer, dataCount)
			DEBUG_HEXDUMP ?-> print("Read:\n\(hex(data))")
			return data
		}
		else if dataCount == 0
		{
			DEBUG ?-> print("End of file.")
			dispatch_source_cancel(dispatch_source)
			throw IOError.EndOfFile
		}
		else if errno == EWOULDBLOCK || errno == EAGAIN || errno == EINTR
		{
			throw IOError.FromCurrentErrno()
		}
		else
		{
			DEBUG ?-> print(String.fromCString(strerror(errno)))
			DEBUG ?-> print("Error. Closing.")
			dispatch_source_cancel(dispatch_source)
			throw IOError.FromCurrentErrno()
		}
		
//		if let error = self.error
//		{
//			self.error = nil
//			print("Signal: handle (woken? \(dispatch_semaphore_signal(handleSemaphore) == 0 ? "no" : "yes"))")
//			//dispatch_semaphore_signal(handleSemaphore)
//			throw error
//		}
//		//if buffer_count == 0
//		//{
//		print("Lock: read")
//		dispatch_semaphore_wait(readSemaphore, DISPATCH_TIME_FOREVER)
//		print("Unlocked: read")
//		//}
//		if let error = self.error
//		{
//			self.error = nil
//			dispatch_semaphore_signal(handleSemaphore)
//			throw error
//		}
//		var output = Array<CChar>(count: buffer_count, repeatedValue: 0)
//		memcpy(&output, buffer, buffer_count)
//		
//		buffer_count = 0
//		print("Signal: handle (woken? \(dispatch_semaphore_signal(handleSemaphore) == 0 ? "no" : "yes"))")
//		//dispatch_semaphore_signal(handleSemaphore)
//		
//		DEBUG_HEXDUMP ?-> print("Read:\n\(hex(output))")
//		
//		return output
		//return []
	}
	
	private func hasDataAvailable()
	{
//		if bufferSize - buffer_count <= 0
//		{
//			print("Lock: handle")
//			dispatch_semaphore_wait(handleSemaphore, DISPATCH_TIME_FOREVER)
//			print("Unlocked: handle")
//		}
//		let count = Darwin.read(handle, buffer.advancedBy(buffer_count), bufferSize - buffer_count)
//		if count > 0
//		{
//			buffer_count += count
//			DEBUG ?-> print("Reading \(count) bytes from socket...")
//		}
//		else if count == 0
//		{
//			error = IOError.EndOfFile
//			DEBUG ?-> print("End of file.")
//			dispatch_source_cancel(dispatch_source)
//			dispatch_semaphore_signal(readSemaphore)
//			return
//		}
//		else if errno != EWOULDBLOCK && errno != EAGAIN && errno != EINTR
//		{
//			DEBUG ?-> print(strerror(errno))
//			error = IOError.FromCurrentErrno()
//			
//			DEBUG ?-> print("Error. Closing.")
//			dispatch_source_cancel(dispatch_source)
//			dispatch_semaphore_signal(readSemaphore)
//			return
//		}
//		print("Signal: read (woken? \(dispatch_semaphore_signal(readSemaphore) == 0 ? "no" : "yes"))")
//		//dispatch_semaphore_signal(readSemaphore)
		
		delegate?.canRead(fromStream: self)
	}
	
	internal func close()
	{
		guard open else { return }
		dispatch_source_cancel(dispatch_source)
	}
	
	deinit
	{
		close()
	}
	
}
