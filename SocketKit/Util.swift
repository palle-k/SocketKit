//
//  Util.swift
//  SocketKit
//
//  Created by Palle Klewitz on 11.04.16.
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
import Darwin
import Foundation

internal var DEBUG = Process.arguments.contains("-skdebug")
internal var DEBUG_HEXDUMP = Process.arguments.contains("-skdebug-hexdump")

internal func sockaddr_cast(inout addr: sockaddr) -> sockaddr_in
{
	return withUnsafePointer(&addr)
	{ sockaddr_ptr -> sockaddr_in in
		var sockaddr_in_result = sockaddr_in()
		memcpy(&sockaddr_in_result, sockaddr_ptr, sizeof(sockaddr_in_result.dynamicType))
		return sockaddr_in_result
	}
}

//Name this properly
public enum DataError : ErrorType
{
	case StringConversion
}

public enum IOError : ErrorType
{
	//Internal errors
	
	case InvalidSocket
	case BadMessage
	case Invalid
	case Overflow
	case InsufficientRessources
	case OutOfMemory
	case TooBig
	
	//Network errors
	
	case NonexistentDevice
	case InsufficientPermissions
	case NetworkDown
	case NoRoute
	case ConnectionReset
	case NotConnected
	case TimedOut
	case Physical
	case BrokenPipe
	
	//End of stream error
	
	case EndOfFile
	
	//Non-fatal errors
	
	case Interrupted
	case Again
	case WouldBlock
	
	//Other
	
	case Unknown
	
	static func FromCurrentErrno() -> IOError
	{
		switch errno
		{
		case EBADF:
			return IOError.InvalidSocket
		case EBADMSG:
			return IOError.BadMessage
		case EINVAL:
			return IOError.Invalid
		case EIO:
			return IOError.Physical
		case EOVERFLOW:
			return IOError.Overflow
		case ECONNRESET:
			return IOError.ConnectionReset
		case ENOTCONN:
			return IOError.NotConnected
		case ETIMEDOUT:
			return IOError.TimedOut
		case ENOBUFS:
			return IOError.InsufficientRessources
		case ENOMEM:
			return IOError.OutOfMemory
		case ENXIO:
			return IOError.NonexistentDevice
		case EWOULDBLOCK:
			return IOError.WouldBlock
		case EAGAIN:
			return IOError.Again
		case EINTR:
			return IOError.Interrupted
		case EPIPE:
			return IOError.BrokenPipe
		default:
			return IOError.Unknown
		}
	}
}

public enum SocketError : ErrorType
{
	case Flags
	case Reuse
	case Bind
	case Nonblocking
	case Listen
	case Accept
	case Open
}

public enum DNSError : ErrorType
{
	case InvalidAddress
	case LookupFailed(info: String?)
}

public enum TLSError : ErrorType
{
	case SessionNotCreated
	case HandshakeFailed
	case ImportFailed
	case DataNotAccessible
	case Unknown
}


internal let isLittleEndian = Int(OSHostByteOrder()) == OSLittleEndian

internal let htons  = isLittleEndian ? _OSSwapInt16 : { $0 }
internal let htonl  = isLittleEndian ? _OSSwapInt32 : { $0 }
internal let htonll = isLittleEndian ? _OSSwapInt64 : { $0 }
internal let ntohs  = isLittleEndian ? _OSSwapInt16 : { $0 }
internal let ntohl  = isLittleEndian ? _OSSwapInt32 : { $0 }
internal let ntohll = isLittleEndian ? _OSSwapInt64 : { $0 }


infix operator ?-> { associativity left precedence 50 }

@inline(__always) internal func ?-> <Result>(left: Bool, @autoclosure right: () throws -> Result) rethrows -> Result?
{
	if left
	{
		return try right()
	}
	return nil
}

internal func hex(data: UnsafePointer<Void>, length: Int) -> String
{
	var chars = Array<UInt8>(count: length, repeatedValue: 0)
	memcpy(&chars, data, length)
	let reduced = chars.reduce("") { "\($0)\(String(format: "%02X", $1)) " }
	return reduced
}

internal func hex(data: [CChar]) -> String
{
	return hex(data, length: data.count)
}