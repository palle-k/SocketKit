//
//  TLSUtil.swift
//  SocketKit
//
//  Created by Palle Klewitz on 15.06.16.
//  Copyright © 2016 Palle Klewitz. All rights reserved.
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
public func TLSCreateStreamPair(fromInputStream inputStream: InputStream, outputStream: OutputStream, certificates: [Certificate]) throws -> (inputStream: TLSInputStream, outputStream: TLSOutputStream)
{
	
	//FIXME: Make this available for client side.
	guard let context = SSLCreateContext(kCFAllocatorMalloc, .serverSide, .streamType)
		else
	{
		throw TLSError.sessionNotCreated
	}
	
	DEBUG ?-> print("Creating TLS encrypted stream pair...")
	
	let tlsInputStream = TLSInputStream(withStream: inputStream, context: context)
	let tlsOutputStream = TLSOutputStream(withStream: outputStream, context: context)
	
	tlsInputStream.outputStream = tlsOutputStream
	tlsOutputStream.inputStream = tlsInputStream
	
	let info = TLSConnectionInfo(inputStream: tlsInputStream, outputStream: tlsOutputStream)
	let ptr = UnsafeMutablePointer<TLSConnectionInfo>.allocate(capacity: MemoryLayout<TLSConnectionInfo>.size)
	ptr.initialize(to: info)
	SSLSetConnection(context, ptr)
	tlsInputStream.connection = ptr
	
	SSLSetIOFuncs(context,
	{ (connection, data, length) -> OSStatus in
		let info = connection.assumingMemoryBound(to: TLSConnectionInfo.self).pointee
		return info.inputStream.readFunc(connection, data: data, length: length)
	},
	{ (connection, data, length) -> OSStatus in
		let info = connection.assumingMemoryBound(to: TLSConnectionInfo.self).pointee
		return info.outputStream.writeFunc(connection, data: data, length: length)
	})
	
	
	//FIXME: Allow changing this peer name.
	//This hostname was chosen as valid TLS certificates are publicly available.
	let peername = "localhost.daplie.com"
	
	DEBUG ?-> print("Setting peer name to \(peername)...")
	let domainStatus = SSLSetPeerDomainName(context, peername, peername.characters.count)
	DEBUG ?-> print("Resulting status: \(domainStatus)")
	
	//FIXME: Allow no certificate, if the client side is used.
	DEBUG ?-> print("Setting certificate...")
	let certificateState = SSLSetCertificate(context, certificates.map{$0.identity} as CFArray)
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
		throw TLSError.handshakeFailed
	}
	
	inputStream.delegate = tlsInputStream
	
	DEBUG ?-> print("Handshake succeeded.")
	
	return (inputStream: tlsInputStream, outputStream: tlsOutputStream)
}
