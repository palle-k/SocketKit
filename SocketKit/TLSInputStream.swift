//
//  TLSInputStream.swift
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

internal struct TLSConnectionInfo
{
	let inputStream: TLSInputStream
	let outputStream: TLSOutputStream
}

public class TLSInputStream : InputStream, InputStreamDelegate
{
	public class func CreateStreamPair(fromInputStream inputStream: InputStream, outputStream: OutputStream, certificates: [Certificate]) throws -> (inputStream: TLSInputStream, outputStream: TLSOutputStream)
	{
		guard let context = SSLCreateContext(kCFAllocatorMalloc, .ServerSide, .StreamType)
			else
		{
			throw TLSError.SessionNotCreated
		}
		
		DEBUG ?-> print("Creating TLS encrypted stream pair...")
		
		let tlsInputStream = TLSInputStream(withStream: inputStream, context: context)
		let tlsOutputStream = TLSOutputStream(withStream: outputStream, context: context)
		
		tlsInputStream.outputStream = tlsOutputStream
		tlsOutputStream.inputStream = tlsInputStream
		
		let info = TLSConnectionInfo(inputStream: tlsInputStream, outputStream: tlsOutputStream)
		let ptr = UnsafeMutablePointer<TLSConnectionInfo>.alloc(sizeof(TLSConnectionInfo))
		ptr.initialize(info)
		SSLSetConnection(context, ptr)
		tlsInputStream.connection = ptr
		
		SSLSetIOFuncs(context,
		{ (connection, data, length) -> OSStatus in
			
			let ptr = UnsafePointer<TLSConnectionInfo>(connection)
			let info = ptr.memory
			return info.inputStream.readFunc(connection, data: data, length: length)
		},
		{ (connection, data, length) -> OSStatus in
			let ptr = UnsafePointer<TLSConnectionInfo>(connection)
			let info = ptr.memory
			return info.outputStream.writeFunc(connection, data: data, length: length)
		})
		
		let peername = "localhost.daplie.com"
		
		DEBUG ?-> print("Setting peer name to \(peername)...")
		let domainStatus = SSLSetPeerDomainName(context, peername, peername.characters.count)
		DEBUG ?-> print("Resulting status: \(domainStatus)")
		
		DEBUG ?-> print("Setting certificate...")
		let certificateState = SSLSetCertificate(context, certificates.map{$0.identity})
		DEBUG ?-> print("Resulting status: \(certificateState)")
		
		DEBUG ?-> print("Beginning handshake...")
		
		var handshakeResult:OSStatus = noErr
		repeat
		{
			handshakeResult = SSLHandshake(context)
		}
		while handshakeResult == errSSLWouldBlock
		
		if handshakeResult != noErr
		{
			DEBUG ?-> print("Handshake failed. Code: \(handshakeResult)")
			throw TLSError.HandshakeFailed
		}
		
		inputStream.delegate = tlsInputStream
		
		DEBUG ?-> print("Handshake succeeded.")
		
		return (inputStream: tlsInputStream, outputStream: tlsOutputStream)
	}
	
	public let underlyingStream: InputStream
	private let context:SSLContext
	internal weak var outputStream: TLSOutputStream?
	private var buffer:UnsafeMutablePointer<CChar>
	private var bufferSize:Int
	private var buffer_count:Int
	private var connection:UnsafeMutablePointer<TLSConnectionInfo>?
	
	public var delegate: InputStreamDelegate?
	
	internal init(withStream stream: InputStream, context: SSLContext, bufferSize:Int = 2048)
	{
		self.underlyingStream = stream
		self.context = context
		buffer = UnsafeMutablePointer<CChar>.alloc(bufferSize)
		self.bufferSize = bufferSize
		buffer_count = 0
	}
	
	public var open: Bool
	{
		return self.underlyingStream.open
	}
	
	public func read(maxByteCount: Int) throws -> [CChar]
	{
		let result = SSLRead(context, buffer, min(bufferSize, maxByteCount), &buffer_count)
		guard result == 0
			else
		{
			print("TLS-ERROR: Read result not zero")
			//TODO: Error handling
			return []
		}
		var data = Array<CChar>(count: buffer_count, repeatedValue: 0)
		memcpy(&data, buffer, buffer_count)
		return data
	}
	
	public func close()
	{
		if !open
		{
			return
		}
		SSLClose(context)
		connection?.dealloc(sizeof(TLSConnectionInfo))
		self.underlyingStream.close()
	}
	
	private func readFunc(connection: SSLConnectionRef, data: UnsafeMutablePointer<Void>, length: UnsafeMutablePointer<Int>) -> OSStatus
	{
		do
		{
			DEBUG ?-> print("SSL - read maximum: \(length.memory) bytes")
			var readData = try underlyingStream.read(length.memory)
			length.memory = readData.count
			DEBUG ?-> print("SSL - read: \(length.memory) bytes")
			//DEBUG_HEXDUMP ?-> print("SSL - read: \(hex(readData))")
			memcpy(data, &readData, readData.count)
		}
		catch
		{
			switch error
			{
			case IOError.WouldBlock, IOError.Again, IOError.Interrupted:
				return errSSLWouldBlock
			case IOError.EndOfFile:
				return errSSLClosedGraceful
			case IOError.BrokenPipe, IOError.BadMessage, IOError.ConnectionReset, IOError.TimedOut:
				return errSSLClosedAbort
			default:
				return errSSLInternal
			}
		}
		return noErr
	}
	
	deinit
	{
		close()
	}
	
	public func canRead(fromStream inputStream: InputStream)
	{
		if inputStream === underlyingStream
		{
			delegate?.canRead(fromStream: self)
		}
	}
	
	public func didClose(inputStream: InputStream)
	{
		if inputStream === underlyingStream
		{
			self.close()
		}
	}
}
