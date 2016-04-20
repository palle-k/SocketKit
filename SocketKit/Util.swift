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

/*
typedef UInt32 SSLCipherSuite;
enum
{
SSL_NULL_WITH_NULL_NULL =               0x0000,.
SSL_RSA_WITH_NULL_MD5 =                 0x0001,.
SSL_RSA_WITH_NULL_SHA =                 0x0002,.
SSL_RSA_EXPORT_WITH_RC4_40_MD5 =        0x0003,.
SSL_RSA_WITH_RC4_128_MD5 =              0x0004,.
SSL_RSA_WITH_RC4_128_SHA =              0x0005,.
SSL_RSA_EXPORT_WITH_RC2_CBC_40_MD5 =    0x0006,.
SSL_RSA_WITH_IDEA_CBC_SHA =             0x0007,.
SSL_RSA_EXPORT_WITH_DES40_CBC_SHA =     0x0008,.
SSL_RSA_WITH_DES_CBC_SHA =              0x0009,.
SSL_RSA_WITH_3DES_EDE_CBC_SHA =         0x000A,.

SSL_DH_DSS_EXPORT_WITH_DES40_CBC_SHA =  0x000B,
SSL_DH_DSS_WITH_DES_CBC_SHA =           0x000C,
SSL_DH_DSS_WITH_3DES_EDE_CBC_SHA =      0x000D,
SSL_DH_RSA_EXPORT_WITH_DES40_CBC_SHA =  0x000E,
SSL_DH_RSA_WITH_DES_CBC_SHA =           0x000F,
SSL_DH_RSA_WITH_3DES_EDE_CBC_SHA =      0x0010,
SSL_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA = 0x0011,
SSL_DHE_DSS_WITH_DES_CBC_SHA =          0x0012,
SSL_DHE_DSS_WITH_3DES_EDE_CBC_SHA =     0x0013,
SSL_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA = 0x0014,
SSL_DHE_RSA_WITH_DES_CBC_SHA =          0x0015,
SSL_DHE_RSA_WITH_3DES_EDE_CBC_SHA =     0x0016,
SSL_DH_anon_EXPORT_WITH_RC4_40_MD5 =    0x0017,
SSL_DH_anon_WITH_RC4_128_MD5 =          0x0018,
SSL_DH_anon_EXPORT_WITH_DES40_CBC_SHA = 0x0019,
SSL_DH_anon_WITH_DES_CBC_SHA =          0x001A,
SSL_DH_anon_WITH_3DES_EDE_CBC_SHA =     0x001B,
SSL_FORTEZZA_DMS_WITH_NULL_SHA =        0x001C,
SSL_FORTEZZA_DMS_WITH_FORTEZZA_CBC_SHA =0x001D,

/* TLS addenda using AES,
per RFC 3268 */
TLS_RSA_WITH_AES_128_CBC_SHA      =     0x002F,
TLS_DH_DSS_WITH_AES_128_CBC_SHA   =     0x0030,
TLS_DH_RSA_WITH_AES_128_CBC_SHA   =     0x0031,
TLS_DHE_DSS_WITH_AES_128_CBC_SHA  =     0x0032,
TLS_DHE_RSA_WITH_AES_128_CBC_SHA  =     0x0033,
TLS_DH_anon_WITH_AES_128_CBC_SHA  =     0x0034,
TLS_RSA_WITH_AES_256_CBC_SHA      =     0x0035,
TLS_DH_DSS_WITH_AES_256_CBC_SHA   =     0x0036,
TLS_DH_RSA_WITH_AES_256_CBC_SHA   =     0x0037,
TLS_DHE_DSS_WITH_AES_256_CBC_SHA  =     0x0038,
TLS_DHE_RSA_WITH_AES_256_CBC_SHA  =     0x0039,
TLS_DH_anon_WITH_AES_256_CBC_SHA  =     0x003A,

/* ECDSA addenda,
RFC 4492 */
TLS_ECDH_ECDSA_WITH_NULL_SHA           =    0xC001,
TLS_ECDH_ECDSA_WITH_RC4_128_SHA        =    0xC002,
TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA   =    0xC003,
TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA    =    0xC004,
TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA    =    0xC005,
TLS_ECDHE_ECDSA_WITH_NULL_SHA          =    0xC006,
TLS_ECDHE_ECDSA_WITH_RC4_128_SHA       =    0xC007,
TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA  =    0xC008,
TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA   =    0xC009,
TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA   =    0xC00A,
TLS_ECDH_RSA_WITH_NULL_SHA             =    0xC00B,
TLS_ECDH_RSA_WITH_RC4_128_SHA          =    0xC00C,
TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA     =    0xC00D,
TLS_ECDH_RSA_WITH_AES_128_CBC_SHA      =    0xC00E,
TLS_ECDH_RSA_WITH_AES_256_CBC_SHA      =    0xC00F,
TLS_ECDHE_RSA_WITH_NULL_SHA            =    0xC010,
TLS_ECDHE_RSA_WITH_RC4_128_SHA         =    0xC011,
TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA    =    0xC012,
TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA     =    0xC013,
TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA     =    0xC014,
TLS_ECDH_anon_WITH_NULL_SHA            =    0xC015,
TLS_ECDH_anon_WITH_RC4_128_SHA         =    0xC016,
TLS_ECDH_anon_WITH_3DES_EDE_CBC_SHA    =    0xC017,
TLS_ECDH_anon_WITH_AES_128_CBC_SHA     =    0xC018,
TLS_ECDH_anon_WITH_AES_256_CBC_SHA     =    0xC019,


/* TLS 1.2 addenda,
RFC 5246 */

/* Initial state. */
TLS_NULL_WITH_NULL_NULL                   = 0x0000,

/* Server provided RSA certificate for key exchange. */
TLS_RSA_WITH_NULL_MD5                     = 0x0001,
TLS_RSA_WITH_NULL_SHA                     = 0x0002,
TLS_RSA_WITH_RC4_128_MD5                  = 0x0004,
TLS_RSA_WITH_RC4_128_SHA                  = 0x0005,
TLS_RSA_WITH_3DES_EDE_CBC_SHA             = 0x000A,
TLS_RSA_WITH_NULL_SHA256                  = 0x003B,
TLS_RSA_WITH_AES_128_CBC_SHA256           = 0x003C,
TLS_RSA_WITH_AES_256_CBC_SHA256           = 0x003D,

/* Server-authenticated (and optionally client-authenticated ) Diffie-Hellman. */
TLS_DH_DSS_WITH_3DES_EDE_CBC_SHA          = 0x000D,
TLS_DH_RSA_WITH_3DES_EDE_CBC_SHA          = 0x0010,
TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA         = 0x0013,
TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA         = 0x0016,
TLS_DH_DSS_WITH_AES_128_CBC_SHA256        = 0x003E,
TLS_DH_RSA_WITH_AES_128_CBC_SHA256        = 0x003F,
TLS_DHE_DSS_WITH_AES_128_CBC_SHA256       = 0x0040,
TLS_DHE_RSA_WITH_AES_128_CBC_SHA256       = 0x0067,
TLS_DH_DSS_WITH_AES_256_CBC_SHA256        = 0x0068,
TLS_DH_RSA_WITH_AES_256_CBC_SHA256        = 0x0069,
TLS_DHE_DSS_WITH_AES_256_CBC_SHA256       = 0x006A,
TLS_DHE_RSA_WITH_AES_256_CBC_SHA256       = 0x006B,

/* Completely anonymous Diffie-Hellman */
TLS_DH_anon_WITH_RC4_128_MD5              = 0x0018,
TLS_DH_anon_WITH_3DES_EDE_CBC_SHA         = 0x001B,
TLS_DH_anon_WITH_AES_128_CBC_SHA256       = 0x006C,
TLS_DH_anon_WITH_AES_256_CBC_SHA256       = 0x006D,

/* Addendum from RFC 4279,
TLS PSK */

TLS_PSK_WITH_RC4_128_SHA                  = 0x008A,
TLS_PSK_WITH_3DES_EDE_CBC_SHA             = 0x008B,
TLS_PSK_WITH_AES_128_CBC_SHA              = 0x008C,
TLS_PSK_WITH_AES_256_CBC_SHA              = 0x008D,
TLS_DHE_PSK_WITH_RC4_128_SHA              = 0x008E,
TLS_DHE_PSK_WITH_3DES_EDE_CBC_SHA         = 0x008F,
TLS_DHE_PSK_WITH_AES_128_CBC_SHA          = 0x0090,
TLS_DHE_PSK_WITH_AES_256_CBC_SHA          = 0x0091,
TLS_RSA_PSK_WITH_RC4_128_SHA              = 0x0092,
TLS_RSA_PSK_WITH_3DES_EDE_CBC_SHA         = 0x0093,
TLS_RSA_PSK_WITH_AES_128_CBC_SHA          = 0x0094,
TLS_RSA_PSK_WITH_AES_256_CBC_SHA          = 0x0095,

/* RFC 4785 - Pre-Shared Key (PSK ) Ciphersuites with NULL Encryption */

TLS_PSK_WITH_NULL_SHA                     = 0x002C,
TLS_DHE_PSK_WITH_NULL_SHA                 = 0x002D,
TLS_RSA_PSK_WITH_NULL_SHA                 = 0x002E,

/* Addenda from rfc 5288 AES Galois Counter Mode (GCM ) Cipher Suites
for TLS. */
TLS_RSA_WITH_AES_128_GCM_SHA256           = 0x009C,
TLS_RSA_WITH_AES_256_GCM_SHA384           = 0x009D,
TLS_DHE_RSA_WITH_AES_128_GCM_SHA256       = 0x009E,
TLS_DHE_RSA_WITH_AES_256_GCM_SHA384       = 0x009F,
TLS_DH_RSA_WITH_AES_128_GCM_SHA256        = 0x00A0,
TLS_DH_RSA_WITH_AES_256_GCM_SHA384        = 0x00A1,
TLS_DHE_DSS_WITH_AES_128_GCM_SHA256       = 0x00A2,
TLS_DHE_DSS_WITH_AES_256_GCM_SHA384       = 0x00A3,
TLS_DH_DSS_WITH_AES_128_GCM_SHA256        = 0x00A4,
TLS_DH_DSS_WITH_AES_256_GCM_SHA384        = 0x00A5,
TLS_DH_anon_WITH_AES_128_GCM_SHA256       = 0x00A6,
TLS_DH_anon_WITH_AES_256_GCM_SHA384       = 0x00A7,

/* RFC 5487 - PSK with SHA-256/384 and AES GCM */
TLS_PSK_WITH_AES_128_GCM_SHA256           = 0x00A8,
TLS_PSK_WITH_AES_256_GCM_SHA384           = 0x00A9,
TLS_DHE_PSK_WITH_AES_128_GCM_SHA256       = 0x00AA,
TLS_DHE_PSK_WITH_AES_256_GCM_SHA384       = 0x00AB,
TLS_RSA_PSK_WITH_AES_128_GCM_SHA256       = 0x00AC,
TLS_RSA_PSK_WITH_AES_256_GCM_SHA384       = 0x00AD,

TLS_PSK_WITH_AES_128_CBC_SHA256           = 0x00AE,
TLS_PSK_WITH_AES_256_CBC_SHA384           = 0x00AF,
TLS_PSK_WITH_NULL_SHA256                  = 0x00B0,
TLS_PSK_WITH_NULL_SHA384                  = 0x00B1,

TLS_DHE_PSK_WITH_AES_128_CBC_SHA256       = 0x00B2,
TLS_DHE_PSK_WITH_AES_256_CBC_SHA384       = 0x00B3,
TLS_DHE_PSK_WITH_NULL_SHA256              = 0x00B4,
TLS_DHE_PSK_WITH_NULL_SHA384              = 0x00B5,

TLS_RSA_PSK_WITH_AES_128_CBC_SHA256       = 0x00B6,
TLS_RSA_PSK_WITH_AES_256_CBC_SHA384       = 0x00B7,
TLS_RSA_PSK_WITH_NULL_SHA256              = 0x00B8,
TLS_RSA_PSK_WITH_NULL_SHA384              = 0x00B9,


/* Addenda from rfc 5289  Elliptic Curve Cipher Suites with
HMAC SHA-256/384. */
TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256   = 0xC023,
TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384   = 0xC024,
TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256    = 0xC025,
TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384    = 0xC026,
TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256     = 0xC027,
TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384     = 0xC028,
TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256      = 0xC029,
TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384      = 0xC02A,

/* Addenda from rfc 5289  Elliptic Curve Cipher Suites with
SHA-256/384 and AES Galois Counter Mode (GCM ) */
TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256   = 0xC02B,
TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384   = 0xC02C,
TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256    = 0xC02D,
TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384    = 0xC02E,
TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256     = 0xC02F,
TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384     = 0xC030,
TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256      = 0xC031,
TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384      = 0xC032,

/* RFC 5746 - Secure Renegotiation */
TLS_EMPTY_RENEGOTIATION_INFO_SCSV         = 0x00FF,

/*
* Tags for SSL 2 cipher kinds that are not specified
* for SSL 3.
*/
SSL_RSA_WITH_RC2_CBC_MD5 =              0xFF80,
SSL_RSA_WITH_IDEA_CBC_MD5 =             0xFF81,
SSL_RSA_WITH_DES_CBC_MD5 =              0xFF82,
SSL_RSA_WITH_3DES_EDE_CBC_MD5 =         0xFF83,
SSL_NO_SUCH_CIPHERSUITE =               0xFFFF
};
*/
/*
public enum TLSCipherSuite
{
	case Null
	
	//RSA Suites
	case RSA_With_Null_MD5
	case RSA_With_Null_SHA
	case RSA_Export_With_RC4_40_MD5
	case RSA_With_RC4_128_MD5
	case RSA_With_RC4_128_SHA
	case RSA_Export_With_RC2_CBC_40_MD5
	case RSA_With_Idea_CBC_SHA
	case RSA_Export_With_DES40_CBC_SHA
	case RSA_With_DES_CBC_SHA
	case RSA_With_3DES_EDE_CBC_SHA
	
	//Diffie Hellmann Suites
	case DH_DSS_Export_With_DES40_CBC_SHA
	case DH_DSS_With_DES_CBC_SHA
	
}
*/
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
	
	internal var sslError:OSStatus
	{
		switch self
		{
		case .InvalidSocket, .Overflow, .InsufficientRessources, .OutOfMemory, .TooBig, .Invalid:
			return errSSLInternal
		case .BadMessage:
			return errSSLPeerUnexpectedMsg
		case .NonexistentDevice, .NetworkDown, .NoRoute:
			return errSSLConnectionRefused
		case .ConnectionReset, .NotConnected, .TimedOut, .Physical, .BrokenPipe:
			return errSSLClosedAbort
		case .Interrupted, .Again, .WouldBlock:
			return errSSLWouldBlock
		case .EndOfFile:
			return errSSLClosedGraceful
		case .InsufficientPermissions:
			return errSSLPeerAccessDenied
		default:
			return errSSLInternal
		}
	}
	
	static internal func FromCurrentErrno() -> IOError
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