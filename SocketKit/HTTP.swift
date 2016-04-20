//
//  HTTP.swift
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

/**

Date formatter for HTML time format

*/
private let DateFormatter:NSDateFormatter =
{
	let formatter = NSDateFormatter()
	formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
	formatter.locale = NSLocale(localeIdentifier: "en_US")
	return formatter
}()


/**

Basic HTTP response to a get request.

Sends the given data as content to the client

*/
public class HTTPResponse : StreamWritable
{
	public let content:NSData
	public let mimeType:String
	
	public init(withContent content: String)
	{
		self.content = content.dataUsingEncoding(NSUTF8StringEncoding)!
		self.mimeType = "text/html"
	}
	
	public init(withContent content: NSData, mimeType: String)
	{
		self.content = content
		self.mimeType = mimeType
	}
	
	public func write(toStream outputStream: OutputStream) throws
	{
		try outputStream.writeln("HTTP/1.1 200 OK")
		try outputStream.writeln("Date: \(DateFormatter.stringFromDate(NSDate()))")
		try outputStream.writeln("Server: PK-SocketKit/0.1a (OS X/Swift)")
		try outputStream.writeln("Last-Modified: \(DateFormatter.stringFromDate(NSDate()))")
		try outputStream.writeln("Accept-Ranges: bytes")
		try outputStream.writeln("Connection: close")
		try outputStream.writeln("Content-Type: \(mimeType)")
		try outputStream.writeln("Content-Length: \(content.length)")
		try outputStream.writeln()
		try outputStream.write(content)
		try outputStream.writeln()
	}
}