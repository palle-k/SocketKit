//
//  TLSOutputStream.swift
//  SocketKit
//
//  Created by Palle Klewitz on 15.04.16.
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

import Foundation
import Security

public class TLSOutputStream : OutputStream
{
	public class func CreateStreamPair(fromInputStream inputStream: InputStream, outputStream: OutputStream, certificates: [Certificate]) throws -> (inputStream: TLSInputStream, outputStream: TLSOutputStream)
	{
		return try TLSInputStream.CreateStreamPair(fromInputStream: inputStream, outputStream: outputStream, certificates: certificates)
	}
	
	public let underlyingStream: OutputStream
	internal let context: SSLContext
	internal weak var inputStream: TLSInputStream?
	private var error:ErrorType?
	
	public var open: Bool
	{
		return self.underlyingStream.open
	}
	
	internal init(withStream stream: OutputStream, context: SSLContext)
	{
		self.underlyingStream = stream
		self.context = context
	}
	
	public func write(data: UnsafePointer<Void>, lengthInBytes byteCount: Int) throws
	{
		var processed = 0
		while processed < byteCount
		{
			let ptr = data.advancedBy(processed)
			var written = 0
			let status = SSLWrite(context, ptr, byteCount - processed, &written)
			
			DEBUG ?-> print("SSL - write: \(written) bytes written. Processed: \(processed). Total: \(byteCount), Status: \(status)")
			
			guard status == 0
				else
			{
				if status == errSSLWouldBlock
				{
					continue
				}
				else if let error = error
				{
					throw error
					self.error = nil
				}
				else
				{
					throw IOError.Unknown
				}
			}
			processed += max(written, 0)
		}
	}
	
	public func close()
	{
		self.inputStream?.close()
		self.underlyingStream.close()
	}
	
	internal func writeFunc(connection: SSLConnectionRef, data: UnsafePointer<Void>, length: UnsafeMutablePointer<Int>) -> OSStatus
	{
		do
		{
			DEBUG ?-> print("SSL - write: \(length.memory) bytes")
			//DEBUG_HEXDUMP ?-> print("SSL - write: \(hex(data, length: length.memory))")
			try underlyingStream.write(data, lengthInBytes: length.memory)
			return noErr
		}
		catch
		{
			self.error = error
			DEBUG ?-> print("SSL - write: Error - \(error)")
			switch error
			{
			case IOError.WouldBlock, IOError.Again, IOError.Interrupted:
				return errSSLWouldBlock
			default:
				return errSSLInternal
			}
		}
	}
	
	public func flush() throws
	{
		try underlyingStream.flush()
	}
	
	deinit
	{
		close()
	}
}

