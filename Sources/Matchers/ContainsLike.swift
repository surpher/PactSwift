//
//  Created by Stanislav Marynych on 20.07.2023.
//  Copyright © 2023 Stanislav Marynych. All rights reserved.
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

	/// Matches response that contains one or all of the expected values.
	///
	/// Use this matcher where you expect one or all of the provided JSON in the response.
	///
	/// ```
	/// [
	///   "foo": Matcher.ContainsLike([
	///   		[1, 2],
	///   		["string1", "string2"]
	///   ]),
	///   "bar": Matcher.ContainsLike([
	///   		[
	///   			"key1": "value1"
	///   		],
	///   		[
	///   			"key2": "value2"
	///   		]
	///   ])
	/// ]
	/// ```
	///
	struct ContainsLike: MatchingRuleExpressible {

		internal let value: Any
		internal var rules: [[String: AnyEncodable]] {
			[
				[
					"match": AnyEncodable("arrayContains")
				]
			]
		}

		internal let variants: [Any]

		// MARK: - Initializers

		/// Matches response that contains a `Set` of `Dictionary` values. First value will be generated during tests.
		///
		/// - Parameters:
		///   - variants: All possible variants.
		///
		public init(_ variants: [Any]) {
			self.value = variants.first as Any
			self.variants = variants
		}
	}

}
