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

public struct Certificate
{
	internal let identity:SecIdentityRef
	
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
	
	public init(withSecIdentity identity: SecIdentityRef)
	{
		self.identity = identity
	}
	
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
	
	public init?(withContentsOfFile filePath: String, readingOptions: NSDataReadingOptions, password: String? = nil) throws
	{
		let data = try NSData(contentsOfFile: filePath, options: readingOptions)
		try self.init(withData: data, password: password)
	}
}