//
//  Created by Marko Justinek on 9/10/20.
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

	/// Matches a `null` value.
	struct MatchNull: MatchingRuleExpressible {

		internal let value: Any
		internal let rules: [[String: AnyEncodable]] = [["match": AnyEncodable("null")]]

		// MARK: - Initializer

		/// The value returned by API provider matches `null`.
		public init() {
			value = "pact_matcher_null"
		}
	}

}

// MARK: - Objective-C

#if !os(Linux)
@objc(PFMatcherNull)
public class ObjcMatchNull: NSObject, ObjcMatcher {

	let type: MatchingRuleExpressible = Matcher.MatchNull()

	/// The value returned by API provider matches `null`.
	@objc 
	public override init() {
		super.init()
	}

}
#endif
