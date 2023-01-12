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

// MARK: - Generators

public extension Matcher {

	// Not sure how to implement these best.
	// TODO: "Regex"
	// TODO: "ProviderState"

	/// Generate a MockServer URL.
	///
	/// - Parameters:
	///   - example: An example URL eg `"http://localhost:8080/orders/1234"`
	///   - regex: A regex to extract the relevant part of the example, eg: `"^.*(/orders/\\d+)$"` that will be combine with the mock server URL.
	///     **Note** this regex *must* include a single capture group!
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
