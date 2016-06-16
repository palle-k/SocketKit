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
	@available(*, deprecated=0.1, message="TLSOutputStream.CreateStreamPair has been deprecated. Use TLSCreateStreamPair(...) instead.")
	public class func CreateStreamPair(fromInputStream inputStream: InputStream, outputStream: OutputStream, certificates: [Certificate]) throws -> (inputStream: TLSInputStream, outputStream: TLSOutputStream)
	{
		return try TLSCreateStreamPair(fromInputStream: inputStream, outputStream: outputStream, certificates: certificates)
	}
	
	
	/**
	
	Underlying stream of the encrypted stream.
	
	Writes data to a source which is TLS/SSL encrypted.
	
	Data written to the TLSOutputStream will be encrypted
	and written to this underlying stream.
	
	*/
	public let underlyingStream: OutputStream
	
	
	/**
	
	Context of the TLS/SSL connection.
	
	The TLS/SSL session context object references the state associated with a session.
	
	*/
	internal let context: SSLContext
	
	
	/**
	
	The encrypted input stream.
	
	The input and output stream require each other
	to work so if one stream is closed, the other will also be closed.
	
	*/
	internal weak var inputStream: TLSInputStream?
	
	
	/**
	
	Specifies, if this stream is open and data can be written to it.
	
	If the stream is closed and a write operation is initiated,
	an IOError will be thrown.
	
	*/
	public var open: Bool
	{
		return self.underlyingStream.open
	}
	
	
	/**
	
	Initializes an encrypted output stream with a stream to write to
	and a TLS/SSL context which stores the connection state.
	read buffer, which has a default size of 4096 bytes.
	
	- parameter stream: Output stream to write to.
	
	- parameter context: The TLS/SSL context.
	
	*/
	internal init(withStream stream: OutputStream, context: SSLContext)
	{
		self.underlyingStream = stream
		self.context = context
	}
	
	
	/**

	Encrypts the provided data and writes it to the underlying stream.
	
	If the operation fails, an IOError is thrown.
	
	If an .Interrupted error is thrown, the operation
	has to be tried again.
	
	- parameter data: Data which should be encrypted and written to the stream.
	
	- parameter byteCount: Number of bytes to encrypt and write.
	
	*/
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
				else
				{
					throw IOError.FromSSlError(status)
				}
			}
			processed += max(written, 0)
		}
	}
	
	
	/**
	
	Closes the stream manually and shuts down the underlying stream
	so no more write calls are possible.
	
	Subsequent calls to the write-function function will fail.
	
	This operation also closes the underlying stream.
	
	*/
	public func close()
	{
		self.inputStream?.close()
		self.underlyingStream.close()
	}
	
	
	/**

	Writes encrypted data to the underlying stream.
	
	- parameter connection: Connection info
	
	- parameter data: Pointer to the data which should be written.
	
	- parameter length: Pointer to the number of bytes which should
	maximally be written. After reading, the value in memory should indicate
	how many bytes were written.
	
	- returns: Result code of the read function.
	If no error occurred, noErr will be returned.
	
	*/
	internal func writeFunc(connection: SSLConnectionRef, data: UnsafePointer<Void>, length: UnsafeMutablePointer<Int>) -> OSStatus
	{
		do
		{
			DEBUG ?-> print("SSL - write: \(length.memory) bytes")
			try underlyingStream.write(data, lengthInBytes: length.memory)
			return noErr
		}
		catch
		{
			let error = error as? IOError
			DEBUG ?-> print("SSL - write: Error - \(error)")
			return error?.sslError ?? errSSLInternal
		}
	}
	
	
	/**
	
	The stream will be closed when it is deallocated.
	
	*/
	deinit
	{
		close()
	}
}

