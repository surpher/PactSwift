//
//  Created by Marko Justinek on 10/4/20.
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

	/// Defines a Pact matcher for a `Set` but does not care about the actual value(s).
	///
	/// Use this matcher when you expect a `Set` of values.
	/// You can specifiy the expected minimum and maximum
	/// occurrances of elements, but the actual values are
	/// not important. Can contain other matchers.
	///
	/// ```
	/// [
	///   "related_ids": Matcher.EachLike(1, min: 2), // Set of 0-2 ints
	///   "names": Matcher.EachLike("John", min: 1, max: 3), // Set of 1-3 strings
	///   "elements": Matcher.EachLike(
	///     [
	///       "foo": "bar",
	///       "bar": Matcher.SomethingLike(5)
	///     ],
	///     max: 10
	///   ) // Set of 0 - 10 objects.
	/// ```
	///
	struct EachLike: MatchingRuleExpressible {

		internal let value: Any
		internal let min: Int?
		internal let max: Int?

		internal var rules: [[String: AnyEncodable]] {
			var ruleValue = ["match": AnyEncodable("type")]
			if let min = min { ruleValue["min"] = AnyEncodable(min) }
			if let max = max { ruleValue["max"] = AnyEncodable(max) }
			return [ruleValue]
		}

		// MARK: - Initializers

		/// Defines a Pact matcher for a `Set` but does not care about the actual values.
		///
		/// Defines a `Set` where its capacity is of at least `1` occurance of `value`.
		///
		/// - Parameters:
		///   - value: Template to base the comparison on
		///   - count: Number of examples to generate, defaults to `1`
		///
		public init(_ value: Any, count: Int = 1) {
			self.value = Array(repeating: value, count: (count > 1) ? count : 1)
			self.min = 1
			self.max = nil
		}

		/// Defines a Pact matcher for a `Set` but does not care about the actual values.
		///
		/// Defines a `Set` where its capacity is at least `min` occurances of provided `value`.
		///
		/// - Parameters:
		///   - value: Template to base the comparison on
		///   - min: Minimum expected number of occurances of provided `value`
		///   - count: Number of examples to generate, defaults to `1`
		///
		/// - Precondition: `min` must be a positive value and less than or equal to `count`
		///
		public init(_ value: Any, min: Int, count: Int = 1) {
			self.value = Array(repeating: value, count: (count > min) ? count : min)
			self.min = min
			self.max = nil
		}

		/// Defines a Pact matcher that defines a `Set` but does not care about the actual values.
		///
		/// Defines a `Set` where its capacity can be of `1` to `max` of provided `value`.
		///
		/// - Parameters:
		///   - value: Template to base the comparison on
		///   - max: Maximum expected number of occurances of provided `value`
		///   - count: Number of examples to generate, defaults to `1`
		///
		/// - Precondition: `max` must be a positive value and not greater than `count`
		///
		public init(_ value: Any, max: Int, count: Int = 1) {
			self.value = Array(repeating: value, count: (count > max) ? max : count)
			self.min = nil
			self.max = max
		}

		/// Defines a Pact matcher for a `Set` but does not care about the actual values.
		///
		/// Defines a `Set` where its capacity can be of `min` to `max` of provided `value`.
		///
		/// - Parameters:
		///   - value: Template to base the comparison on
		///   - min: Minimum expected number of occurances of provided `value`
		///   - max: Maximum expected number of occurances of provided `value`
		///   - count: Number of examples to generate, defaults to `1`
		///
		/// - Precondition: `min` and `max` must each be a positive value. Lesser of the two values will be considered as `min` and greater of the two will be considered as `max`
		///
		/// - Precondition: `count` must be a value between `min` and `max`, else either `min` or `max` is used to generate the number of examples
		///
		public init(_ value: Any, min: Int, max: Int, count: Int = 1) {
			self.value = Array(repeating: value, count: count < min ? min : (count > max) ? max : count)
			self.min = Swift.min(min, max)
			self.max = Swift.max(min, max)
		}
	}

}

// MARK: - Objective-C

@objc(PFMatcherEachLike)
public class ObjcEachLike: NSObject, ObjcMatcher {

	let type: MatchingRuleExpressible

	/// Defines a Pact matcher describing a set
	///
	/// - Parameters
	///   - value: Template to base the comparison on
	///   - count: Number of examples to generate, defaults to `1`
	///
	@objc(value: count:)
	public init(value: Any, count: Int = 1) {
		type = Matcher.EachLike(value, count: count)
	}

	/// Defines a Pact matcher describing a set
	///
	/// - Parameters:
	///   - value: Template to base the comparison on
	///   - min: Minimum expected number of occurances of provided `value`
	///   - max: Maximum expected number of occurances of provided `value`
	///   - count: Number of examples to generate, defaults to `1`
	///
	/// - Precondition: `min` and `max` must each be a positive value. Lesser of the two values will be considered as `min` and greater of the two will be considered as `max`
	///
	/// - Precondition: `count` must be a value between `min` and `max`, else either `min` or `max` is used to generate the number of examples
	///
	@objc(value: min: max: count:)
	public init(value: Any, min: Int, max: Int, count: Int = 1) {
		type = Matcher.EachLike(value, min: min, max: max, count: count)
	}

}
