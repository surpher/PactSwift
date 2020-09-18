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

	/// Generates a random decimal value (BigDecimal) with the provided number of digits
	struct RandomDecimal: ExampleGeneratorExpressible {
		internal let value: Any
		internal let generator: ExampleGenerator.Generator = .decimal
		internal var attributes: [String: AnyEncodable]?

		/// Generates a random decimal value (BigDecimal) with the provided number of digits
		///
		/// - Parameters:
		///   - digits: Number of digits of the generated `Decimal` value
		public init(digits: Int = 6) {
			let digits = digits < 9 ? digits : 9
			self.value = NumberHelper.randomDecimal(digits: digits)
			self.attributes = [
				"digits": AnyEncodable(digits < 9 ? digits : 9),
			]
		}
	}

}

private enum NumberHelper {

	static func randomDecimal(digits: Int) -> Decimal {
		var randomDecimal: String = ""
		(0..<digits).forEach { _ in
			randomDecimal.append("\(Int.random(in: 1...9))")
		}

		return Decimal(string: randomDecimal)!
	}

}
