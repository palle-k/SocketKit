//
//  Certificates.swift
//  SocketKit
//
//  Created by Palle Klewitz on 14.04.16.
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
import Foundation
import Security

/**

Certificate for TLS/SSL encrypted connections

A certificate can be loaded from a PKCS12-file
or directly as a SecIdentityRef.

*/
public struct Certificate : Equatable
{
	/**
	
	Identity containing the certificate sent to the client
	and the private key for decryption
	
	*/
	internal let identity:SecIdentity
	
	
	/**

	Hostname, which should be used.

	*/
	public let hostname:String
	
	/**

	Initialize a new certificate with the given data protected by the given password.
	The data has to be in PKCS12 format.
	
	If the certificate cannot be loaded, a TLSError is thrown.
	For further information, activate the -skdebug flag, which prints further error messages.
	
	- parameter data: Data object containing the PKCS12 certificate and key
	
	- parameter password: Password protecting the the specified PKCS12 certificate.
	If no password should be used, the password should be nil.
	
	- throws: A TLSError indicating that the certificate could not be loaded.
	
	*/
	public init(with data:Data, password:String? = nil, hostname:String = Host.current().name ?? "localhost") throws
	{
		let options = [String(kSecImportExportPassphrase) : (password ?? "")]
		var array:CFArray? = nil
		let status = SecPKCS12Import(data as CFData, options as CFDictionary, &array)
		
		guard status == errSecSuccess
		else
		{
			DEBUG ?-> print("Import failed. Reason: \(status)")
			throw TLSError.importFailed
		}
		
		guard let identities = array as Array<AnyObject>?
		else
		{
			DEBUG ?-> print("Identities not loaded")
			throw TLSError.importFailed
		}
		
		DEBUG ?-> identities.forEach { print($0) }
		
		guard let dict = identities.first as? NSDictionary
		else
		{
			DEBUG ?-> print("Identities empty or not dictionary")
			throw TLSError.importFailed
		}
		
		guard let identity = dict[kSecImportItemIdentity as String] as! SecIdentity?
		else
		{
			DEBUG ?-> print("Identity could not be casted or does not exist")
			throw TLSError.importFailed
		}
		
		self.identity = identity
		self.hostname = hostname
	}
	
	
	/**

	Creates a new certificate with the specified SecIdentityRef.
	
	- parameter identity: Identity containing the certificate and private key to use
	
	*/
	public init(with identity: SecIdentity, hostname:String = Host.current().name ?? "localhost")
	{
		self.identity = identity
		self.hostname = hostname
	}
	
	
	/**
	
	Initialize a new certificate with the data at the given path protected by the given password.
	The data has to be in PKCS12 format.
	
	If the certificate cannot be loaded, a TLSError is thrown.
	For further information, activate the -skdebug flag, which prints further error messages.
	
	- parameter filePath: Path to file containing the PKCS12 certificate and key
	
	- parameter password: Password protecting the the specified PKCS12 certificate
	If no password should be used, the password should be nil.
	
	- throws: A TLSError indicating that the certificate could not be loaded.
	
	*/
	public init(contentsOf filePath: String, password: String? = nil, hostname: String = Host.current().name ?? "localhost") throws
	{
		guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath))
		else
		{
			DEBUG ?-> print("Data could not be loaded.")
			throw TLSError.dataNotAccessible
		}
		try self.init(with: data, password: password, hostname: hostname)
	}
	
	
	/**
	
	Initialize a new certificate with the data at the given path protected by the given password.
	The data has to be in PKCS12 format.
	
	If the certificate cannot be loaded, a TLSError is thrown.
	For further information, activate the -skdebug flag, which prints further error messages.
	
	- parameter filePath: Path to file containing the PKCS12 certificate and key
	
	- parameter readingOptions: Options for reading
	
	- parameter password: Password protecting the the specified PKCS12 certificate
	If no password should be used, the password should be nil.
	
	- throws: A TLSError indicating that the certificate could not be loaded.
	
	*/
	public init(contentsOf filePath: String, readingOptions: NSData.ReadingOptions, password: String? = nil, hostname: String = Host.current().name ?? "localhost") throws
	{
		let data = try Data(contentsOf: URL(fileURLWithPath: filePath), options: readingOptions)
		try self.init(with: data, password: password, hostname: hostname)
	}
}


/**

Compares the two certificates.

If both certificates are equal, true is returned.
If not, false is returned.

The comparison is based on the private keys of

- parameter left: First certificate for comparison

- parameter right: Second certificate for comparison

- returns: A boolean indicating if the two certificates are equal.

*/
public func == (left: Certificate, right: Certificate) -> Bool
{
	let leftKeyPtr = UnsafeMutablePointer<SecKey?>.allocate(capacity: MemoryLayout<SecKey>.size)
	let rightKeyPtr = UnsafeMutablePointer<SecKey?>.allocate(capacity: MemoryLayout<SecKey>.size)
	
	SecIdentityCopyPrivateKey(left.identity, leftKeyPtr)
	SecIdentityCopyPrivateKey(right.identity, rightKeyPtr)
	
	let result = memcmp(leftKeyPtr, rightKeyPtr, MemoryLayout<SecKey>.size) > 0
	leftKeyPtr.deallocate(capacity: MemoryLayout<SecKey>.size)
	rightKeyPtr.deallocate(capacity: MemoryLayout<SecKey>.size)
	return result
}
