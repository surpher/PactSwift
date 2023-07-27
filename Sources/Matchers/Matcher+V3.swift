//
//  Created by Oliver Jones on 12/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
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

// MARK: - Pact Specification v3 matchers

public extension Matcher {
	/// A matcher that checks if the string representation of a value contains the substring.
	///
	/// - Parameters:
	///   - value: The substring to match with.
	///
	static func includes<T: StringProtocol & Encodable>(_ value: T) -> AnyMatcher {
		GenericMatcher(type: "include", value: value).asAny()
	}

	/// A matcher that checks if the type of the value is an integer.
	///
	/// - Note: Requires `Pact.Specification.v3`.
	///
	static func integer<T: BinaryInteger & Encodable>(_ value: T) -> AnyMatcher {
		GenericMatcher(type: "integer", value: value).asAny()
	}

	/// A matcher that checks if the type of the value is a number with decimal places.
	///
	/// - Note: Requires `Pact.Specification.v3`.
	///
	static func decimal<T: FloatingPoint & Encodable>(_ value: T) -> AnyMatcher {
		GenericMatcher(type: "decimal", value: value).asAny()
	}

	/// A matcher that checks if the type of the value is an number.
	///
	/// - Note: Requires `Pact.Specification.v3`.
	///
	static func number<T: Numeric & Encodable>(_ value: T) -> AnyMatcher {
		GenericMatcher(type: "number", value: value).asAny()
	}

	/// A matcher that matches the string representation of a value against the datetime format.
	///
	/// - Note: Requires `Pact.Specification.v3`.
	/// - Parameters:
	///   - value: An example value.
	///   - format: The date time format to match against  (eg, `"yyyy-MM-dd HH:mm:ss"`).
	///
	static func datetime(_ value: String, format: String) -> AnyMatcher {
		GenericMatcher(type: "timestamp", value: value, format: format).asAny()
	}

	/// A matcher that matches the string representation of a value against the time format.
	///
	/// - Note: Requires `Pact.Specification.v3`.
	/// - Parameters:
	///   - value: An example value.
	///   - format: The time format to match against  (eg, `"HH:mm:ss"`).
	///
	static func time(_ value: String, format: String) -> AnyMatcher {
		GenericMatcher(type: "time", value: value, format: format).asAny()
	}

	/// A matcher that matches the string representation of a value against the date format.
	///
	/// - Note: Requires `Pact.Specification.v3`.
	/// - Parameters:
	///   - value: An example value.
	///   - format: The date format to match against (eg, `"yyyy-MM-dd"`).
	///
	static func date(_ value: String, format: String) -> AnyMatcher {
		GenericMatcher(type: "date", value: value, format: format).asAny()
	}

	/// A matcher that matches if the value is a null value (this is content specific, for JSON will match a JSON null).
	///
	/// - Note: Requires `Pact.Specification.v3`.
	///
	static func null() -> AnyMatcher {
		GenericMatcher(type: "null", value: nil as String?).asAny()
	}

	/// A matcher that matches if the value is a boolean value (booleans and the string values `"true"` and `"false"`).
	///
	/// - Note: Requires `Pact.Specification.v3`.
	///
	static func bool(_ value: Bool) -> AnyMatcher {
		GenericMatcher(type: "boolean", value: value).asAny()
	}

	/* TODO: Disabled some matchers that I'm unsure how to use at the moment. 🤔

	/// A matcher that matches binary data by its content type (magic file check).
	///
	/// - Note: Requires `Pact.Specification.v3`.
	///
	/// - Parameters:
	///   - value: The MIME content type to match against eg (`"image/jpeg"`).
	///
	static func contentType(_ value: String) -> AnyMatcher {
		GenericMatcher(type: "contentType", value: value).asAny()
	}

	/// A matcher that matches the values in a map/dictionary, ignoring the keys
	///
	/// - Note: Requires `Pact.Specification.v3`.
	///
	/// - Parameters:
	///   - values: A dictionary to match against. The keys don't matter.
	///
	static func values<T: Encodable>(_ value: [String: T]) -> AnyMatcher {
		GenericMatcher(type: "values", value: value).asAny()
	}
	*/
}
