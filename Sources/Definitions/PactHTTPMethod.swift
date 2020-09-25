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

import Foundation

/// The HTTP method expected in the interaction
@objc public enum PactHTTPMethod: Int {

	case GET
	case HEAD
	case POST
	case PUT
	case PATCH
	case DELETE
	case TRACE
	case CONNECT
	case OPTIONS

	var method: String {
		switch self {
		case .GET: return "get"
		case .HEAD: return "head"
		case .POST: return "post"
		case .PUT: return "put"
		case .PATCH: return "patch"
		case .DELETE: return "delete"
		case .TRACE: return "trace"
		case .CONNECT: return "connect"
		case .OPTIONS: return "options"
		}
	}

}

extension PactHTTPMethod: Encodable {

	enum CodingKeys: CodingKey {
		case method
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(method)
	}

}
