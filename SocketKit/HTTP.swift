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
internal let HTTPDateFormatter:NSDateFormatter =
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
	@available(*, introduced=0.1, deprecated=0.1)
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
	@available(*, introduced=0.1, deprecated=0.1)
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
	@available(*, introduced=0.1, deprecated=0.1)
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
	case Continue = "100 Continue"
	
	
	/**
	
	The requester has asked the server to switch protocols and the server has agreed to do so.
	
	*/
	case SwitchingProtocols = "101 Switching Protocols"
	
	
	/**
	
	A WebDAV request may contain many sub-requests involving file operations, 
	requiring a long time to complete the request. 
	
	This code indicates that the server has received and is processing the request, 
	but no response is available yet.
 
	This prevents the client from timing out and assuming the request was lost.
	
	*/
	case Processing = "102 Processing"
	
	
	//2XX - Success
	
	/**
	
	Standard response for successful HTTP requests. 
	
	The actual response will depend on the request method used. 
	
	- In a GET request, the response will contain an entity corresponding to the requested resource.
	- In a POST request, the response will contain an entity describing or containing the result of the action.
	
	*/
	case OK = "200 OK"
	
	
	/**
	
	The request has been fulfilled, resulting in the creation of a new resource.
	
	*/
	case Created = "201 Created"
	
	
	/**
	
	The request has been accepted for processing, but the processing has not been completed. 
	The request might or might not be eventually acted upon, 
	and may be disallowed when processing occurs.
	
	*/
	case Accepted = "202 Accepted"
	
	
	/**
	
	The server is a transforming proxy (e.g. a Web accelerator) that received a 200 OK from its origin, 
	but is returning a modified version of the origin's response.
	
	*/
	case NonAuthoritativeInformation = "203 Non-Authoritative Information"
	
	
	/**
	
	The server successfully processed the request and is not returning any content.
	
	*/
	case NoContent = "204 No Content"
	
	
	/**
	
	The server successfully processed the request, but is not returning any content. 
	Unlike a 204 response, this response requires that the requester reset the document view.
	
	*/
	case ResetContent = "205 Reset Content"
	
	
	/**
	
	The server is delivering only part of the resource (byte serving) 
	due to a range header sent by the client.
	
	The range header is used by HTTP clients to enable resuming of interrupted downloads, 
	or split a download into multiple simultaneous streams.
	
	*/
	case PartialContent = "206 Partial Content"
	
	
	/**
	
	The message body that follows is an XML message and can contain
	a number of separate response codes,
	depending on how many sub-requests were made.
	
	*/
	case MultiStatus = "207 Multi-Status"
	
	
	/**
	
	The members of a DAV binding have already been enumerated in a previous reply to this request, 
	and are not being included again.
	
	*/
	case AlreadyReported = "208 Already Reported"
	
	
	/**
	
	The server has fulfilled a request for the resource, 
	and the response is a representation of the result of 
	one or more instance-manipulations applied to the current instance.
	
	*/
	case IMUsed = "226 IM Used"
	
	
	//3XX - Redirect
	
	/**
	
	Indicates multiple options for the resource from which the client may choose. 
	
	For example, this code could be used to present multiple video format options, 
	to list files with different extensions, or to suggest word sense disambiguation.
	
	*/
	case MultipleChoices = "300 Multiple Choices"
	
	
	/**
	
	This and all future requests should be directed to the given URI.
	
	*/
	case MovedPermanently = "301 Moved Permanently"
	
	
	/**
	
	The HTTP/1.0 specification (RFC 1945) required the client to perform a temporary redirect 
	(the original describing phrase was "Moved Temporarily"),
	but popular browsers implemented 302 with the functionality of a 303 See Other. 
	Therefore, HTTP/1.1 added status codes 303 and 307 to distinguish between the two behaviours.
	
	However, some Web applications and frameworks use the 302 status code as if it were the 303.
	
	*/
	case Found = "302 Found"
	
	
	/**
	
	The response to the request can be found under another URI using a GET method. 
	
	When received in response to a POST (or PUT/DELETE), 
	the client should presume that the server has received the data and should issue 
	a redirect with a separate GET message.
	
	*/
	case SeeOther = "303 See Other"
	
	
	/**
	
	Indicates that the resource has not been modified since 
	the version specified by the request headers If-Modified-Since or If-None-Match. 
	
	In such case, there is no need to retransmit the resource since 
	the client still has a previously-downloaded copy.
	
	*/
	case NotModified = "304 Not Modified"
	
	
	/**
	
	The requested resource is available only through a proxy, 
	the address for which is provided in the response. 
	
	Many HTTP clients (such as Mozilla and Internet Explorer) do not correctly handle 
	responses with this status code, primarily for security reasons.
	
	*/
	case UseProxy = "305 Use Proxy"
	
	
	/**
	
	No longer used. Originally meant "Subsequent requests should use the specified proxy."
	
	*/
	@available(*, deprecated=0.1)
	case SwitchProxy = "306 Switch Proxy"
	
	
	/**
	
	In this case, the request should be repeated with another URI; however, 
	future requests should still use the original URI. 
	In contrast to how 302 was historically implemented, 
	the request method is not allowed to be changed when reissuing the original request. 
	
	For example, a POST request should be repeated using another POST request.
	
	*/
	case TemporaryRedirect = "307 Temporary Redirect"
	
	
	/**
	
	The request and all future requests should be repeated using another URI. 
	307 and 308 parallel the behaviours of 302 and 301, but do not allow the HTTP method to change. 
	So, for example, submitting a form to a permanently redirected resource may continue smoothly.
	
	*/
	case PermanentRedirect = "308 Permanent Redirect"
	
	
	//4XX - Client Error
	
	/**
	
	The server cannot or will not process the request due to an apparent client error 
	(e.g., malformed request syntax, invalid request message framing, or deceptive request routing).
	
	*/
	case BadRequest = "400 Bad Request"
	
	
	/**
	
	Similar to 403 Forbidden, but specifically for use when authentication is required 
	and has failed or has not yet been provided.
	The response must include a WWW-Authenticate header field containing 
	a challenge applicable to the requested resource. 
	
	401 semantically means "unauthenticated", i.e. the user does not have the necessary credentials.
	
	Note: Some sites issue HTTP 401 when an IP address is banned from the website 
	(usually the website domain) and that specific address is refused permission to access a website.
	
	*/
	case Unauthorized = "401 Unauthorized"
	
	
	/**
	
	Reserved for future use. The original intention was that this code 
	might be used as part of some form of digital cash or micropayment scheme, 
	but that has not happened, and this code is not usually used. 
	Google Developers API uses this status if a particular developer has exceeded the daily limit on requests.
	
	*/
	case PaymentRequired = "402 Payment Required"
	
	
	/**
	
	The request was a valid request, but the server is refusing to respond to it. 
	403 error semantically means "unauthorized", i.e. the user does not have 
	the necessary permissions for the resource.
	
	*/
	case Forbidden = "403 Forbidden"
	
	
	/**
	
	The requested resource could not be found but may be available in the future. 
	Subsequent requests by the client are permissible.
	
	*/
	case NotFound = "404 Not Found"
	
	
	/**
	
	A request method is not supported for the requested resource; for example, 
	a GET request on a form which requires data to be presented via POST, 
	or a PUT request on a read-only resource.
	
	*/
	case MethodNotAllowed = "405 Method Not Allowed"
	
	
	/**
	
	The requested resource is capable of generating only content 
	not acceptable according to the Accept headers sent in the request.
	
	*/
	case NotAcceptable = "406 Not Acceptable"
	
	
	/**
	
	The client must first authenticate itself with the proxy.
	
	*/
	case ProxyAuthenticationRequired = "407 Proxy Authentication Required"
	
	
	/**
	
	The server timed out waiting for the request. 
	
	According to HTTP specifications: 
	"The client did not produce a request within the time that the server was prepared to wait. 
	The client MAY repeat the request without modifications at any later time."
	
	*/
	case RequestTimeout = "408 Request Timeout"
	
	
	/**
	
	Indicates that the request could not be processed because of conflict in the request, 
	such as an edit conflict between multiple simultaneous updates.
	
	*/
	case Conflict = "409 Conflict"
	
	
	/**
	
	Indicates that the resource requested is no longer available and will not be available again. 
	This should be used when a resource has been intentionally removed and the resource should be purged. 
	Upon receiving a 410 status code, the client should not request the resource in the future. 
	Clients such as search engines should remove the resource from their indices.
	Most use cases do not require clients and search engines to purge the resource, 
	and a "404 Not Found" may be used instead.
	
	*/
	case Gone = "410 Gone"
	
	
	/**
	
	The request did not specify the length of its content, 
	which is required by the requested resource.
	
	*/
	case LengthRequired = "411 Length Required"
	
	
	/**
	
	The server does not meet one of the preconditions that the requester put on the request.
	
	*/
	case PreconditionFailed = "412 Precondition Failed"
	
	
	/**
	
	The request is larger than the server is willing or able to process. 
	Previously called "Request Entity Too Large".
	
	*/
	case PayloadTooLarge = "413 Payload Too Large"
	
	
	/**
	
	The URI provided was too long for the server to process. 
	Often the result of too much data being encoded as a query-string of a GET request, 
	in which case it should be converted to a POST request.
	
	Called "Request-URI Too Long" previously.
	
	*/
	case URITooLong = "414 URI Too Long"
	
	
	/**
	
	The request entity has a media type which the server or resource does not support. 
	For example, the client uploads an image as image/svg+xml, 
	but the server requires that images use a different format.
	
	*/
	case UnsupportedMediaType = "415 Unsupported Media Type"
	
	
	/**
	
	The client has asked for a portion of the file (byte serving),
	but the server cannot supply that portion. 
	
	For example, if the client asked for a part of the file that lies beyond the end of the file.
	
	Called "Requested Range Not Satisfiable" previously.
	
	*/
	case RangeNotSatisfiable = "416 Range Not Satisfiable"
	
	
	/**
	
	The server cannot meet the requirements of the Expect request-header field.
	
	*/
	case ExpectationFailed = "417 Expectation Failed"
	
	
	/**
	
	Used in Hyper Text Coffee Pot Control Protocol (HTCPCP).
	
	Should be returned by tea pots requested to brew coffee.
	
	*/
	case ImATeapot = "418 I'm a teapot"
	
	
	/**
	
	The request was directed at a server that is not able to produce a response 
	(for example because a connection reuse).
	
	*/
	case MisdirectedRequest = "421 Misdirected Request"
	
	
	/**
	
	The request was well-formed but was unable to be followed due to semantic errors.
	
	*/
	case UnprocessableEntity = "422 Unprocessable Entity"
	
	
	/**
	
	The resource that is being accessed is locked.
	
	*/
	case Locked = "423 Locked"
	
	
	/**
	
	The request failed due to failure of a previous request (e.g., a PROPPATCH).
	
	*/
	case FailedDependency = "424 Failed Dependency"
	
	
	/**
	
	The client should switch to a different protocol such as TLS/1.0, 
	given in the Upgrade header field.
	
	*/
	case UpgradeRequired = "426 Upgrade Required"
	
	
	/**
	
	The origin server requires the request to be conditional. 
	
	Intended to prevent "the 'lost update' problem, 
	where a client GETs a resource's state, modifies it, 
	and PUTs it back to the server, 
	when meanwhile a third party has modified the state on the server, 
	leading to a conflict."
	
	*/
	case PreconditionRequired = "428 Precondition Required"
	
	
	/**
	
	The user has sent too many requests in a given amount of time. 
	
	Intended for use with rate limiting schemes.
	
	*/
	case TooManyRequests = "429 Too Many Requests"
	
	
	/**
	
	The server is unwilling to process the request because either an individual header field, 
	or all the header fields collectively, are too large.
	
	*/
	case RequestHeaderFieldsTooLarge = "431 Request Header Fields Too Large"
	
	
	/**
	
	A server operator has received a legal demand to deny access to a resource 
	or to a set of resources that includes the requested resource.
	
	The code 451 was chosen as a reference to the novel Fahrenheit 451.
	
	*/
	case UnavailableForLegalReasons = "451 Unavailable For Legal Reasons"
	
	
	//5XX - Server Error
	
	/**
	
	A generic error message, given when an unexpected condition 
	was encountered and no more specific message is suitable.
	
	*/
	case InternalServerError = "500 Internal Server Error"
	
	
	/**
	
	The server either does not recognize the request method, 
	or it lacks the ability to fulfill the request. 
	
	Usually this implies future availability (e.g., a new feature of a web-service API).
	
	*/
	case NotImplemented = "501 Not Implemented"
	
	
	/**
	
	The server was acting as a gateway or proxy and 
	received an invalid response from the upstream server.
	
	*/
	case BadGateway = "502 Bad Gateway"
	
	
	/**
	
	The server is currently unavailable (because it is overloaded or down for maintenance).
	Generally, this is a temporary state.
	
	*/
	case ServiceUnavailable = "503 Service Unavailable"
	
	
	/**
	
	The server was acting as a gateway or proxy and did not receive 
	a timely response from the upstream server.
	
	*/
	case GatewayTimeout = "504 Gateway Timeout"
	
	
	/**
	
	The server does not support the HTTP protocol version used in the request.
	
	*/
	case HTTPVersionNotSupported = "505 HTTP Version Not Supported"
	
	
	/**
	
	Transparent content negotiation for the request results in a circular reference.
	
	*/
	case VariantAlsoNegotiates = "506 Variant Also Negotiates"
	
	
	/**
	
	The server is unable to store the representation needed to complete the request.
	
	*/
	case InsufficientStorage = "507 Insufficient Storage"
	
	
	/**
	
	The server detected an infinite loop while processing the request 
	(sent in lieu of 208 Already Reported).
	
	*/
	case LoopDetected = "508 Loop Detected"
	
	
	/**
	
	Further extensions to the request are required for the server to fulfil it.
	
	*/
	case NotExtended = "510 Not Extended"
	
	
	/**
	
	The client needs to authenticate to gain network access. 
	
	Intended for use by intercepting proxies used to control access to the network
	(e.g., "captive portals" used to require agreement to Terms of Service 
	before granting full Internet access via a Wi-Fi hotspot).
	
	*/
	case NetworkAuthenticationRequired = "511 Network Authentication Required"
	
}


public struct HTTPRequest : StreamReadable, StreamWritable
{
	public init(byReadingFrom stream: InputStream) throws
	{
		
	}
	
	public init()
	{
		
	}
	
	public func write(to outputStream: OutputStream) throws
	{
		
	}
}


/**

Basic HTTP response to a get request.

Sends the given data as content to the client

*/
public class HTTPResponse : StreamWritable, StreamReadable
{
	public let version:String
	public let status:String
	public var header:[String:String]
	
	public let content:NSData
	
	required public init(byReadingFrom stream: InputStream) throws
	{
		content = NSData()
		version = "HTTP/1.1"
		status = "200 OK"
		header = [:]
	}
	
	public init(with content: String)
	{
		self.content = content.dataUsingEncoding(NSUTF8StringEncoding)!
		version = "HTTP/1.1"
		status = "200 OK"
		header = [:]
	}
	
	public init(with content: NSData)
	{
		self.content = content
		version = "HTTP/1.1"
		status = "200 OK"
		header = [:]
	}
	
	public func write(to outputStream: OutputStream) throws
	{
		try outputStream.writeln("HTTP/1.1 200 OK")
		try outputStream.writeln("Date: \(HTTPDateFormatter.stringFromDate(NSDate()))")
		try outputStream.writeln("Server: PK-SocketKit/0.1a (OS X/Swift)")
		try outputStream.writeln("Last-Modified: \(HTTPDateFormatter.stringFromDate(NSDate()))")
		try outputStream.writeln("Accept-Ranges: bytes")
		try outputStream.writeln("Connection: close")
		try outputStream.writeln("Content-Type: text/html")
		try outputStream.writeln("Content-Length: \(content.length)")
		try outputStream.writeln()
		try outputStream.write(content)
		try outputStream.writeln()
	}
}