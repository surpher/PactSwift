//
//  Created by Marko Justinek on 6/4/20.
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

struct AnyEncodable: Encodable {

	private let _encode: (Encoder) throws -> Void

	init<T: Encodable>(_ value: T) {
		self._encode = { encoder in
			var container = encoder.singleValueContainer()

			// This is not the greatest of ways to handle an optional value that should be presented as `null` in JSON.
			// Unfortunately using generics and optionals here do not play nicely where `AnyEncodable(nil)` will not be allowed by Swift.
			// Force casting the `Matcher.MatchNull().value` to a String should fail catastrophically at PactSwift unit tests level if type is changed.
			if let value = value as? String, value == Matcher.MatchNull().value as! String {
				try container.encodeNil()
				return
			}

			try container.encode(value)
		}
	}

	func encode(to encoder: Encoder) throws {
		try _encode(encoder)
	}

}
