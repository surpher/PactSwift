//
//  Created by Marko Justinek on 11/4/20.
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

import Foundation
import XCTest

public extension Matcher {

	/// Matches a value that fits the provided `regex` pattern
	///
	/// This matcher can be used in request `path`.
	///
	/// ```
	/// [
	///   "foo": Matcher.RegexLike(value: "2020-04-27", pattern: "\d{4}-\d{2}-\d{2}")
	/// ]
	/// ```
	///
	struct RegexLike: MatchingRuleExpressible, PactPathParameter {
		internal let value: Any
		internal let pattern: String

		internal var rules: [[String: AnyEncodable]] {
			[
				[
					"match": AnyEncodable("regex"),
					"regex": AnyEncodable(pattern),
				],
			]
		}

		// MARK: - Iitializer

		/// Matches a value that fits the provided `regex` term
		///
		/// - Parameters:
		///   - value: The value to be used in tests
		///   - term: The regex term that describes the `value`
		///
		/// This matcher can be used in request `path`.
		///
		@available(*, deprecated, message: "Use `.init(value:pattern:) instead")
		public init(_ value: String, term: String) {
			self.value = value
			self.pattern = term
		}

		/// Matches a value that fits the provided `regex` pattern
		///
		/// - Parameters:
		///   - value: The value to be used in tests
		///   - pattern: The regex term that describes the `value`
		///
		/// This matcher can be used in request `path`.
		///
		public init(value: String, pattern: String) {
			self.value = value
			self.pattern = pattern
		}
	}

}

// MARK: - Objective-C

@objc(PFMatcherRegexLike)
public class ObjcRegexLike: NSObject, ObjcMatcher {

	let type: MatchingRuleExpressible

	/// Matches a value that fits the provided `regex` term.
	///
	/// - Parameters:
	///   - value: The value to be used in tests
	///   - term: The regex term that describes the `value`
	///
	/// This matcher can be used in request `path`.
	///
	@available(*, deprecated, message: "Use `.init(value:pattern:) instead")
	@objc(value: term:)
	public init(value: String, term: String) {
		type = Matcher.RegexLike(value: value, pattern: term)
	}

	/// Matches a value that fits the provided `regex` pattern
	///
	/// - Parameters:
	///   - value: The value to be used in tests
	///   - pattern: The regex term that describes the `value`
	///
	/// This matcher can be used in request `path`.
	///
	@objc(value: pattern:)
	public init(value: String, pattern: String) {
		type = Matcher.RegexLike(value: value, pattern: pattern)
	}

}
