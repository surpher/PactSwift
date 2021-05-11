//
//  Created by Marko Justinek on 18/9/20.
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
@_implementationOnly import PactSwiftMockServer

#if SWIFT_PACKAGE
import PactMockServer
#endif

public extension ExampleGenerator {

	/// Generates a random string value of the provided size characters
	struct RandomString: ExampleGeneratorExpressible {
		internal let value: Any
		internal let generator: ExampleGenerator.Generator
		internal var rules: [String: AnyEncodable]?

		/// Generates a random string value of the provided size characters
		///
		/// - Parameters:
		///   - size: The size of generated `String`
		///
		/// - Precondition: `size` is a positive value
		///
		public init(size: Int = 20) {
			self.generator = .string
			self.value = String((0..<size).map { _ in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
			self.rules = [
				"size": AnyEncodable(size),
			]
		}

		/// Generates a random string value from the provided regular expression
		///
		/// Use a raw `String` (eg: `#"\d{2}/\d{2,4}"#`) to avoid interpreting special characters.
		///
		/// Feature provided by`kennytm/rand_regex` library (https://github.com/kennytm/rand_regex).
		///
		/// - Parameters:
		///   - regex: The regular expression that defines the generated `String`
		///
		public init(regex: String) {
			guard let regexValue = MockServer.generate_value(regex: regex) else {
				fatalError("Failed to generate a random string from \"\(regex)\"")
			}

			self.generator = .regex
			self.value = regexValue
			self.rules = [
				"regex": AnyEncodable(regex),
			]
		}
	}

}

// MARK: - Objective-C

@objc(PFGeneratorRandomString)
public class ObjcRandomString: NSObject, ObjcGenerator {

	let type: ExampleGeneratorExpressible

	/// Generates a random string value of the provided size characters
	///
	/// - Parameters:
	///   - size: The size of generated `String`
	///
	/// - Precondition: `size` is a positive value
	///
	@objc(size:)
	public init(size: Int = 20) {
		type = ExampleGenerator.RandomString(size: size)
	}

	/// Generates a random string value from the provided regular expression
	///
	/// Use a raw `String` (eg: `#"\d{2}/\d{2,4}"#`) to avoid interpreting special characters.
	///
	/// Feature provided by`kennytm/rand_regex` library (https://github.com/kennytm/rand_regex).
	///
	/// - Parameters:
	///   - regex: The regular expression that defines the generated `String`
	///
	@objc(regex:)
	public init(regex: String) {
		type = ExampleGenerator.RandomString(regex: regex)
	}

}
