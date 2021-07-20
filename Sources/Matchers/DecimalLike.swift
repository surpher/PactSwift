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

	/// Mathes a `Decimal` value.
	///
	/// - Parameters:
	///   - value: The value MockService should expect or respond with in your tests
	///
	/// Use this matcher when you expect the type being returned by the API provider is a `Decimal`.
	///
	/// ```
	/// [
	///   "foo": Matcher.DecimalLike(1234)
	/// ]
	/// ```
	///
	struct DecimalLike: MatchingRuleExpressible {
		internal let value: Any
		internal let rules: [[String: AnyEncodable]] = [["match": AnyEncodable("decimal")]]

		// MARK: - Initializer

		/// Mathes a `Decimal` value.
		///
		/// - parameter value: The value MockService should expect or respond with in your tests
		///
		public init(_ value: Decimal) {
			self.value = value
		}
	}

}

// MARK: - Objective-C

/// Mathes a `Decimal` value.
///
/// Use this matcher when you expect the type being returned by the API provider is a `Decimal`.
///
/// ```
/// @{@"foo": [Matcher DecimalLike(1234)] }
/// ```
///
/// - Parameters:
///   - value: The value MockService should expect or respond with
///
@objc(PFMatcherDecimalLike)
public class ObjcDecimalLike: NSObject, ObjcMatcher {

	let type: MatchingRuleExpressible

	/// Mathes a `Decimal` value.
	///
	/// - Parameters:
	///   - value: The value MockService should expect or respond with
	///
	@objc(value:)
	public init(value: Decimal) {
		self.type = Matcher.DecimalLike(value)
	}

}
