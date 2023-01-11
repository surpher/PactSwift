//
//  Created by Oliver Jones on 9/1/2023.
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

public protocol Matcher: Encodable {
	// no additional members
}

/// Type erasing wraper around `any Matcher`.
public struct AnyMatcher: Matcher {
	var matcher: any Matcher

	public init(_ matcher: any Matcher) {
		self.matcher = matcher
	}

	public func encode(to encoder: Encoder) throws {
		try matcher.encode(to: encoder)
	}
}

public extension Matcher {

	private func asAny() -> AnyMatcher {
		AnyMatcher(self)
	}

	// MARK: - Matchers

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

	// MARK: - Pact Specification v1 matchers

	/// A matcher that checks that the values are equal.
	///
	/// - Note: Requires `Pact.Specification.v1`.
	/// - Parameters:
	///   - value: The value to match with.
	///
	static func equals<T: Encodable>(_ value: T) -> AnyMatcher {
		GenericMatcher(type: "equality", value: value).asAny()
	}

	// MARK: - Pact Specification v2 matchers

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

	// MARK: - Pact Specification v3 matchers

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

	// MARK: - Pact Specification v4 matchers

	// TODO: "arrayContains"

	/// A matcher that matches the response status code.
	///
	/// - Note: Requires `Pact.Specification.v4`.
	///
	static func statusCode(_ statusCode: HTTPStatus) -> AnyMatcher {
		switch statusCode {
		case .information:
			return GenericMatcher(type: "statusCode", value: "information").asAny()
		case .success:
			return GenericMatcher(type: "statusCode", value: "success").asAny()
		case .redirect:
			return GenericMatcher(type: "statusCode", value: "redirect").asAny()
		case .clientError:
			return GenericMatcher(type: "statusCode", value: "clientError").asAny()
		case .serverError:
			return GenericMatcher(type: "statusCode", value: "serverError").asAny()
		case .nonError:
			return GenericMatcher(type: "statusCode", value: "nonError").asAny()
		case .error:
			return GenericMatcher(type: "statusCode", value: "error").asAny()
		case .statusCodes(let codes):
			return GenericMatcher(type: "statusCode", value: codes).asAny()
		}
	}

	/// A matcher that matches a value that must be present and not empty (not null or the empty string).
	///
	/// - Note: Requires `Pact.Specification.v4`.
	///
	static func notEmpty() -> AnyMatcher {
		GenericMatcher(type: "notEmpty", value: "non-empty").asAny()
	}

	/// A matcher that matches a value that must be valid based on the `semver` specification.
	///
	/// - Note: Requires `Pact.Specification.v4`.
	///
	/// - Parameters:
	///   - value: An example value (eg: `"1.2.3"`)
	///
	static func semver(_ value: String) -> AnyMatcher {
		GenericMatcher(type: "semver", value: value).asAny()
	}

	// TODO: "eachKey", "eachValue"

	// MARK: - Generators

	//case regex = "Regex"
	//case providerState = "ProviderState"

	/// Generate a MockServer URL.
	///
	/// - Parameters:
	///   - example: An example URL eg `"http://localhost:8080/orders/1234"`
	///   - regex: A regex to extract the relevant part of the example, eg: `"^.*(/orders/\\d+)$"` that will be combine with the mock server URL. **Note** this regex *must* include a single capture group!
	static func generatedMockServerUrl(example: String, regex: String) -> AnyMatcher {
		GenericMatcher(type: "type", value: example, generator: .mockServerUrl, regex: regex, example: example).asAny()
	}

	/// Generate a random string value.
	///
	/// - Parameters:
	///   - value: The example value.
	///   - size: The size of string to generate (uses the length of the example `value` by default).
	///
	static func randomString(like value: String, size: Int? = nil) -> AnyMatcher {
		GenericMatcher(type: "type", value: value, generator: .randomString, size: size ?? value.count).asAny()
	}

	static func randomInteger<T: BinaryInteger & Encodable>(like value: T, range: ClosedRange<Int>? = nil) -> AnyMatcher {
		GenericMatcher(type: "type", value: value, generator: .randomInt, min: range?.lowerBound, max: range?.upperBound).asAny()
	}

	/// Generate a random `Int` within the specified `range`.
	///
	/// - Parameters:
	///   - range: The range of values that the generated number should be within.
	///
	static func randomInteger(_ range: ClosedRange<Int>) -> AnyMatcher {
		GenericMatcher(type: "type", value: range.randomElement(), generator: .randomInt, min: range.lowerBound, max: range.upperBound).asAny()
	}

	static func randomDecimal<T: FloatingPoint & Encodable>(like value: T, digits: Int? = nil ) -> AnyMatcher {
		GenericMatcher(type: "type", value: value, generator: .randomDecimal, digits: digits).asAny()
	}

	static func randomBoolean() -> AnyMatcher {
		GenericMatcher(type: "type", value: true, generator: .randomBoolean).asAny()
	}

	static func randomUUID(like value: String, format: UUIDFormat = .simple) -> AnyMatcher {
		GenericMatcher(type: "type", value: value, generator: .uuid, format: format.rawValue).asAny()
	}

	static func randomUUID(like value: UUID) -> AnyMatcher {
		GenericMatcher(type: "type", value: value.uuidString, generator: .uuid, format: UUIDFormat.upperCaseHyphenated.rawValue).asAny()
	}

	/// Generate a random hexadecimal value.
	///
	/// - Parameters:
	///   - value: The example value.
	///   - digits: The number of digits to generate (uses the length of the example `value` by default).
	///
	static func randomHexadecimal(like value: String, digits: Int? = nil) -> AnyMatcher {
		GenericMatcher(type: "type", value: value, generator: .randomHex, digits: digits ?? value.count).asAny()
	}

	/// Generate a random date.
	///
	/// - Parameters:
	///   - value: Example value.
	///   - format: The date format (eg, yyyy-MM-dd)
	///   - expression: An expression to manipulate the generated date.
	///
	/// Expression | Resulting date-time
	/// --|--
	/// `nil` | `"2000-01-01T10:00Z"`
	/// `"now"`| `2000-01-01T10:00Z`
	/// `"today"` | `"2000-01-01T10:00Z"`
	/// `"yesterday"` | `"1999-12-31T10:00Z"`
	/// `"tomorrow"` | `"2000-01-02T10:00Z"`
	/// `"+ 1 day"` | `"2000-01-02T10:00Z"`
	/// `"+ 1 week"` | `"2000-01-08T10:00Z"`
	/// `"- 2 weeks"` | `"1999-12-18T10:00Z"`
	/// `"+ 4 years"` | `"2004-01-01T10:00Z"`
	/// `"tomorrow+ 4 years"` | `"2004-01-02T10:00Z"`
	/// `"next week"` | `"2000-01-08T10:00Z"`
	/// `"last month"` | `"1999-12-01T10:00Z"`
	/// `"next fortnight"` | `"2000-01-15T10:00Z"`
	/// `"next monday"` | `"2000-01-03T10:00Z"`
	/// `"last wednesday"` | `"1999-12-29T10:00Z"`
	/// `"next mon"` | `"2000-01-03T10:00Z"`
	/// `"last december"` | `"1999-12-01T10:00Z"`
	/// `"next jan"` | `"2001-01-01T10:00Z"`
	/// `"next june + 2 weeks"` | `"2000-06-15T10:00Z"`
	/// `"last mon + 2 weeks"` | `"2000-01-10T10:00Z"`
	/// `"+ 1 day - 2 weeks"` | `"1999-12-19T10:00Z"`
	/// `"last december + 2 weeks + 4 days"` | `"1999-12-19T10:00Z"`
	/// `"@ now"` | `"2000-01-01T10:00Z"` |
	/// `"@ midnight"` | `"2000-01-01T00:00Z"`
	/// `"@ noon"` | `"2000-01-01T12:00Z"` |
	/// `"@ 2 o'clock"` | `"2000-01-01T14:00Z"`
	/// `"@ 12 o'clock am"` | `"2000-01-01T12:00Z"`
	/// `"@ 1 o'clock pm"` | `"2000-01-01T13:00Z"`
	/// `"@ + 1 hour"` | `"2000-01-01T11:00Z"`
	/// `"@ - 2 minutes"` | `"2000-01-01T09:58Z"`
	/// `"@ + 4 seconds"` | `"2000-01-01T10:00:04Z"`
	/// `"@ + 4 milliseconds"` | `"2000-01-01T10:00:00.004Z"`
	/// `"@ midnight+ 4 minutes"` | `"2000-01-01T00:04Z"`
	/// `"@ next hour"` | `"2000-01-01T11:00Z"`
	/// `"@ last minute"` | `"2000-01-01T09:59Z"`
	/// `"@ now + 2 hours - 4 minutes"` | `"2000-01-01T11:56Z"`
	/// `"@ + 2 hours - 4 minutes"` | `"2000-01-01T11:56Z"`
	/// `"today @ 1 o'clock"` | `"2000-01-01T13:00Z"`
	/// `"yesterday @ midnight"` | `"1999-12-31T00:00Z"`
	/// `"yesterday @ midnight - 1 hour"` | `"1999-12-30T23:00Z"`
	/// `"tomorrow @ now"` | `"2000-01-02T10:00Z"`
	/// `"+ 1 day @ noon"` | `"2000-01-02T12:00Z"`
	/// `"+ 1 week @ +1 hour"` | `"2000-01-08T11:00Z"`
	/// `"- 2 weeks @ now + 1 hour"` | `"1999-12-18T11:00Z"`
	/// `"+ 4 years @ midnight"` | `"2004-01-01T00:00Z"`
	/// `"tomorrow + 4 years @ 3 o'clock + 40 milliseconds"` | `"2004-01-02T15:00:00.040Z"`
	/// `"next week @ next hour"` | `"2000-01-08T11:00Z"`
	/// `"last month @ last hour"` | `"1999-12-01T09:00Z"`
	static func generatedDate(_ value: String, format: String, expression: String? = nil) -> AnyMatcher {
		GenericMatcher(type: "type", value: value, generator: .date, format: format, expression: expression).asAny()
	}

	static func generatedDatetime(_ value: String, format: String, expression: String? = nil) -> AnyMatcher {
		GenericMatcher(type: "type", value: value, generator: .dateTime, format: format, expression: expression).asAny()
	}

	static func generatedTime(_ value: String, format: String, expression: String? = nil) -> AnyMatcher {
		GenericMatcher(type: "type", value: value, generator: .time, format: format, expression: expression).asAny()
	}

}
