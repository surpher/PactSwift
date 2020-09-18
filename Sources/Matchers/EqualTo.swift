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

	/// Defines a Pact matcher that expects the provided value.
	///
	/// Use this matcher where you expect the exact type and value
	/// in the interaction between consumer and provider.
	///
	/// ```
	/// // DSL
	/// [
	///   "foo": Matcher.EqualTo("bar"),
	///   "bar": Matcher.EqualTo(847)
	/// ]
	/// ```
	struct EqualTo: MatchingRuleExpressible {

		internal let value: Any
		internal let rules: [[String: AnyEncodable]] = [["match": AnyEncodable("equality")]]

		// MARK: - Initializers

		/// Defines a Pact matcher that explicitly expects the provided value.
		///
		/// - parameter value: The value to be returned by MockService
		public init(_ value: Any) {
			self.value = value
		}
	}

}
