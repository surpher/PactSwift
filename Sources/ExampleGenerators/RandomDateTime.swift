//
//  Created by Marko Justinek on 17/9/20.
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

public extension ExampleGenerator {

	/// Generates a Date and Time (timestamp) value from the current date and time either in ISO format or using the provided format string
	struct RandomDateTime: ExampleGeneratorExpressible {
		internal let value: Any
		internal let generator: ExampleGenerator.Generator = .dateTime
		internal var rules: [String: AnyEncodable]?

		/// Generates a Date and Time (timestamp) value from the current date and time either in ISO format or using the provided format string
		///
		/// - Parameters:
		///   - format: The format of generated timestamp
		///
		public init(format: String? = nil) {
			self.value = Date.formattedDate(format: format, isoFormat: .dateTime)

			if let format = format {
				self.rules = [
					"format": AnyEncodable(format),
				]
			}
		}
	}

	/// Generates a generator for DateTime using an expression
	///
	/// Warning:
	/// Not all Pact impelmentations support this type of example generator!
	struct DateTimeExpression: ExampleGeneratorExpressible {
		internal let value: Any
		internal let generator: ExampleGenerator.Generator = .dateTime
		internal var rules: [String: AnyEncodable]?

		/// Generates an example generator for DateTime using an expression
		///
		/// It uses Swift's `DateFormatter` to cast the provided `Date` object into `String` with the provided `format`.
		/// This `String` is used as the value for consumer tests.
		///
		/// When defining an expression like `"today +1 day @ 6 o'clock pm"`,
		/// it is your responsibility to create and pass the `Date` object that fits the expression for the needs of your tests.
		///
		/// - Parameters:
		///   - format: The date time format
		///   - expression: The expression provider should use when verifying
		///   - use: The `Date` object for the consumer test. It uses the value of `format` to prepare the value the Mock Server will return.
		///
		/// - Warning: Not all Pact implementations support this type of example generator!
		///
		public init(format: String, expression: String, use date: Date) {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = format

			self.value = dateFormatter.string(from: date)
			self.rules = [
				"format": AnyEncodable(format),
				"expression": AnyEncodable(expression),
			]
		}
	}

}

// MARK: - Objective-C

#if !os(Linux)
@objc(PFGeneratorRandomDateTime)
public class ObjcRandomDateTime: NSObject, ObjcGenerator {

	let type: ExampleGeneratorExpressible

	/// Generates a Date and Time (timestamp) value from the current date and time either in ISO format or using the provided format string
	///
	/// - Parameters:
	///   - format: The format of generated timestamp
	///
	@objc(format:)
	public init(format: String? = nil) {
		type = ExampleGenerator.RandomDateTime(format: format)
	}

}
#endif
