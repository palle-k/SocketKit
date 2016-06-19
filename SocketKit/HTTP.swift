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


public enum HTTPRequestHeaderField: String
{
	
	/**
	
	Content-Types that are acceptable for the response. See [Content negotiation](https://en.wikipedia.org/wiki/Content_negotiation).
	
	*/
	case Accept = "Accept"
	
	
	/**
	
	Character sets that are acceptable
	
	*/
	case AcceptCharset = "Accept-Charset"
	
	
	/**
	
	List of acceptable encodings. See [HTTP compression](https://en.wikipedia.org/wiki/HTTP_compression).
	
	*/
	case AcceptEncoding = "Accept-Encoding"
	
	
	/**
	
	List of acceptable human languages for response. See [Content negotiation](https://en.wikipedia.org/wiki/Content_negotiation).
	
	*/
	case AcceptLanguage = "Accept-Language"
	
	
	/**
	
	Acceptable version in time
	
	*/
	case AcceptDatetime = "Accept-Datetime"
	
	
	/**
	
	Authentication credentials for HTTP authentication
	
	*/
	case Authorization = "Authorization"
	
	
	/**
	
	Used to specify directives that must be obeyed by all caching mechanisms along the request-response chain
	
	*/
	case CacheControl = "Cache-Control"
	
	
	/**
	
	Control options for the current connection and list of hop-by-hop request fields.
	
	*/
	case Connection = "Connection"
	
	
	/**
	
	An HTTP cookie previously sent by the server with Set-Cookie
	
	*/
	case Cookie = "Cookie"
	
	
	/**
	
	The length of the request body in octets (8-bit bytes)
	
	*/
	case ContentLength = "Content-Length"
	
	
	/**
	
	A Base64-encoded binary MD5 sum of the content of the request body
	
	*/
	case ContentMD5 = "Content-MD5"
	
	
	/**
	
	The MIME type of the body of the request 
	
	(used with POST and PUT requests)
	
	*/
	case ContentType = "Content-Type"
	
	
	/**
	
	The date and time that the message was originated 
	
	(in "HTTP-date" format as defined by RFC 7231 Date/Time Formats)
	
	*/
	case Date = "Date"
	
	
	/**
	
	Indicates that particular server behaviors are required by the client
	
	*/
	case Expect = "Expect"
	
	
	/**
	
	Disclose original information of a client connecting to a web server through an HTTP proxy
	
	*/
	case Forwarded = "Forwarded"
	
	
	/**
	
	The email address of the user making the request
	
	*/
	case From = "From"
	
	
	/**
	
	The domain name of the server (for virtual hosting), 
	and the TCP port number on which the server is listening.
	
	The port number may be omitted if the port is the standard port for the service requested.
	
	Mandatory since HTTP/1.1.
	
	*/
	case Host = "Host"
	
	
	/**
	
	Only perform the action if the client supplied entity matches the same entity on the server.
	This is mainly for methods like PUT to only update a resource 
	if it has not been modified since the user last updated it.
	
	*/
	case IfMatch = "If-Match"
	
	
	/**
	
	Allows a 304 Not Modified to be returned if content is unchanged
	
	*/
	case IfModifiedSince = "If-Modified-Since"
	
	
	/**
	
	Allows a 304 Not Modified to be returned if content is unchanged, see [HTTP ETag](https://en.wikipedia.org/wiki/HTTP_ETag)
	
	*/
	case IfNoneMatch = "If-None-Match"
	
	
	/**
	
	If the entity is unchanged, send me the part(s) that I am missing; 
	otherwise, send me the entire new entity
	
	*/
	case IfRange = "If-Range"
	
	
	/**
	
	Only send the response if the entity has not been modified since a specific time.
	
	*/
	case IfUnmodifiedSince = "If-Unmodified-Since"
	
	
	/**
	
	Limit the number of times the message can be forwarded through proxies or gateways.
	
	*/
	case MaxForwards = "Max-Forwards"
	
	
	/**
	
	Initiates a request for [cross-origin resource sharing](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing)
	(asks server for an 'Access-Control-Allow-Origin' response field).
	
	*/
	case Origin = "Origin"
	
	
	/**
	
	Implementation-specific fields that may have various effects anywhere along the request-response chain.
	
	*/
	case Pragma = "Pragma"
	
	
	/**
	
	Authorization credentials for connecting to a proxy.
	
	*/
	case ProxyAuthorization = "Proxy-Authorization"
	
	
	/**
	
	Request only part of an entity. Bytes are numbered from 0. 
	See [Byte serving](https://en.wikipedia.org/wiki/Byte_serving).
	
	*/
	case Range = "Range"
	
	
	/**
	
	This is the address of the previous web page from which a link to the currently requested page was followed. 
	
	(The word “referrer” has been misspelled in the RFC 
	as well as in most implementations to the point that it has become standard usage
	and is considered correct terminology)
	
	*/
	case Referer = "Referer"
	
	
	/**
	
	The transfer encodings the user agent is willing to accept: 
	the same values as for the response header field Transfer-Encoding can be used,
	plus the "trailers" value (related to the "chunked" transfer method) 
	to notify the server it expects to receive additional fields
	in the trailer after the last, zero-sized, chunk.
	
	*/
	case TE = "TE"
	
	
	/**
	
	The user agent string of the user agent
	
	*/
	case UserAgent = "User-Agent"
	
	
	/**
	
	Ask the server to upgrade to another protocol.
	
	*/
	case Upgrade = "Upgrade"
	
	
	/**
	
	Informs the server of proxies through which the request was sent.
	
	*/
	case Via = "Via"
	
	
	/**
	
	A general warning about possible problems with the entity body.
	
	*/
	case Warning = "Warning"
	
	
	// Non standard request headers (X-Headers)
	
	/**
	
	Mainly used to identify Ajax requests. 
	Most JavaScript frameworks send this field with value of XMLHttpRequest
	
	*/
	case XRequestedWith = "X-Requested-With"
	
	
	/**
	
	Requests a web application to disable their tracking of a user.
	
	*/
	case DNT = "DNT"
	
	
	/**
	
	A de facto standard for identifying the originating IP address 
	of a client connecting to a web server through an HTTP proxy or load balancer
	
	*/
	case XForwardedFor = "X-Forwarded-For"
	
	
	/**
	
	a de facto standard for identifying the original host 
	requested by the client in the Host HTTP request header, 
	since the host name and/or port of the reverse proxy (load balancer) 
	may differ from the origin server handling the request.
	
	*/
	case XForwardedHost = "X-Forwarded-Host"
	
	
	/**
	
	a de facto standard for identifying the originating protocol of an HTTP request, 
	since a reverse proxy (or a load balancer) may communicate 
	with a web server using HTTP even if the request to the reverse proxy is HTTPS. 
	An alternative form of the header (X-ProxyUser-Ip) 
	is used by Google clients talking to Google servers.
	
	*/
	case XForwardedProto = "X-Forwarded-Proto"
	
	
	/**
	
	Non-standard header field used by Microsoft applications and load-balancers
	
	*/
	case FrontEndHttps = "Front-End-Https"
	
	
	/**
	
	Requests a web application override the method specified in the request (typically POST) 
	with the method given in the header field (typically PUT or DELETE). 
	Can be used when a user agent or firewall prevents 
	PUT or DELETE methods from being sent directly 
	
	(note that this either a bug in the software component, 
	which ought to be fixed, or an intentional configuration, 
	in which case bypassing it may be the wrong thing to do).
	
	*/
	case XHTTPMethodOverride = "X-HTTP-Method-Override"
	
	
	/**
	
	Allows easier parsing of the MakeModel/Firmware 
	that is usually found in the User-Agent String of AT&T Devices
	
	*/
	case XAttDeviceid = "X-Att-Deviceid"
	
	
	/**
	
	Links to an XML file on the Internet with a full description and details 
	about the device currently connecting.
	
	*/
	case XWapProfile = "x-wap-profile"
	
	
	/**
	
	Implemented as a misunderstanding of the HTTP specifications. 
	Common because of mistakes in implementations of early HTTP versions. 
	Has exactly the same functionality as standard Connection field.
	
	*/
	case ProxyConnection = "Proxy-Connection"
	
	
	/**
	
	Server-side deep packet insertion of a unique ID identifying customers of Verizon Wireless; 
	also known as "perma-cookie" or "supercookie"
	
	*/
	case XUIDH = "X-UIDH"
	
	
	/**
	
	Used to prevent cross-site request forgery. Alternative header names are: X-CSRFToken and X-XSRF-TOKEN
	
	*/
	case XCsrfToken = "X-Csrf-Token"
}


public enum HTTPResponseHeaderField: String
{
	
	/**
	
	Specifying which web sites can participate in cross-origin resource sharing
	
	*/
	case AccessControlAllowOrigin = "Access-Control-Allow-Origin"
	
	
	/**
	
	Specifies which patch document formats this server supports
	
	*/
	case AcceptPatch = "Accept-Patch"
	
	
	/**
	
	What partial content range types this server supports via byte serving
	
	*/
	case AcceptRanges = "Accept-Ranges"
	
	
	/**
	
	The age the object has been in a proxy cache in seconds
	
	*/
	case Age = "Age"
	
	
	/**
	
	Valid actions for a specified resource. To be used for a 405 Method not allowed
	
	*/
	case Allow = "Allow"
	
	
	/**
	
	A server uses "Alt-Svc" header (meaning Alternative Services) 
	to indicate that its resources can also be accessed at a different network location
	(host or port) or using a different protocol
	
	*/
	case AltSvc = "Alt-Svc"
	
	
	/**
	
	Tells all caching mechanisms from server to client 
	whether they may cache this object. 
	
	It is measured in seconds
	
	*/
	case CacheControl = "Cache-Control"
	
	
	/**
	
	Control options for the current connection and list of hop-by-hop response fields
	
	*/
	case Connection = "Connection"
	
	
	/**
	
	An opportunity to raise a "File Download" dialogue box 
	for a known MIME type with binary format or suggest a filename for dynamic content.
	
	*/
	case ContentDisposition = "Content-Disposition"
	
	
	/**
	
	The type of encoding used on the data. See [HTTP compression](https://en.wikipedia.org/wiki/HTTP_compression).
	
	*/
	case ContentEncoding = "Content-Encoding"
	
	
	/**
	
	The natural language or languages of the intended audience for the enclosed content
	
	*/
	case ContentLanguage = "Content-Language"
	
	
	/**
	
	The length of the response body in octets (8-bit bytes)
	
	*/
	case ContentLength = "Content-Length"
	
	
	/**
	
	An alternate location for the returned data
	
	*/
	case ContentLocation = "Content-Location"
	
	
	/**
	
	A Base64-encoded binary MD5 sum of the content of the response
	
	*/
	case ContentMD5 = "Content-MD5"
	
	
	/**
	
	Where in a full body message this partial message belongs
	
	*/
	case ContentRange = "Content-Range"
	
	
	/**
	
	The MIME type of this content
	
	*/
	case ContentType = "Content-Type"
	
	
	/**
	
	The date and time that the message was sent (in "HTTP-date" format as defined by RFC 7231)
	
	*/
	case Date = "Date"
	
	
	/**
	
	An identifier for a specific version of a resource, often a message digest
	
	*/
	case ETag = "ETag"
	
	
	/**
	
	Gives the date/time after which the response is considered stale 
	(in "HTTP-date" format as defined by RFC 7231)
	
	*/
	case Expires = "Expires"
	
	
	/**
	
	The last modified date for the requested object 
	(in "HTTP-date" format as defined by RFC 7231)
	
	*/
	case LastModified = "Last-Modified"
	
	
	/**
	
	Used to express a typed relationship with another resource, 
	where the relation type is defined by RFC 5988
	
	*/
	case Link = "Link"
	
	
	/**
	
	Used in redirection, or when a new resource has been created.
	
	*/
	case Location = "Location"
	
	
	/**
	
	This field is supposed to set P3P policy, 
	in the form of P3P:CP="your_compact_policy".
	
	*/
	case P3P = "P3P"
	
	
	/**
	
	Implementation-specific fields that may have various effects 
	anywhere along the request-response chain.
	
	*/
	case Pragma = "Pragma"
	
	
	/**
	
	Request authentication to access the proxy.
	
	*/
	case ProxyAuthenticate = "Proxy-Authenticate"
	
	
	/**
	
	HTTP Public Key Pinning, announces hash of website's authentic TLS certificate
	
	*/
	case PublicKeyPins = "Public-Key-Pins"
	
	
	/**
	
	Used in redirection, or when a new resource has been created.
	
	*/
	case Refresh = "Refresh"
	
	
	/**
	
	If an entity is temporarily unavailable, this instructs the client to try again later.
	Value could be a specified period of time (in seconds) or a HTTP-date.
	
	*/
	case RetryAfter = "Retry-After"
	
	
	/**
	
	A name for the server
	
	*/
	case Server = "Server"
	
	
	/**
	
	An HTTP cookie
	
	*/
	case SetCookie = "Set-Cookie"
	
	
	/**
	
	CGI header field specifying the status of the HTTP response. 
	Normal HTTP responses use a separate "Status-Line" instead, defined by RFC 7230.
	
	*/
	case Status = "Status"
	
	
	/**
	
	A HSTS Policy informing the HTTP client how long to cache the HTTPS only policy 
	and whether this applies to subdomains.
	
	*/
	case StrictTransportSecurity = "Strict-Transport-Security"
	
	
	/**
	
	The Trailer general field value indicates that the given set of header fields
	is present in the trailer of a message encoded with chunked transfer coding.
	
	*/
	case Trailer = "Trailer"
	
	
	/**
	
	The form of encoding used to safely transfer the entity to the user. 
	Currently defined methods are: chunked, compress, deflate, gzip, identity.
	
	*/
	case TransferEncoding = "Transfer-Encoding"
	
	
	/**
	
	Tracking Status Value, value suggested to be sent in response to a DNT(do-not-track)
	
	*/
	case TSV = "TSV"
	
	
	/**
	
	Ask the client to upgrade to another protocol.
	
	*/
	case Upgrade = "Upgrade"
	
	
	/**
	
	Tells downstream proxies how to match future request headers
	to decide whether the cached response can be used
	rather than requesting a fresh one from the origin server.
	
	*/
	case Vary = "Vary"
	
	
	/**
	
	Informs the client of proxies through which the response was sent.
	
	*/
	case Via = "Via"
	
	
	/**
	
	A general warning about possible problems with the entity body.
	
	*/
	case Warning = "Warning"
	
	
	/**
	
	Indicates the authentication scheme that should be used to access the requested entity.
	
	*/
	case WWWAuthenticate = "WWW-Authenticate"
	
	
	/**
	
	Clickjacking protection
	
	*/
	case XFrameOptions = "X-Frame-Options"
	
	
	// Non standard request headers (X-Headers)
	
	/**
	
	Cross-site scripting (XSS) filter
	
	*/
	case XXSSProtection = "X-XSS-Protection"
	
	
	/**
	
	Content Security Policy definition.
	
	*/
	case XWebKitCSP = "X-WebKit-CSP"
	
	
	/**
	
	The only defined value, "nosniff", 
	prevents Internet Explorer from MIME-sniffing a response away from the declared content-type. 
	This also applies to Google Chrome, when downloading extensions.
	
	*/
	case XContentTypeOptions = "X-Content-Type-Options"
	
	
	/**
	
	Specifies the technology (e.g. ASP.NET, PHP, JBoss) supporting the web application
	
	*/
	case XPoweredBy = "X-Powered-By"
	
	
	/**
	
	Recommends the preferred rendering engine (often a backward-compatibility mode) 
	to use to display the content.
 
	Also used to activate Chrome Frame in Internet Explorer.
	
	*/
	case XUACompatible = "X-UA-Compatible"
	
	
	/**
	
	Provide the duration of the audio or video in seconds;
 
	only supported by Gecko browsers
	
	*/
	case XContentDuration = "X-Content-Duration"
	
	
	/**
	
	Tells a server which (presumably in the middle of a HTTP -> HTTPS migration) 
	hosts mixed content that the client would prefer redirection to HTTPS
	and can handle Content-Security-Policy: upgrade-insecure-requests
	
	*/
	case UpgradeInsecureRequests = "Upgrade-Insecure-Requests"
	
	
	/**
	
	Correlates HTTP requests between a client and server.
	
	*/
	case XRequestID = "X-Request-ID"
}

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