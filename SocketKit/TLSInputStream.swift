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

An input stream which is encrypted using the
TLS/SSL protocol.

The input stream uses an underlying input stream to 
read the encrypted data, which is then decrypted.

The decrypted data can then be read from this stream.

*/
open class TLSInputStream : InputStream, InputStreamDelegate
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
	@available(*, deprecated: 0.1, message: "TLSInputStream.CreateStreamPair has been deprecated. Use TLSCreateStreamPair(...) instead.")
	open class func CreateStreamPair(fromInputStream inputStream: InputStream, outputStream: OutputStream, certificates: [Certificate]) throws -> (inputStream: TLSInputStream, outputStream: TLSOutputStream)
	{
		return try TLSCreateStreamPair(fromInputStream: inputStream, outputStream: outputStream, certificates: certificates)
	}
	
	
	/**

	Underlying stream of the encrypted stream.
	
	Reads data from a source which was TLS/SSL encrypted.
	The data read from this stream will be decrypted and can be read
	from the TLSInputStream.
	
	*/
	open let underlyingStream: InputStream
	
	
	/**

	Context of the TLS/SSL connection.
	
	The TLS/SSL session context object references the state associated with a session.
	
	*/
	internal let context:SSLContext
	
	
	/**

	The encrypted output stream.
	
	The input and output stream require each other
	to work so if one stream is closed, the other will also be closed.
	
	*/
	internal weak var outputStream: TLSOutputStream?
	
	
	/**

	A buffer for reading the decrypted data.
	
	*/
	fileprivate var buffer:UnsafeMutablePointer<CChar>
	
	
	/**

	The size of the read buffer
	
	*/
	fileprivate var bufferSize:Int
	
	
	/**

	The TLS connection info object which is used in the read
	and write functions to reference the streams as COpaquePointers
	don't allow for context to be passed directly into the c-function.
	
	*/
	internal var connection:UnsafeMutablePointer<TLSConnectionInfo>?
	
	
	/**
	
	The delegate of this stream will be notified
	if new data is available or the stream was closed.
	
	*/
	open var delegate: InputStreamDelegate?
	
	
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
		buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferSize)
		self.bufferSize = bufferSize
	}
	
	
	/**

	Specifies, if this stream is open and data can be read from it.
	
	If the stream is closed and a read operation is initiated,
	an IOError will be thrown.
	
	*/
	open var open: Bool
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
	open func read(_ maxByteCount: Int) throws -> [CChar]
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
		var data = Array<CChar>(repeating: 0, count: buffer_count)
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
	open func close()
	{
		if !open
		{
			return
		}
		SSLClose(context)
		connection?.deallocate(capacity: MemoryLayout<TLSConnectionInfo>.size)
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
	internal func readFunc(_ connection: SSLConnectionRef, data: UnsafeMutableRawPointer, length: UnsafeMutablePointer<Int>) -> OSStatus
	{
		do
		{
			DEBUG ?-> print("SSL - read maximum: \(length.pointee) bytes")
			var readData = try underlyingStream.read(length.pointee)
			length.pointee = readData.count
			DEBUG ?-> print("SSL - read: \(length.pointee) bytes")
			memcpy(data, &readData, readData.count)
		}
		catch
		{
			switch error
			{
			case IOError.wouldBlock, IOError.again, IOError.interrupted:
				return errSSLWouldBlock
			case IOError.endOfFile:
				return errSSLClosedGraceful
			case IOError.brokenPipe, IOError.badMessage, IOError.connectionReset, IOError.timedOut:
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
	open func canRead(from inputStream: InputStream)
	{
		if inputStream === underlyingStream
		{
			delegate?.canRead(from: self)
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
	open func didClose(_ inputStream: InputStream)
	{
		if inputStream === underlyingStream
		{
			self.close()
		}
	}
}
