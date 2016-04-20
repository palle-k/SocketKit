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
	internal let identity:SecIdentityRef
	
	
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
	public init(withData data:NSData, password:String? = nil) throws
	{
		let options = [String(kSecImportExportPassphrase) : (password ?? "")]
		var array:CFArray? = nil
		let status = SecPKCS12Import(data, options, &array)
		
		guard status == errSecSuccess
		else
		{
			DEBUG ?-> print("Import failed. Reason: \(status)")
			throw TLSError.ImportFailed
		}
		
		guard let identities = array as Array<AnyObject>?
		else
		{
			DEBUG ?-> print("Identities not loaded")
			throw TLSError.ImportFailed
		}
		
		DEBUG ?-> identities.forEach { print($0) }
		
		guard let dict = identities.first as? NSDictionary
		else
		{
			DEBUG ?-> print("Identities empty or not dictionary")
			throw TLSError.ImportFailed
		}
		
		guard let identity = dict[kSecImportItemIdentity as String] as! SecIdentityRef?
		else
		{
			DEBUG ?-> print("Identity could not be casted or does not exist")
			throw TLSError.ImportFailed
		}
		
		self.identity = identity
	}
	
	
	/**

	Creates a new certificate with the specified SecIdentityRef.
	
	- parameter identity: Identity containing the certificate and private key to use
	
	*/
	public init(withSecIdentity identity: SecIdentityRef)
	{
		self.identity = identity
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
	public init(withContentsOfFile filePath: String, password: String? = nil) throws
	{
		guard let data = NSData(contentsOfFile: filePath)
		else
		{
			DEBUG ?-> print("Data could not be loaded.")
			throw TLSError.DataNotAccessible
		}
		try self.init(withData: data, password: password)
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
	public init(withContentsOfFile filePath: String, readingOptions: NSDataReadingOptions, password: String? = nil) throws
	{
		let data = try NSData(contentsOfFile: filePath, options: readingOptions)
		try self.init(withData: data, password: password)
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
	let leftKeyPtr = UnsafeMutablePointer<SecKey?>.alloc(sizeof(SecKey))
	let rightKeyPtr = UnsafeMutablePointer<SecKey?>.alloc(sizeof(SecKey))
	
	SecIdentityCopyPrivateKey(left.identity, leftKeyPtr)
	SecIdentityCopyPrivateKey(right.identity, rightKeyPtr)
	
	let result = memcmp(leftKeyPtr, rightKeyPtr, sizeof(SecKey)) > 0
	leftKeyPtr.dealloc(sizeof(SecKey))
	rightKeyPtr.dealloc(sizeof(SecKey))
	return result
}
