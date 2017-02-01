//
//  HTTPResponse.swift
//  SocketKit
//
//  Created by Palle Klewitz on 20.06.16.
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


/**

Basic HTTP response to a get request.

Sends the given data as content to the client

*/
public struct HTTPResponse
{
	public var version:HTTPVersion
	public var status:HTTPStatusCode
	public var header:[HTTPResponseHeaderField:String]
	
	public var content:Data
	
	public init(with content: String)
	{
		self.content = content.data(using: String.Encoding.utf8)!
		version = .v1_1
		status = .ok
		header = [:]
	}
	
	public init(with content: Data)
	{
		self.content = content
		version = .v1_1
		status = .ok
		header = [:]
	}
	
	public init(version: HTTPVersion, status: HTTPStatusCode, header: [HTTPResponseHeaderField:String], data: Data)
	{
		self.version = version
		self.status = status
		self.header = header
		self.content = data
	}
}

extension HTTPResponse: StreamWritable
{
	
	public func write(to outputStream: OutputStream) throws
	{
		// Preparing header fields
		
		var header = self.header
		
		if !header.keys.contains(.date)
		{
			header[.date] = "\(HTTPDateFormatter.string(from: Date()))"
		}
		if !header.keys.contains(.server)
		{
			header[.server] = "PK-SocketKit/\(Bundle(identifier: "com.palleklewitz.SocketKit")?.infoDictionary!["CFBundleShortVersionString"] ?? "")"
		}
		if !header.keys.contains(.lastModified)
		{
			header[.lastModified] = "\(HTTPDateFormatter.string(from: Date()))"
		}
		if !header.keys.contains(.acceptRanges)
		{
			header[.acceptRanges] = "bytes"
		}
		if !header.keys.contains(.connection)
		{
			header[.connection] = "close"
		}
		if !header.keys.contains(.contentType)
		{
			header[.contentType] = "application/octet-stream"
		}
		if !header.keys.contains(.contentLength)
		{
			header[.contentLength] = "\(content.count)"
		}
		
		// Sending status line
		try outputStream.writeln("\(version.rawValue) \(status.rawValue)")
		
		// Sending header fields
		for (headerField, headerValue) in header
		{
			try outputStream.writeln("\(headerField.rawValue): \(headerValue)")
		}
		
		guard content.count <= 0 else { return }
		
		// Sending content
		try outputStream.writeln()
		try outputStream.write(content)
		try outputStream.writeln()
	}
	
}


extension HTTPResponse: StreamReadable
{

	public init(byReadingFrom stream: InputStream) throws
	{
		content = Data()
		version = .v1_1
		status = .ok
		header = [:]
		fatalError("Reading HTTP response from stream not yet implemented")
	}

}


