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

	/// Matches an `Int` type.
	///
	/// Use this matcher where you expect an `Int` to be returned
	/// by your API provider.
	///
	struct IntegerLike: MatchingRuleExpressible {

		internal let value: Any
		internal let rules: [[String: AnyEncodable]] = [["match": AnyEncodable("integer")]]

		// MARK: - Initializer

		/// Matches an `Int` type.
		///
		/// - Parameters:
		///   - value: Value to use in tests
		///
		public init(_ value: Int) {
			self.value = value
		}
	}

}

// MARK: - Objective-C

#if !os(Linux)
@objc(PFMatcherIntegerLike)
public class ObjcIntegerLike: NSObject, ObjcMatcher {

	let type: MatchingRuleExpressible

	/// Matches an `Int` type.
	///
	/// - Parameters:
	///   - value: Value to use in tests
	///
	@objc(value:)
	public init(value: Int) {
		type = Matcher.IntegerLike(value)
	}

}
#endif
