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

	/// Object where the key itself is ignored, but the value template must match
	///
	/// - Parameters:
	///   - value: The value template to use in consumer test
	///
	/// Use this matcher in situations when the `key` is not known in advance but the actual value structure and type
	/// must match. You may use other `Matcher`s and `ExampleGenerator`s for its value.
	///
	/// An example pact test set up:
	///
	/// ```
	/// .willRespondWith(
	///   status: 200,
	///   body: [
	///     "abc": Matcher.EachKeyLike([
	///       "field1": Matcher.SomethingLike("value1"),
	///       "field2": Matcher.IntegerLike(123)
	///     ]),
	///     "xyz": Matcher.EachKeyLike([
	///       "field1": Matcher.SomethingLike("value2"),
	///       "field2": Matcher.IntegerLike(456)
	///     ])
	///   ]
	/// )
	/// ```
	///
	///	Will generate the response JSON:
	///
	/// ```
	/// {
	///   "abc": { "field1": "value1", "field2": 123 },
	///   "xyz": { "field1": "value2", "field2": 456 },
	/// }
	/// ```
	///
	/// And the matching rules will be set to match any key:
	///
	/// ```
	/// "matchingRules": {
	///    "body": {
	///      "$.*": {
	///        "combine": "AND",
	///        "matchers": [{"match": "type"}]
	///      },
	///      "$.*.field1": {
	///        "combine": "AND",
	///        "matchers": [{"match": "type"}]
	///      },
	///      "$.*.field2": {
	///        "combine": "AND",
	///        "matchers": [{"match": "integer"}]
	///      }
	///    }
	///  },
	///  ...
	/// ```
	///
	/// - Warning: Note that using a different matcher at the same level might
	/// yield conflicting matching rules when validating the provider.
	///
	struct EachKeyLike: MatchingRuleExpressible {

		let value: Any
		let rules: [[String: AnyEncodable]] = [["match": AnyEncodable("type")]]

		// MARK: - Initializers

		/// Object where the key itself is ignored, but the value template must match
		///
		/// - Parameters:
		///   - value: The value template to use in consumer test
		///
		/// Use this matcher in situations when the `key` is not known in advance but the actual value structure and type
		/// must match. You may use other `Matcher`s and `ExampleGenerator`s for its value.
		///
		/// An example pact test set up:
		///
		/// ```
		/// .willRespondWith(
		///   status: 200,
		///   body: [
		///     "abc": Matcher.EachKeyLike([
		///       "field1": Matcher.SomethingLike("value1"),
		///       "field2": Matcher.IntegerLike(123)
		///     ]),
		///     "xyz": Matcher.EachKeyLike([
		///       "field1": Matcher.SomethingLike("value2"),
		///       "field2": Matcher.IntegerLike(456)
		///     ])
		///   ]
		/// )
		/// ```
		///
		///	Will generate the response JSON:
		///
		/// ```
		/// {
		///   "abc": { "field1": "value1", "field2": 123 },
		///   "xyz": { "field1": "value2", "field2": 456 },
		/// }
		/// ```
		///
		/// And the matching rules will be set to match any key:
		///
		/// ```
		/// "matchingRules": {
		///    "body": {
		///      "$.*": {
		///        "combine": "AND",
		///        "matchers": [{"match": "type"}]
		///      },
		///      "$.*.field1": {
		///        "combine": "AND",
		///        "matchers": [{"match": "type"}]
		///      },
		///      "$.*.field2": {
		///        "combine": "AND",
		///        "matchers": [{"match": "integer"}]
		///      }
		///    }
		///  },
		///  ...
		/// ```
		///
		/// - Warning: Note that using a different matcher at the same level might
		/// yield conflicting matching rules when validating the provider.
		///
		public init(_ value: Any) {
			self.value = value
		}
	}

}

// MARK: - Objective-C

@objc(PFMatcherEachKeyLike)
public class ObjcEachKeyLike: NSObject, ObjcMatcher {

	let type: MatchingRuleExpressible

	/// Object where the key itself is ignored, but the value template must match
	///
	/// - Parameters:
	///   - value: The value template to use in consumer test
	///
	/// Use this matcher in situations when the `key` is not known in advance but the actual value structure and type
	/// must match. You may use other `Matcher`s and `ExampleGenerator`s for its value.
	///
	/// - Warning: Note that using a different matcher at the same level might
	/// yield conflicting matching rules when validating the provider.
	///
	@objc(value:)
	public init(value: Any) {
		type = Matcher.EachKeyLike(value)
	}

}
