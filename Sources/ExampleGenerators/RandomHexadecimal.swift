//
//  Created by Marko Justinek on 17/9/20.
//  Copyright © 2020 Itty Bitty Apps Pty Ltd / PACT Foundation. All rights reserved.
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

public extension ExampleGenerator {

	/// Generates a random hexadecimal value (String) with the provided number of digits
	struct RandomHexadecimal: ExampleGeneratorExpressible {
		internal let value: Any
		internal let generator: ExampleGenerator.Generator = .hexadecimal
		internal var rules: [String: AnyEncodable]?

		/// Generates a random hexadecimal value (String) with the provided number of digits
		///
		/// - Parameters:
		///   - digits: The length of generated hexadecimal string
		public init(digits: UInt8 = 8) {
			// MockServer overrides this value and returns a new string so accuracy and correctness here is irrelevant
			self.value = String((0..<digits).map { _ in "0123456789ABCDEF".randomElement()! })
			self.rules = [
				"digits": AnyEncodable(digits),
			]
		}
	}

}

// MARK: - Objective-C

@objc(PFGeneratorRandomHexadecimal)
public class ObjcRandomHexadecimal: NSObject, ObjcGenerator {

	let type: ExampleGeneratorExpressible

	/// Generates a random hexadecimal value (String) with the provided number of digits
	///
	/// - Parameters:
	///   - digits: The length of generated hexadecimal string
	@objc(digits:)
	public init(digits: Int = 8) {
		type = ExampleGenerator.RandomHexadecimal(digits: UInt8(digits))
	}

}
