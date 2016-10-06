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

Date formatter for HTTP time format

*/
internal let HTTPDateFormatter:DateFormatter =
{
	let formatter = DateFormatter()
	formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
	formatter.locale = Locale(identifier: "en_US")
	return formatter
}()


/**

HTTP Versions

*/

public enum HTTPVersion: String
{
	
	/**

	HTTP Version 1.0
	
	*/
	case v1_0 = "HTTP/1.0"
	
	
	/**
	
	HTTP Version 1.1
	
	Allows pipelining of requests, put and delete requests
	
	*/
	case v1_1 = "HTTP/1.1"
	
	
	/**
	
	HTTP Version 2.0
	
	Allows combination of requests, pushing data, further compression and binary data
	
	*/
	case v2_0 = "HTTP/2.0"
}


/**

HTTP Header Fields for Client Requests

*/
public enum HTTPRequestHeaderField: String
{
	
	/**
	
	Content-Types that are acceptable for the response. See [Content negotiation](https://en.wikipedia.org/wiki/Content_negotiation).
	
	*/
	case accept = "Accept"
	
	
	/**
	
	Character sets that are acceptable
	
	*/
	case acceptCharset = "Accept-Charset"
	
	
	/**
	
	List of acceptable encodings. See [HTTP compression](https://en.wikipedia.org/wiki/HTTP_compression).
	
	*/
	case acceptEncoding = "Accept-Encoding"
	
	
	/**
	
	List of acceptable human languages for response. See [Content negotiation](https://en.wikipedia.org/wiki/Content_negotiation).
	
	*/
	case acceptLanguage = "Accept-Language"
	
	
	/**
	
	Acceptable version in time
	
	*/
	case acceptDatetime = "Accept-Datetime"
	
	
	/**
	
	Authentication credentials for HTTP authentication
	
	*/
	case authorization = "Authorization"
	
	
	/**
	
	Used to specify directives that must be obeyed by all caching mechanisms along the request-response chain
	
	*/
	case cacheControl = "Cache-Control"
	
	
	/**
	
	Control options for the current connection and list of hop-by-hop request fields.
	
	*/
	case connection = "Connection"
	
	
	/**
	
	An HTTP cookie previously sent by the server with Set-Cookie
	
	*/
	case cookie = "Cookie"
	
	
	/**
	
	The length of the request body in octets (8-bit bytes)
	
	*/
	case contentLength = "Content-Length"
	
	
	/**
	
	A Base64-encoded binary MD5 sum of the content of the request body
	
	*/
	@available(*, introduced: 0.1, deprecated: 0.1)
	case contentMD5 = "Content-MD5"
	
	
	/**
	
	The MIME type of the body of the request 
	
	(used with POST and PUT requests)
	
	*/
	case contentType = "Content-Type"
	
	
	/**
	
	The date and time that the message was originated 
	
	(in "HTTP-date" format as defined by RFC 7231 Date/Time Formats)
	
	*/
	case date = "Date"
	
	
	/**
	
	Indicates that particular server behaviors are required by the client
	
	*/
	case expect = "Expect"
	
	
	/**
	
	Disclose original information of a client connecting to a web server through an HTTP proxy
	
	*/
	case forwarded = "Forwarded"
	
	
	/**
	
	The email address of the user making the request
	
	*/
	case from = "From"
	
	
	/**
	
	The domain name of the server (for virtual hosting), 
	and the TCP port number on which the server is listening.
	
	The port number may be omitted if the port is the standard port for the service requested.
	
	Mandatory since HTTP/1.1.
	
	*/
	case host = "Host"
	
	
	/**
	
	Only perform the action if the client supplied entity matches the same entity on the server.
	This is mainly for methods like PUT to only update a resource 
	if it has not been modified since the user last updated it.
	
	*/
	case ifMatch = "If-Match"
	
	
	/**
	
	Allows a 304 Not Modified to be returned if content is unchanged
	
	*/
	case ifModifiedSince = "If-Modified-Since"
	
	
	/**
	
	Allows a 304 Not Modified to be returned if content is unchanged, see [HTTP ETag](https://en.wikipedia.org/wiki/HTTP_ETag)
	
	*/
	case ifNoneMatch = "If-None-Match"
	
	
	/**
	
	If the entity is unchanged, send me the part(s) that I am missing; 
	otherwise, send me the entire new entity
	
	*/
	case ifRange = "If-Range"
	
	
	/**
	
	Only send the response if the entity has not been modified since a specific time.
	
	*/
	case ifUnmodifiedSince = "If-Unmodified-Since"
	
	
	/**
	
	Limit the number of times the message can be forwarded through proxies or gateways.
	
	*/
	case maxForwards = "Max-Forwards"
	
	
	/**
	
	Initiates a request for [cross-origin resource sharing](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing)
	(asks server for an 'Access-Control-Allow-Origin' response field).
	
	*/
	case origin = "Origin"
	
	
	/**
	
	Implementation-specific fields that may have various effects anywhere along the request-response chain.
	
	*/
	case pragma = "Pragma"
	
	
	/**
	
	Authorization credentials for connecting to a proxy.
	
	*/
	case proxyAuthorization = "Proxy-Authorization"
	
	
	/**
	
	Request only part of an entity. Bytes are numbered from 0. 
	See [Byte serving](https://en.wikipedia.org/wiki/Byte_serving).
	
	*/
	case range = "Range"
	
	
	/**
	
	This is the address of the previous web page from which a link to the currently requested page was followed. 
	
	(The word “referrer” has been misspelled in the RFC 
	as well as in most implementations to the point that it has become standard usage
	and is considered correct terminology)
	
	*/
	case referer = "Referer"
	
	
	/**
	
	The transfer encodings the user agent is willing to accept: 
	the same values as for the response header field Transfer-Encoding can be used,
	plus the "trailers" value (related to the "chunked" transfer method) 
	to notify the server it expects to receive additional fields
	in the trailer after the last, zero-sized, chunk.
	
	*/
	case transferEncoding = "TE"
	
	
	/**
	
	The user agent string of the user agent
	
	*/
	case userAgent = "User-Agent"
	
	
	/**
	
	Ask the server to upgrade to another protocol.
	
	*/
	case upgrade = "Upgrade"
	
	
	/**
	
	Informs the server of proxies through which the request was sent.
	
	*/
	case via = "Via"
	
	
	/**
	
	A general warning about possible problems with the entity body.
	
	*/
	case warning = "Warning"
	
	
	// Non standard request headers (X-Headers)
	
	/**
	
	Mainly used to identify Ajax requests. 
	Most JavaScript frameworks send this field with value of XMLHttpRequest
	
	*/
	case x_RequestedWith = "X-Requested-With"
	
	
	/**
	
	Requests a web application to disable their tracking of a user.
	
	*/
	case doNotTrack = "DNT"
	
	
	/**
	
	A de facto standard for identifying the originating IP address 
	of a client connecting to a web server through an HTTP proxy or load balancer
	
	*/
	case x_ForwardedFor = "X-Forwarded-For"
	
	
	/**
	
	a de facto standard for identifying the original host 
	requested by the client in the Host HTTP request header, 
	since the host name and/or port of the reverse proxy (load balancer) 
	may differ from the origin server handling the request.
	
	*/
	case x_ForwardedHost = "X-Forwarded-Host"
	
	
	/**
	
	a de facto standard for identifying the originating protocol of an HTTP request, 
	since a reverse proxy (or a load balancer) may communicate 
	with a web server using HTTP even if the request to the reverse proxy is HTTPS. 
	An alternative form of the header (X-ProxyUser-Ip) 
	is used by Google clients talking to Google servers.
	
	*/
	case x_ForwardedProto = "X-Forwarded-Proto"
	
	
	/**
	
	Non-standard header field used by Microsoft applications and load-balancers
	
	*/
	case frontEndHttps = "Front-End-Https"
	
	
	/**
	
	Requests a web application override the method specified in the request (typically POST) 
	with the method given in the header field (typically PUT or DELETE). 
	Can be used when a user agent or firewall prevents 
	PUT or DELETE methods from being sent directly 
	
	(note that this either a bug in the software component, 
	which ought to be fixed, or an intentional configuration, 
	in which case bypassing it may be the wrong thing to do).
	
	*/
	case x_HTTPMethodOverride = "X-HTTP-Method-Override"
	
	
	/**
	
	Allows easier parsing of the MakeModel/Firmware 
	that is usually found in the User-Agent String of AT&T Devices
	
	*/
	case x_AttDeviceid = "X-Att-Deviceid"
	
	
	/**
	
	Links to an XML file on the Internet with a full description and details 
	about the device currently connecting.
	
	*/
	case x_WapProfile = "x-wap-profile"
	
	
	/**
	
	Implemented as a misunderstanding of the HTTP specifications. 
	Common because of mistakes in implementations of early HTTP versions. 
	Has exactly the same functionality as standard Connection field.
	
	*/
	case proxyConnection = "Proxy-Connection"
	
	
	/**
	
	Server-side deep packet insertion of a unique ID identifying customers of Verizon Wireless; 
	also known as "perma-cookie" or "supercookie"
	
	*/
	case x_UIDH = "X-UIDH"
	
	
	/**
	
	Used to prevent cross-site request forgery. Alternative header names are: X-CSRFToken and X-XSRF-TOKEN
	
	*/
	case x_CsrfToken = "X-Csrf-Token"
	
	
	static func `for`(name: String) -> HTTPRequestHeaderField!
	{
		let fields:[HTTPRequestHeaderField] =
			[.accept,
			 .acceptCharset,
			 .acceptDatetime,
			 .acceptEncoding,
			 .acceptLanguage,
			 .authorization,
			 .cacheControl,
			 .connection,
			 .contentLength,
			 .contentMD5,
			 .contentType,
			 .cookie,
			 .date,
			 .doNotTrack,
			 .expect,
			 .forwarded,
			 .from,
			 .frontEndHttps,
			 .host,
			 .ifMatch,
			 .ifRange,
			 .ifNoneMatch,
			 .ifModifiedSince,
			 .ifUnmodifiedSince,
			 .maxForwards,
			 .origin,
			 .pragma,
			 .proxyAuthorization,
			 .proxyConnection,
			 .range,
			 .referer,
			 .transferEncoding,
			 .upgrade,
			 .userAgent,
			 .via,
			 .warning,
			 .x_AttDeviceid,
			 .x_CsrfToken,
			 .x_ForwardedFor,
			 .x_ForwardedHost,
			 .x_ForwardedProto,
			 .x_HTTPMethodOverride,
			 .x_RequestedWith,
			 .x_UIDH,
			 .x_WapProfile]
		
		let namedFields = fields.map{($0.rawValue, $0)}
		
		var dict:[String: HTTPRequestHeaderField] = [:]
		for (name, field) in namedFields
		{
			dict[name.lowercased()] = field
		}
		//HTTP Header Fields are case insensitive.
		return dict[name.lowercased()]
		
	}
}


/**

HTTP Header fields for Server Responses

*/
public enum HTTPResponseHeaderField: String
{
	
	/**
	
	Specifying which web sites can participate in cross-origin resource sharing
	
	*/
	case accessControlAllowOrigin = "Access-Control-Allow-Origin"
	
	
	/**
	
	Specifies which patch document formats this server supports
	
	*/
	case acceptPatch = "Accept-Patch"
	
	
	/**
	
	What partial content range types this server supports via byte serving
	
	*/
	case acceptRanges = "Accept-Ranges"
	
	
	/**
	
	The age the object has been in a proxy cache in seconds
	
	*/
	case age = "Age"
	
	
	/**
	
	Valid actions for a specified resource. To be used for a 405 Method not allowed
	
	*/
	case allow = "Allow"
	
	
	/**
	
	A server uses "Alt-Svc" header (meaning Alternative Services) 
	to indicate that its resources can also be accessed at a different network location
	(host or port) or using a different protocol
	
	*/
	case altSvc = "Alt-Svc"
	
	
	/**
	
	Tells all caching mechanisms from server to client 
	whether they may cache this object. 
	
	It is measured in seconds
	
	*/
	case cacheControl = "Cache-Control"
	
	
	/**
	
	Control options for the current connection and list of hop-by-hop response fields
	
	*/
	case connection = "Connection"
	
	
	/**
	
	An opportunity to raise a "File Download" dialogue box 
	for a known MIME type with binary format or suggest a filename for dynamic content.
	
	*/
	case contentDisposition = "Content-Disposition"
	
	
	/**
	
	The type of encoding used on the data. See [HTTP compression](https://en.wikipedia.org/wiki/HTTP_compression).
	
	*/
	case contentEncoding = "Content-Encoding"
	
	
	/**
	
	The natural language or languages of the intended audience for the enclosed content
	
	*/
	case contentLanguage = "Content-Language"
	
	
	/**
	
	The length of the response body in octets (8-bit bytes)
	
	*/
	case contentLength = "Content-Length"
	
	
	/**
	
	An alternate location for the returned data
	
	*/
	case contentLocation = "Content-Location"
	
	
	/**
	
	A Base64-encoded binary MD5 sum of the content of the response
	
	*/
	@available(*, introduced: 0.1, deprecated: 0.1)
	case contentMD5 = "Content-MD5"
	
	
	/**
	
	Where in a full body message this partial message belongs
	
	*/
	case contentRange = "Content-Range"
	
	
	/**
	
	The MIME type of this content
	
	*/
	case contentType = "Content-Type"
	
	
	/**
	
	The date and time that the message was sent (in "HTTP-date" format as defined by RFC 7231)
	
	*/
	case date = "Date"
	
	
	/**
	
	An identifier for a specific version of a resource, often a message digest
	
	*/
	case eTag = "ETag"
	
	
	/**
	
	Gives the date/time after which the response is considered stale 
	(in "HTTP-date" format as defined by RFC 7231)
	
	*/
	case expires = "Expires"
	
	
	/**
	
	The last modified date for the requested object 
	(in "HTTP-date" format as defined by RFC 7231)
	
	*/
	case lastModified = "Last-Modified"
	
	
	/**
	
	Used to express a typed relationship with another resource, 
	where the relation type is defined by RFC 5988
	
	*/
	case link = "Link"
	
	
	/**
	
	Used in redirection, or when a new resource has been created.
	
	*/
	case location = "Location"
	
	
	/**
	
	This field is supposed to set P3P policy, 
	in the form of P3P:CP="your_compact_policy".
	
	*/
	case p3p = "P3P"
	
	
	/**
	
	Implementation-specific fields that may have various effects 
	anywhere along the request-response chain.
	
	*/
	case pragma = "Pragma"
	
	
	/**
	
	Request authentication to access the proxy.
	
	*/
	case proxyAuthenticate = "Proxy-Authenticate"
	
	
	/**
	
	HTTP Public Key Pinning, announces hash of website's authentic TLS certificate
	
	*/
	case publicKeyPins = "Public-Key-Pins"
	
	
	/**
	
	Used in redirection, or when a new resource has been created.
	
	*/
	case refresh = "Refresh"
	
	
	/**
	
	If an entity is temporarily unavailable, this instructs the client to try again later.
	Value could be a specified period of time (in seconds) or a HTTP-date.
	
	*/
	case retryAfter = "Retry-After"
	
	
	/**
	
	A name for the server
	
	*/
	case server = "Server"
	
	
	/**
	
	An HTTP cookie
	
	*/
	case setCookie = "Set-Cookie"
	
	
	/**
	
	CGI header field specifying the status of the HTTP response. 
	Normal HTTP responses use a separate "Status-Line" instead, defined by RFC 7230.
	
	*/
	case status = "Status"
	
	
	/**
	
	A HSTS Policy informing the HTTP client how long to cache the HTTPS only policy 
	and whether this applies to subdomains.
	
	*/
	case strictTransportSecurity = "Strict-Transport-Security"
	
	
	/**
	
	The Trailer general field value indicates that the given set of header fields
	is present in the trailer of a message encoded with chunked transfer coding.
	
	*/
	case trailer = "Trailer"
	
	
	/**
	
	The form of encoding used to safely transfer the entity to the user. 
	Currently defined methods are: chunked, compress, deflate, gzip, identity.
	
	*/
	case transferEncoding = "Transfer-Encoding"
	
	
	/**
	
	Tracking Status Value, value suggested to be sent in response to a DNT(do-not-track)
	
	*/
	case tsv = "TSV"
	
	
	/**
	
	Ask the client to upgrade to another protocol.
	
	*/
	case upgrade = "Upgrade"
	
	
	/**
	
	Tells downstream proxies how to match future request headers
	to decide whether the cached response can be used
	rather than requesting a fresh one from the origin server.
	
	*/
	case vary = "Vary"
	
	
	/**
	
	Informs the client of proxies through which the response was sent.
	
	*/
	case via = "Via"
	
	
	/**
	
	A general warning about possible problems with the entity body.
	
	*/
	case warning = "Warning"
	
	
	/**
	
	Indicates the authentication scheme that should be used to access the requested entity.
	
	*/
	case wwwAuthenticate = "WWW-Authenticate"
	
	
	/**
	
	Clickjacking protection
	
	*/
	@available(*, introduced: 0.1, deprecated: 0.1)
	case x_FrameOptions = "X-Frame-Options"
	
	
	// Non standard request headers (X-Headers)
	
	/**
	
	Cross-site scripting (XSS) filter
	
	*/
	case x_XSSProtection = "X-XSS-Protection"
	
	
	/**
	
	Content Security Policy definition.
	
	*/
	case x_WebKitCSP = "X-WebKit-CSP"
	
	
	/**
	
	The only defined value, "nosniff", 
	prevents Internet Explorer from MIME-sniffing a response away from the declared content-type. 
	This also applies to Google Chrome, when downloading extensions.
	
	*/
	case x_ContentTypeOptions = "X-Content-Type-Options"
	
	
	/**
	
	Specifies the technology (e.g. ASP.NET, PHP, JBoss) supporting the web application
	
	*/
	case x_PoweredBy = "X-Powered-By"
	
	
	/**
	
	Recommends the preferred rendering engine (often a backward-compatibility mode) 
	to use to display the content.
 
	Also used to activate Chrome Frame in Internet Explorer.
	
	*/
	case x_UACompatible = "X-UA-Compatible"
	
	
	/**
	
	Provide the duration of the audio or video in seconds;
 
	only supported by Gecko browsers
	
	*/
	case x_ContentDuration = "X-Content-Duration"
	
	
	/**
	
	Tells a server which (presumably in the middle of a HTTP -> HTTPS migration) 
	hosts mixed content that the client would prefer redirection to HTTPS
	and can handle Content-Security-Policy: upgrade-insecure-requests
	
	*/
	case upgradeInsecureRequests = "Upgrade-Insecure-Requests"
	
	
	/**
	
	Correlates HTTP requests between a client and server.
	
	*/
	case x_RequestID = "X-Request-ID"
}


/**

Response Codes for HTTP responses.

- **1XX**: Informational Responses

- **2XX**: Success Responses

- **3XX**: Redirect Responses

- **4XX**: Client Error Responses

- **5XX**: Server Error Responses

*/
public enum HTTPStatusCode : String
{
	//1XX - Informational
	
	/**

	The server has received the request headers and the client 
	should proceed to send the request body 
	(in the case of a request for which a body needs to be sent; for example, a POST request). 
	
	Sending a large request body to a server after a request has been rejected
	for inappropriate headers would be inefficient. 
	To have a server check the request's headers, 
	a client must send Expect: 100-continue as a header in its 
	initial request and receive a 100 Continue status code in response before sending the body. 
	The response 417 Expectation Failed indicates the request should not be continued
	
	*/
	case `continue` = "100 Continue"
	
	
	/**
	
	The requester has asked the server to switch protocols and the server has agreed to do so.
	
	*/
	case switchingProtocols = "101 Switching Protocols"
	
	
	/**
	
	A WebDAV request may contain many sub-requests involving file operations, 
	requiring a long time to complete the request. 
	
	This code indicates that the server has received and is processing the request, 
	but no response is available yet.
 
	This prevents the client from timing out and assuming the request was lost.
	
	*/
	case processing = "102 Processing"
	
	
	//2XX - Success
	
	/**
	
	Standard response for successful HTTP requests. 
	
	The actual response will depend on the request method used. 
	
	- In a GET request, the response will contain an entity corresponding to the requested resource.
	- In a POST request, the response will contain an entity describing or containing the result of the action.
	
	*/
	case ok = "200 OK"
	
	
	/**
	
	The request has been fulfilled, resulting in the creation of a new resource.
	
	*/
	case created = "201 Created"
	
	
	/**
	
	The request has been accepted for processing, but the processing has not been completed. 
	The request might or might not be eventually acted upon, 
	and may be disallowed when processing occurs.
	
	*/
	case accepted = "202 Accepted"
	
	
	/**
	
	The server is a transforming proxy (e.g. a Web accelerator) that received a 200 OK from its origin, 
	but is returning a modified version of the origin's response.
	
	*/
	case nonAuthoritativeInformation = "203 Non-Authoritative Information"
	
	
	/**
	
	The server successfully processed the request and is not returning any content.
	
	*/
	case noContent = "204 No Content"
	
	
	/**
	
	The server successfully processed the request, but is not returning any content. 
	Unlike a 204 response, this response requires that the requester reset the document view.
	
	*/
	case resetContent = "205 Reset Content"
	
	
	/**
	
	The server is delivering only part of the resource (byte serving) 
	due to a range header sent by the client.
	
	The range header is used by HTTP clients to enable resuming of interrupted downloads, 
	or split a download into multiple simultaneous streams.
	
	*/
	case partialContent = "206 Partial Content"
	
	
	/**
	
	The message body that follows is an XML message and can contain
	a number of separate response codes,
	depending on how many sub-requests were made.
	
	*/
	case multiStatus = "207 Multi-Status"
	
	
	/**
	
	The members of a DAV binding have already been enumerated in a previous reply to this request, 
	and are not being included again.
	
	*/
	case alreadyReported = "208 Already Reported"
	
	
	/**
	
	The server has fulfilled a request for the resource, 
	and the response is a representation of the result of 
	one or more instance-manipulations applied to the current instance.
	
	*/
	case imUsed = "226 IM Used"
	
	
	//3XX - Redirect
	
	/**
	
	Indicates multiple options for the resource from which the client may choose. 
	
	For example, this code could be used to present multiple video format options, 
	to list files with different extensions, or to suggest word sense disambiguation.
	
	*/
	case multipleChoices = "300 Multiple Choices"
	
	
	/**
	
	This and all future requests should be directed to the given URI.
	
	*/
	case movedPermanently = "301 Moved Permanently"
	
	
	/**
	
	The HTTP/1.0 specification (RFC 1945) required the client to perform a temporary redirect 
	(the original describing phrase was "Moved Temporarily"),
	but popular browsers implemented 302 with the functionality of a 303 See Other. 
	Therefore, HTTP/1.1 added status codes 303 and 307 to distinguish between the two behaviours.
	
	However, some Web applications and frameworks use the 302 status code as if it were the 303.
	
	*/
	case found = "302 Found"
	
	
	/**
	
	The response to the request can be found under another URI using a GET method. 
	
	When received in response to a POST (or PUT/DELETE), 
	the client should presume that the server has received the data and should issue 
	a redirect with a separate GET message.
	
	*/
	case seeOther = "303 See Other"
	
	
	/**
	
	Indicates that the resource has not been modified since 
	the version specified by the request headers If-Modified-Since or If-None-Match. 
	
	In such case, there is no need to retransmit the resource since 
	the client still has a previously-downloaded copy.
	
	*/
	case notModified = "304 Not Modified"
	
	
	/**
	
	The requested resource is available only through a proxy, 
	the address for which is provided in the response. 
	
	Many HTTP clients (such as Mozilla and Internet Explorer) do not correctly handle 
	responses with this status code, primarily for security reasons.
	
	*/
	case useProxy = "305 Use Proxy"
	
	
	/**
	
	No longer used. Originally meant "Subsequent requests should use the specified proxy."
	
	*/
	@available(*, deprecated: 0.1)
	case switchProxy = "306 Switch Proxy"
	
	
	/**
	
	In this case, the request should be repeated with another URI; however, 
	future requests should still use the original URI. 
	In contrast to how 302 was historically implemented, 
	the request method is not allowed to be changed when reissuing the original request. 
	
	For example, a POST request should be repeated using another POST request.
	
	*/
	case temporaryRedirect = "307 Temporary Redirect"
	
	
	/**
	
	The request and all future requests should be repeated using another URI. 
	307 and 308 parallel the behaviours of 302 and 301, but do not allow the HTTP method to change. 
	So, for example, submitting a form to a permanently redirected resource may continue smoothly.
	
	*/
	case permanentRedirect = "308 Permanent Redirect"
	
	
	//4XX - Client Error
	
	/**
	
	The server cannot or will not process the request due to an apparent client error 
	(e.g., malformed request syntax, invalid request message framing, or deceptive request routing).
	
	*/
	case badRequest = "400 Bad Request"
	
	
	/**
	
	Similar to 403 Forbidden, but specifically for use when authentication is required 
	and has failed or has not yet been provided.
	The response must include a WWW-Authenticate header field containing 
	a challenge applicable to the requested resource. 
	
	401 semantically means "unauthenticated", i.e. the user does not have the necessary credentials.
	
	Note: Some sites issue HTTP 401 when an IP address is banned from the website 
	(usually the website domain) and that specific address is refused permission to access a website.
	
	*/
	case unauthorized = "401 Unauthorized"
	
	
	/**
	
	Reserved for future use. The original intention was that this code 
	might be used as part of some form of digital cash or micropayment scheme, 
	but that has not happened, and this code is not usually used. 
	Google Developers API uses this status if a particular developer has exceeded the daily limit on requests.
	
	*/
	case paymentRequired = "402 Payment Required"
	
	
	/**
	
	The request was a valid request, but the server is refusing to respond to it. 
	403 error semantically means "unauthorized", i.e. the user does not have 
	the necessary permissions for the resource.
	
	*/
	case forbidden = "403 Forbidden"
	
	
	/**
	
	The requested resource could not be found but may be available in the future. 
	Subsequent requests by the client are permissible.
	
	*/
	case notFound = "404 Not Found"
	
	
	/**
	
	A request method is not supported for the requested resource; for example, 
	a GET request on a form which requires data to be presented via POST, 
	or a PUT request on a read-only resource.
	
	*/
	case methodNotAllowed = "405 Method Not Allowed"
	
	
	/**
	
	The requested resource is capable of generating only content 
	not acceptable according to the Accept headers sent in the request.
	
	*/
	case notAcceptable = "406 Not Acceptable"
	
	
	/**
	
	The client must first authenticate itself with the proxy.
	
	*/
	case proxyAuthenticationRequired = "407 Proxy Authentication Required"
	
	
	/**
	
	The server timed out waiting for the request. 
	
	According to HTTP specifications: 
	"The client did not produce a request within the time that the server was prepared to wait. 
	The client MAY repeat the request without modifications at any later time."
	
	*/
	case requestTimeout = "408 Request Timeout"
	
	
	/**
	
	Indicates that the request could not be processed because of conflict in the request, 
	such as an edit conflict between multiple simultaneous updates.
	
	*/
	case conflict = "409 Conflict"
	
	
	/**
	
	Indicates that the resource requested is no longer available and will not be available again. 
	This should be used when a resource has been intentionally removed and the resource should be purged. 
	Upon receiving a 410 status code, the client should not request the resource in the future. 
	Clients such as search engines should remove the resource from their indices.
	Most use cases do not require clients and search engines to purge the resource, 
	and a "404 Not Found" may be used instead.
	
	*/
	case gone = "410 Gone"
	
	
	/**
	
	The request did not specify the length of its content, 
	which is required by the requested resource.
	
	*/
	case lengthRequired = "411 Length Required"
	
	
	/**
	
	The server does not meet one of the preconditions that the requester put on the request.
	
	*/
	case preconditionFailed = "412 Precondition Failed"
	
	
	/**
	
	The request is larger than the server is willing or able to process. 
	Previously called "Request Entity Too Large".
	
	*/
	case payloadTooLarge = "413 Payload Too Large"
	
	
	/**
	
	The URI provided was too long for the server to process. 
	Often the result of too much data being encoded as a query-string of a GET request, 
	in which case it should be converted to a POST request.
	
	Called "Request-URI Too Long" previously.
	
	*/
	case uriTooLong = "414 URI Too Long"
	
	
	/**
	
	The request entity has a media type which the server or resource does not support. 
	For example, the client uploads an image as image/svg+xml, 
	but the server requires that images use a different format.
	
	*/
	case unsupportedMediaType = "415 Unsupported Media Type"
	
	
	/**
	
	The client has asked for a portion of the file (byte serving),
	but the server cannot supply that portion. 
	
	For example, if the client asked for a part of the file that lies beyond the end of the file.
	
	Called "Requested Range Not Satisfiable" previously.
	
	*/
	case rangeNotSatisfiable = "416 Range Not Satisfiable"
	
	
	/**
	
	The server cannot meet the requirements of the Expect request-header field.
	
	*/
	case expectationFailed = "417 Expectation Failed"
	
	
	/**
	
	Used in Hyper Text Coffee Pot Control Protocol (HTCPCP).
	
	Should be returned by tea pots requested to brew coffee.
	
	*/
	case imATeapot = "418 I'm a teapot"
	
	
	/**
	
	The request was directed at a server that is not able to produce a response 
	(for example because a connection reuse).
	
	*/
	case misdirectedRequest = "421 Misdirected Request"
	
	
	/**
	
	The request was well-formed but was unable to be followed due to semantic errors.
	
	*/
	case unprocessableEntity = "422 Unprocessable Entity"
	
	
	/**
	
	The resource that is being accessed is locked.
	
	*/
	case locked = "423 Locked"
	
	
	/**
	
	The request failed due to failure of a previous request (e.g., a PROPPATCH).
	
	*/
	case failedDependency = "424 Failed Dependency"
	
	
	/**
	
	The client should switch to a different protocol such as TLS/1.0, 
	given in the Upgrade header field.
	
	*/
	case upgradeRequired = "426 Upgrade Required"
	
	
	/**
	
	The origin server requires the request to be conditional. 
	
	Intended to prevent "the 'lost update' problem, 
	where a client GETs a resource's state, modifies it, 
	and PUTs it back to the server, 
	when meanwhile a third party has modified the state on the server, 
	leading to a conflict."
	
	*/
	case preconditionRequired = "428 Precondition Required"
	
	
	/**
	
	The user has sent too many requests in a given amount of time. 
	
	Intended for use with rate limiting schemes.
	
	*/
	case tooManyRequests = "429 Too Many Requests"
	
	
	/**
	
	The server is unwilling to process the request because either an individual header field, 
	or all the header fields collectively, are too large.
	
	*/
	case requestHeaderFieldsTooLarge = "431 Request Header Fields Too Large"
	
	
	/**
	
	A server operator has received a legal demand to deny access to a resource 
	or to a set of resources that includes the requested resource.
	
	The code 451 was chosen as a reference to the novel Fahrenheit 451.
	
	*/
	case unavailableForLegalReasons = "451 Unavailable For Legal Reasons"
	
	
	//5XX - Server Error
	
	/**
	
	A generic error message, given when an unexpected condition 
	was encountered and no more specific message is suitable.
	
	*/
	case internalServerError = "500 Internal Server Error"
	
	
	/**
	
	The server either does not recognize the request method, 
	or it lacks the ability to fulfill the request. 
	
	Usually this implies future availability (e.g., a new feature of a web-service API).
	
	*/
	case notImplemented = "501 Not Implemented"
	
	
	/**
	
	The server was acting as a gateway or proxy and 
	received an invalid response from the upstream server.
	
	*/
	case badGateway = "502 Bad Gateway"
	
	
	/**
	
	The server is currently unavailable (because it is overloaded or down for maintenance).
	Generally, this is a temporary state.
	
	*/
	case serviceUnavailable = "503 Service Unavailable"
	
	
	/**
	
	The server was acting as a gateway or proxy and did not receive 
	a timely response from the upstream server.
	
	*/
	case gatewayTimeout = "504 Gateway Timeout"
	
	
	/**
	
	The server does not support the HTTP protocol version used in the request.
	
	*/
	case httpVersionNotSupported = "505 HTTP Version Not Supported"
	
	
	/**
	
	Transparent content negotiation for the request results in a circular reference.
	
	*/
	case variantAlsoNegotiates = "506 Variant Also Negotiates"
	
	
	/**
	
	The server is unable to store the representation needed to complete the request.
	
	*/
	case insufficientStorage = "507 Insufficient Storage"
	
	
	/**
	
	The server detected an infinite loop while processing the request 
	(sent in lieu of 208 Already Reported).
	
	*/
	case loopDetected = "508 Loop Detected"
	
	
	/**
	
	Further extensions to the request are required for the server to fulfil it.
	
	*/
	case notExtended = "510 Not Extended"
	
	
	/**
	
	The client needs to authenticate to gain network access. 
	
	Intended for use by intercepting proxies used to control access to the network
	(e.g., "captive portals" used to require agreement to Terms of Service 
	before granting full Internet access via a Wi-Fi hotspot).
	
	*/
	case networkAuthenticationRequired = "511 Network Authentication Required"
	
}


public enum HTTPMethod: String
{
	case get = "GET"
	case put = "PUT"
	case post = "POST"
	case head = "HEAD"
	case delete = "DELETE"
	case options = "OPTIONS"
	case connect = "CONNECT"
}


