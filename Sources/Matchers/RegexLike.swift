//
//  Created by Marko Justinek on 11/4/20.
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

public extension Matcher {

	/// Defines a Pact matcher that expects a value
	/// conforming to a `Regex` term.
	///
	/// Use this matcher where you expect a term defined
	/// by a regular expression term.
	///
	/// ```
	/// [
	///   "foo": Matcher.RegexLike("2020-04-27", term: "\d{4}-\d{2}-\d{2}")
	/// ]
	/// ```
	struct RegexLike: MatchingRuleExpressible {
		internal let value: Any
		internal let term: String

		internal var rules: [[String: AnyEncodable]] {
			[
				[
					"match": AnyEncodable("regex"),
					"regex": AnyEncodable(term),
				],
			]
		}

		// MARK: - Iitializer

		/// Defines a Pact matcher that expectes a value
		/// conforming to a `Regex` term.
		///
		/// - parameter value: The value MockService should expect or respond with
		/// - parameter term: The regex term that the `value` conforms to
		public init(_ value: String, term: String) {
			self.value = value
			self.term = term
		}
	}

}
