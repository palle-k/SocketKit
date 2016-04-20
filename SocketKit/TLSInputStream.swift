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


/**

Info object associated with a SSLContext.

This type can be used as a SSLConnection
so the streams can be retrieved from the 
SSLRead and SSLWrite functions as these are
CFunctionPointers which do not allow for context
to be passed from outside.

*/
internal struct TLSConnectionInfo
{
	
	/**

	The underlying input stream of a TLS connection.
	
	The encrpyted data will be read from this stream.
	
	*/
	let inputStream: TLSInputStream
	
	
	/**

	The underlying output stream of a TLS connection.
	
	The encrypted data will be written to this stream.
	
	*/
	let outputStream: TLSOutputStream
}


/**

An input stream which is encrypted using the
TLS/SSL protocol.

The input stream uses an underlying input stream to 
read the encrypted data, which is then decrypted.

The decrypted data can then be read from this stream.

*/
public class TLSInputStream : InputStream, InputStreamDelegate
{
	
	/**

	Creates a TLS/SSL session for the provided streams.
	
	This currently works for server side only.
	
	The provided Certificates are used for encryption.
	
	When creating an encrypted stream pair, a handshake will automatically be performed.
	If the handshake fails, a TLSError will be thrown.
	
	- parameter inputStream: Input stream which should be used as an underlying stream to the TLS/SSL input stream.
	Reads the encrypted data.
	
	- parameter outputStream: Output stream which should be used as an underlying stream to the TLS/SSL output stream.
	The encrypted data will be written to it.
	
	- parameter certificates: Array of certificates for encryption. The first certificate has to contain a private key used for
	decryption. A private key will automatically be included if the certificate is loaded from a PKCS12-file.
	
	- throws: A TLSError indicating that the TLS/SSL session could not be created.
	
	- returns: An encrypted input and output stream.
	
	*/
	public class func CreateStreamPair(fromInputStream inputStream: InputStream, outputStream: OutputStream, certificates: [Certificate]) throws -> (inputStream: TLSInputStream, outputStream: TLSOutputStream)
	{
		
		//FIXME: Make this available for client side.
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
		
		
		//FIXME: Allow changing this peer name.
		let peername = "localhost.daplie.com"
		
		DEBUG ?-> print("Setting peer name to \(peername)...")
		let domainStatus = SSLSetPeerDomainName(context, peername, peername.characters.count)
		DEBUG ?-> print("Resulting status: \(domainStatus)")
		
		//FIXME: Allow no certificate, if the client side is used.
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
	
	
	/**

	Underlying stream of the encrypted stream.
	
	Reads data from a source which was TLS/SSL encrypted.
	The data read from this stream will be decrypted and can be read
	from the TLSInputStream.
	
	*/
	public let underlyingStream: InputStream
	
	
	/**

	Context of the TLS/SSL connection.
	
	The TLS/SSL session context object references the state associated with a session.
	
	*/
	private let context:SSLContext
	
	
	/**

	The encrypted output stream.
	
	The input and output stream require each other
	to work so if one stream is closed, the other will also be closed.
	
	*/
	internal weak var outputStream: TLSOutputStream?
	
	
	/**

	A buffer for reading the decrypted data.
	
	*/
	private var buffer:UnsafeMutablePointer<CChar>
	
	
	/**

	The size of the read buffer
	
	*/
	private var bufferSize:Int
	
	
	/**

	The TLS connection info object which is used in the read
	and write functions to reference the streams as COpaquePointers
	don't allow for context to be passed directly into the c-function.
	
	*/
	private var connection:UnsafeMutablePointer<TLSConnectionInfo>?
	
	
	/**
	
	The delegate of this stream will be notified
	if new data is available or the stream was closed.
	
	*/
	public var delegate: InputStreamDelegate?
	
	
	/**

	Initializes an encrypted input stream with a stream to read from,
	a TLS/SSL context which stores the connection state and a buffer size for a input
	read buffer, which has a default size of 4096 bytes.
	
	- parameter stream: Input stream to read from.
	
	- parameter context: The TLS/SSL context.
	
	- parameter bufferSize: The size of the read buffer in bytes. Default: 4KiB.
	
	*/
	internal init(withStream stream: InputStream, context: SSLContext, bufferSize:Int = 4096)
	{
		self.underlyingStream = stream
		self.context = context
		buffer = UnsafeMutablePointer<CChar>.alloc(bufferSize)
		self.bufferSize = bufferSize
	}
	
	
	/**

	Specifies, if this stream is open and data can be read from it.
	
	If the stream is closed and a read operation is initiated,
	an IOError will be thrown.
	
	*/
	public var open: Bool
	{
		return self.underlyingStream.open
	}
	
	
	/**

	Reads encrypted data and decrypts it.
	
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
	public func read(maxByteCount: Int) throws -> [CChar]
	{
		var buffer_count = 0
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
	
	
	/**
	
	Closes the stream manually and shuts down the underlying stream
	so no more read calls are possible.
	
	Subsequent calls to the read-function function will fail.
	
	The delegate will be notified of this operation.
	
	This operation also closes the underlying stream.
	
	*/
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
	
	
	/**

	Reads data from the encrypted stream and passes it to the TLS/SSL
	context for decryption.
	
	- parameter connection: Connection info
	
	- parameter data: Pointer to the data which will be read
	
	- parameter length: Pointer to the number of bytes which should
	maximally be read. After reading, the value in memory should indicate
	how many bytes were read.
	
	- returns: Result code of the read function. 
	If no error occurred, noErr will be returned.
	
	*/
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
	
	
	/**

	The stream will be closed when it is deallocated.
	
	*/
	deinit
	{
		close()
	}
	
	
	/**

	Delegate methods for the underlying stream
	
	Notifies the stream about new data which is available
	in the underlying stream.
	
	**Warning:** This method should not be called manually,
	it will automatically be called by the underlying stream.
	
	If another stream than the underlying stream is passed to this method,
	the call will be ignored.
	
	- parameter inputStream: The input stream which has new data available.
	
	*/
	public func canRead(fromStream inputStream: InputStream)
	{
		if inputStream === underlyingStream
		{
			delegate?.canRead(fromStream: self)
		}
	}
	
	
	/**
	
	Delegate methods for the underlying stream
	
	Notifies the stream that the underlying stream was closed.
	
	**Warning:** This method should not be called manually,
	it will automatically be called by the underlying stream.
	
	If another stream than the underlying stream is passed to this method,
	the call will be ignored.
	
	- parameter inputStream: The input stream which has new data available.
	
	*/
	public func didClose(inputStream: InputStream)
	{
		if inputStream === underlyingStream
		{
			self.close()
		}
	}
}
