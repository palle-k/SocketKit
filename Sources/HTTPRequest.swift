//
//  HTTPRequest.swift
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


public struct HTTPRequest
{
	public var version:String
	public var path:String
	public var method:HTTPMethod
	public var header:[String:String]
	
	public var content: Data?
	
	public init()
	{
		version = "HTTP/1.1"
		method = .get
		path = "/"
		header = [:]
	}
	
	public subscript(key: String) -> String?
	{
		get
		{
			return header[key]
		}
		
		set (new)
		{
			if let new = new
			{
				header[key] = new
			}
			else
			{
				header.removeValue(forKey: key)
			}
		}
	}
	
	public subscript(key: HTTPRequestHeaderField) -> String?
	{
		get
		{
			return header[key.rawValue]
		}
		
		set (new)
		{
			if let new = new
			{
				header[key.rawValue] = new
			}
			else
			{
				header.removeValue(forKey: key.rawValue)
			}
		}
	}
}

extension HTTPRequest: StreamWritable
{
	
	public func write(to outputStream: OutputStream) throws
	{
		let escapedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
		try outputStream.writeln("\(method.rawValue) \(escapedPath) \(version)")
		for (key, value) in header
		{
			
			try outputStream.writeln("\(key): \(value)")
		}
	}
	
}

extension HTTPRequest: StreamReadable
{
	public init(byReadingFrom stream: InputStream) throws
	{
		guard let requestLine = try stream.readLine(.ascii) else { fatalError("Cannot read line. TODO: Work around this!") }
		guard !requestLine.isEmpty else { fatalError("Cannot parse HTTP request") }
		let components = requestLine.components(separatedBy: .whitespaces)
		guard components.count == 3 else { fatalError("Malformed HTTP request. TODO: Create ErrorType for this!") }
		switch components[0].uppercased()
		{
		case "GET":
			method = .get
		case "POST":
			method = .post
		case "PUT":
			method = .put
		case "OPTIONS":
			method = .options
		case "HEAD":
			method = .head
		case "DELETE":
			method = .delete
		case "CONNECT":
			method = .connect
		default:
			fatalError("Malformed HTTP Request. TODO: Create ErrorType for this!")
		}
		
		path = components[1]
		version = components[2]
		
		let header:[String:String] = [:]
		
		while let headerLine = try stream.readLine(.ascii), !headerLine.isEmpty
		{
			
		}
		
		self.header = header
	}
}


