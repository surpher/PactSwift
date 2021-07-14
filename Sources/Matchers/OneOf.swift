//
//  Created by Marko Justinek on 9/7/21.
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
@_implementationOnly import PactSwiftToolbox

public extension Matcher {

	/// Defines a Pact matcher that validates against one of the provided values.
	/// Uses the first provided value in consumer tests. Removes duplicate values.
	struct OneOf: MatchingRuleExpressible {
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

		// MARK: - Initializer

		/// Defines a Pact matcher that validates against one of the provided values.
		///
		/// - Parameters:
		///   - values: List of allowed values
		///
		/// Uses the first provided value in consumer tests and removes duplicated values.
		///
		init(_ values: AnyHashable...) {
			self.init(values: values)
		}

		/// Defines a Pact matcher that validates against one of the provided values.
		///
		/// - Parameters:
		///   - values: The array of allowed values
		///
		/// Uses the first provided value in consumer tests and removes duplicated values.
		///
		init(values: [AnyHashable]) {
			self.value = values.first as Any
			self.term = Self.regexed(values)
		}

		// MARK: - Private

		private static func regexed(_ values: [AnyHashable]) -> String {
			values.unique.map { "^\($0)$" }.joined(separator: "|")
		}
	}

}

// MARK: - Objective-C

@objc(PFMatcherOneOf)
public class ObjcOneOf: NSObject, ObjcMatcher {

	let type: MatchingRuleExpressible

	/// Defines a Pact matcher that validates against one of the provided values.
	///
	/// - Parameters:
	///   - values: The array of allowed values
	///
	/// Uses the first provided value in consumer tests and removes duplicated values.
	///
	@objc(oneOfFloat:)
	public init(values: [AnyHashable]) {
		type = Matcher.OneOf(values: values)
	}

}
