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

public extension Matcher {

	/// Matches response that contains any or all expected values.
	///
	/// Use this matcher where you expect either all or
	/// at least one of the provided `String` values to be present
	/// in the response.
	///
	/// ```
	/// [
	///   "foo": Matcher.IncludesLike("1", "Jane", "John", combine: .OR, generate: "Jane has 1 pony, John has none"),
	///   "bar": Matcher.IncludesLike(["1", "Jane", "John"], combine: .AND)
	/// ]
	/// ```
	///
	struct IncludesLike: MatchingRuleExpressible {
		public enum IncludeCombine: String {
			case AND
			case OR
		}

		internal let value: Any
		internal let combine: IncludeCombine
		internal var rules: [[String: AnyEncodable]] {
			includeStringValues.map {
				[
					"match": AnyEncodable("include"),
					"value": AnyEncodable($0),
				]
			}
		}

		private var includeStringValues: [String]

		// MARK: - Initializers

		/// Matches response that contains a `Set` of `String` values.
		///
		/// - Parameters:
		///   - values: The expected values to be returned
		///   - combine: Defines whether matches are combined with logical `AND` or `OR`
		///   - generate: The value to generate during tests
		///
		public init(_ values: String..., combine: IncludeCombine = .AND, generate: String? = nil) {
			self.value = generate ?? values.joined(separator: " ")
			self.includeStringValues = values
			self.combine = combine
		}

		/// Matches response that contains a `Set` of `String` values.
		///
		/// - Parameters:
		///   - values: The expected values to be returned
		///   - combine: Defines whether matches are combined with logical `AND` or `OR`
		///   - generate: The value to generate during tests
		///
		public init(_ values: [String], combine: IncludeCombine = .AND, generate: String? = nil) {
			self.value = generate ?? values.joined(separator: " ")
			self.includeStringValues = values
			self.combine = combine
		}
	}

}

// MARK: - Objective-C

#if !os(Linux)
@objc(PFMatcherIncludesLike)
public class ObjcIncludesLike: NSObject, ObjcMatcher {

	let type: MatchingRuleExpressible

	/// Matches response that contains all of the expected values.
	///
	/// - Parameters:
	///   - values: The expected values to be returned
	///   - combine: Defines whether matches are combined with logical AND or OR
	///   - generate: The value to generate during tests
	///
	@objc(includesAll: generate:)
	public init(includesAll: [String], generate: String?) {
		type = Matcher.IncludesLike(includesAll, combine: .AND, generate: generate)
	}

	/// Matches response that contains a any of the expected values.
	///
	/// - Parameters:
	///   - values: The expected values to be returned
	///   - combine: Defines whether matches are combined with logical AND or OR
	///   - generate: The value to generate during tests
	///
	@objc(includesAny: generate:)
	public init(includesAny: [String], generate: String?) {
		type = Matcher.IncludesLike(includesAny, combine: .OR, generate: generate)
	}

}
#endif
