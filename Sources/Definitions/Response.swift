//
//  Created by Marko Justinek on 31/3/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
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

/// An object representing an API response for a Pact test.
public struct Response {

	var statusCode: Int
	var headers: [String: Any]?

	private let bodyEncoder: (Encoder) throws -> Void

}

extension Response: Encodable {

	enum CodingKeys: String, CodingKey {
		case statusCode = "status"
		case headers
		case body
		case matchingRules
		case generators
	}

	/// Creates an object representing a network `Response`.
	/// - Parameters:
	///   - statusCode: The status code of the API response
	///   - headers: Headers of the API response
	///   - body: Optional body in the API response
	///
	init(statusCode: Int, headers: [String: Any]? = nil, body: Any? = nil) throws {
		self.statusCode = statusCode
		self.headers = headers

		let bodyValues = try Toolbox.process(element: body, for: .body)
		let headerValues = try Toolbox.process(element: headers, for: .header)

		self.bodyEncoder = {
			var container = $0.container(keyedBy: CodingKeys.self)
			try container.encode(statusCode, forKey: .statusCode)
			if let header = headerValues?.node { try container.encode(header, forKey: .headers) }
			if let encodableBody = bodyValues?.node { try container.encode(encodableBody, forKey: .body) }
			if let matchingRules = Toolbox.merge(body: bodyValues?.rules, header: headerValues?.rules) {
				try container.encode(matchingRules, forKey: .matchingRules)
			}
			if let generators = Toolbox.merge(body: bodyValues?.generators, header: headerValues?.generators) {
				try container.encode(generators, forKey: .generators)
			}
		}
	}

	public func encode(to encoder: Encoder) throws {
		try bodyEncoder(encoder)
	}

}
