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

// MARK: - Pact Specification v2 matchers

public extension Matcher {
	/// A matcher that validates against one of the provided values.
	///
	/// Use this matcher when you're expecting API response values to fit an `enum` type.
	///
	/// - Parameters:
	///   - values: A `Set` of values to match against. Case sensitive.
	static func oneOf<T: CustomStringConvertible>(_ values: Set<T>) -> AnyMatcher {
		let descriptions = values.map(\.description).sorted()
		return regex("^(\(descriptions.joined(separator: "|")))$", example: descriptions.first ?? "")
	}

	/// A matcher that executes a regular expression match against the string representation of a value.
	///
	/// - Note: Requires `Pact.Specification.v2`.
	/// - Parameters:
	///   - regex: The regex to use when matching.
	///   - example: An example value that matches the `regex`.
	///
	static func regex(_ regex: String, example: String) -> AnyMatcher {
		GenericMatcher(type: "regex", value: example, regex: regex).asAny()
	}

	/// A matcher that executes a regular expression match against the string representation of an IP4 address.
	///
	/// - Note: Requires `Pact.Specification.v2`.
	/// - Parameters:
	///    - example: An IPv4 address to use as an example. Defaults to `127.0.0.13`
	static func ip4Address(_ example: String = "127.0.0.13") -> AnyMatcher {
		.regex(#"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"#, example: example)
	}

	/// A matcher that executes a regular expression match against the string representation of an IP6 address.
	///
	/// - Note: Requires `Pact.Specification.v2`.
	/// - Parameters:
	///    - example: An IPv6 address to use as an example. Defaults to `::ffff:192.0.2.128`
	static func ip6Address(_ example: String = "::ffff:192.0.2.128") -> AnyMatcher {
		// swiftlint:disable:next line_length
		.regex("^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$", example: example)
	}

	/// A matcher that executes a regular expression match against the string representation of a hexadecimal value (optionally with `0x` prefix).
	///
	/// - Note: Requires `Pact.Specification.v2`.
	/// - Parameters:
	///    - example: An hexadecimal string to use as an example. Defaults to `3F`
	static func hexadecimal(_ example: String = "3F") -> AnyMatcher {
		.regex(#"^(?:0x)?[0-9a-fA-F]+$"#, example: example)
	}

	/// A matcher that executes a regular expression match against the string representation of a base64 encoded value (assumes no line breaks).
	///
	/// - Note: Requires `Pact.Specification.v2`.
	/// - Parameters:
	///    - example: An base64 encoded string to use as an example. Defaults to `ZXhhbXBsZQo=` which is `"example"` encoded in base64.
	static func base64(_ example: String = "ZXhhbXBsZQo=") -> AnyMatcher {
		.regex(#"^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$"#, example: example)
	}

	/// A matcher that executes a type based match against the value, that is, they are equal if they are the same type.
	///
	/// - Note: Requires `Pact.Specification.v2`.
	/// - Parameters:
	///   - value: An example value to match the type of.
	///
	static func like<T: Encodable>(_ value: T) -> AnyMatcher {
		GenericMatcher(type: "type", value: value).asAny()
	}

	/// A matcher that executes a type based match against the values, that is, they are equal if they are the same type.
	///
	/// - Note: Requires `Pact.Specification.v2`.
	/// - Parameters:
	///   - values: The example values.
	///
	static func like(_ value: [String: AnyMatcher]) -> AnyMatcher {
		GenericMatcher(type: "type", value: value).asAny()
	}

	/// A matcher that executes a type based match against the values, that is, they are equal if they are the same type.
	///
	/// In addition, if the values represent a collection, the length of the actual value is compared against the minimum.
	///
	/// - Note: Requires `Pact.Specification.v2`.
	/// - Parameters:
	///   - values: The example values.
	///   - min: The minimum length of the array of values.
	///
	static func eachLike<T: Encodable>(_ value: T, min: Int) -> AnyMatcher {
		GenericMatcher(type: "type", value: [value], min: min).asAny()
	}

	/// A matcher that executes a type based match against the values, that is, they are equal if they are the same type.
	///
	/// In addition, if the values represent a collection, the length of the actual value is compared against the maximum.
	///
	/// - Note: Requires `Pact.Specification.v2`.
	/// - Parameters:
	///   - values: The example values.
	///   - max: The maximum length of the array of values.
	///
	static func eachLike<T: Encodable>(_ value: T, max: Int) -> AnyMatcher {
		GenericMatcher(type: "type", value: [value], max: max).asAny()
	}

	/// A matcher that executes a type based match against the values, that is, they are equal if they are the same type.
	///
	/// In addition, if the values represent a collection, the length of the actual value is compared against the minimum and maximum.
	///
	/// - Note: Requires `Pact.Specification.v2`.
	/// - Parameters:
	///   - values: The example values.
	///   - min: The minimum length of the array of values.
	///   - max: The maximum length of the array of values.
	///
	static func eachLike<T: Encodable>(_ value: T, min: Int, max: Int) -> AnyMatcher {
		precondition(min <= max, "min must be <= max")
		return GenericMatcher(type: "type", value: [value], min: min, max: max).asAny()
	}
}
