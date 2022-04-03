//
//  Created by Marko Justinek on 3/4/2022.
//  Copyright © 2022 PACT Foundation. All rights reserved.
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

	struct EachKeyLike: MatchingRuleExpressible {

		let key: String
		let value: Any
		let rules: [[String: AnyEncodable]] = [["match": AnyEncodable("type")]]

		// MARK: - Initializers

		/// Object where the key itself is ignored, but the value template must match
		///
		/// - Parameters:
		///   - key: The key to ignore
		///   - value: The value template to use in consumer test
		///
		/// Use this matcher in situations when the `key` is not known in advance but the actual value structure and type
		/// must match. You may use other `Matcher`s and `ExampleGenerator`s for its value.
		///
		/// ```
		/// // DSL
		/// .willRespondWith(
		///   status: 200,
		///   body: [
		///     "articles": Matcher.EachLike(
		///       [
		///         "variants": Matcher.EachKeyLike(
		///           "001", value: ["created_on": ExampleGenerator.RandomDate]
		///         )
		///       ]
		///     )
		///   ]
		/// )
		///
		/// // will generate JSON:
		/// {
		///   "articles": [
		///     {
		///       "variants": {
		///         "001": {
		///           "created_on": "2022-03-23"
		///         }
		///       }
		///     }
		///   ]
		/// }
		/// ```
		///
		public init(_ key: String, value: Any) {
			self.key = key
			self.value = value
		}
	}

}

// MARK: - Objective-C

#if !os(Linux)
@objc(PFMatcherEachKeyLike)
public class ObjcEachKeyLike: NSObject, ObjcMatcher {

	let type: MatchingRuleExpressible

	/// Object where the key itself is ignored, but the value template must match
	///
	/// - Parameters:
	///   - key: The key to ignore
	///   - value: The value template to use in consumer test
	///
	/// Use this matcher in situations when the `key` is not known in advance but the actual value structure and type
	/// must match. You may use other `Matcher`s and `ExampleGenerator`s for its value.
	///
	@objc(key: value:)
	public init(key: String, value: Any) {
		type = Matcher.EachKeyLike(key, value: value)
	}

}
#endif
