//
//  Created by Marko Justinek on 31/3/20.
//  Copyright © 2020 Itty Bitty Apps Pty Ltd / PACT Foundation. All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

/// An object representing an API request for a Pact test.
public struct Request {

	let httpMethod: PactHTTPMethod
	let path: String
	let query: [String: [String]]?
	let headers: [String: String]?
	let body: Any?

	var description: String {
		let request = "\(httpMethod.method.uppercased()) \(path)"
		let queryString = query?.compactMap { "\($0)=\($1.joined(separator: ","))" }.joined(separator: "&")
		let headersString = headers?.compactMap { "\"\($0)\": \"\($1)\"" }.joined(separator: "\n\t")

		return
			"\(request) \(queryString ?? "")\(headersString != nil ? "\n\n\tHeaders:\n\t" + headersString! : "")"
	}

	private let bodyEncoder: (Encoder) throws -> Void

}

extension Request: Encodable {

	enum CodingKeys: String, CodingKey {
		case httpMethod = "method"
		case path
		case query
		case headers
		case body
		case matchingRules
		case generators
	}

	/// Creates an object representing a network `Request`.
	///
	/// - Parameters:
	///   - method: The http method of the http request
	///   - path: A url path of the http reuquest (without the base url)
	///   - query: A url query
	///   - headers: Headers of the http reqeust
	///   - body: Optional body of the http request
	init(method: PactHTTPMethod, path: String, query: [String: [String]]? = nil, headers: [String: String]? = nil, body: Any? = nil) {
		self.httpMethod = method
		self.path = path
		self.query = query
		self.headers = headers
		self.body = body

		var pact: (body: AnyEncodable?, matchingRules: AnyEncodable?, generators: AnyEncodable?)

		if let body = body {
			do {
				let parsedPact = try PactBuilder(with: body).encoded(for: .body)
				pact = (body: parsedPact.node, matchingRules: parsedPact.rules, generators: parsedPact.generators)
			} catch {
				fatalError("Can not instantiate a `Request` with non-encodable `body`.")
			}
		}

		self.bodyEncoder = {
			var container = $0.container(keyedBy: CodingKeys.self)
			try container.encode(method, forKey: .httpMethod)
			try container.encode(path, forKey: .path)
			if let query = query { try container.encode(query, forKey: .query) }
			if let headers = headers { try container.encode(headers, forKey: .headers) }
			if let encodableBody = pact.body { try container.encode(encodableBody, forKey: .body) }
			if let matchingRules = pact.matchingRules { try container.encode(matchingRules, forKey: .matchingRules) }
			if let generators = pact.generators { try container.encode(generators, forKey: .generators) }
		}
	}

	public func encode(to encoder: Encoder) throws {
		try bodyEncoder(encoder)
	}

}
