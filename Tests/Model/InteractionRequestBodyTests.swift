//
//  Created by Oliver Jones on 10/1/2023.
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

import XCTest
@testable import PactSwift

final class InteractionRequestBodyTests: InteractionTestCase {

	func testRequest_Body() async throws {
		try buildRequest(
			"like",
			body: .like([
				"key": "value"
			])
		)

		struct Body: Encodable {
			var key: String
		}

		try await verify(body: Body(key: "value"), expectedStatus: 200)
	}

	func testRequest_WrongBody() async throws {
		try buildRequest(
			"like",
			body: .like([
				"key": "value"
			])
		)

		struct Body: Encodable {
			var otherKey: String
		}

		try await suppressingPactFailure {
			try await verify(body: Body(otherKey: "value"), expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingOneOf() async throws {
		try buildRequest(
			"oneOf",
			body: .like([
				"key": .oneOf(["one", "two"])
			])
		)

		struct Body: Encodable {
			enum Case: String, Encodable {
				case one, two
			}
			var key: Case
		}

		try await verify(body: Body(key: .one), expectedStatus: 200)
	}

	func testRequest_BodyMatchingOneOf_Negative() async throws {
		try buildRequest(
			"oneOf",
			body: .like([
				"key": .oneOf(["one", "two"])
			])
		)

		struct Body: Encodable {
			enum Case: String, Encodable {
				case three
			}
			var key: Case
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key: .three), expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingLike() async throws {
		try buildRequest(
			"like",
			body: .like([
				"key": .like("value")
			])
		)

		struct Body: Encodable {
			var key: String
		}

		try await verify(body: Body(key: "not value but a string"), expectedStatus: 200)
	}

	func testRequest_BodyMatchingLike_Negative() async throws {
		try buildRequest(
			"like",
			body: .like([
				"key": .like("value")
			])
		)

		struct Body: Encodable {
			var key: Int
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key: 123), expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingEachLikeMin() async throws {
		try buildRequest(
			"eachLikeMin",
			body: .like([
				"key": .eachLike("value", min: 2)
			])
		)

		struct Body: Encodable {
			var key: [String]
		}

		try await verify(body: Body(key: ["not value but a string", "another value"]), expectedStatus: 200)
	}

	func testRequest_BodyMatchingEachLikeMin_Negative() async throws {
		try buildRequest(
			"eachLikeMin",
			body: .like([
				"key": .eachLike("value", min: 2)
			])
		)

		struct Body: Encodable {
			var key: [String]
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key: ["only value"]), expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingEachLikeMax() async throws {
		try buildRequest(
			"eachLikeMax",
			body: .like([
				"key": .eachLike("value", max: 1)
			])
		)

		struct Body: Encodable {
			var key: [String]
		}

		try await verify(body: Body(key: ["not value but a string"]), expectedStatus: 200)
	}

	func testRequest_BodyMatchingEachLikeMax_Negative() async throws {
		try buildRequest(
			"eachLikeMax",
			body: .like([
				"key": .eachLike("value", max: 1)
			])
		)

		struct Body: Encodable {
			var key: [String]
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key: ["value1", "value2"]), expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingEachLikeMinMax() async throws {
		try buildRequest(
			"eachLikeMinMax",
			body: .like([
				"key": .eachLike("value", min: 1, max: 2)
			])
		)

		struct Body: Encodable {
			var key: [String]
		}

		try await verify(body: Body(key: ["1", "2"]), expectedStatus: 200)
	}

	func testRequest_BodyMatchingEachLikeMinMax_Negative() async throws {
		try buildRequest(
			"eachLikeMinMax",
			body: .like([
				"key": .eachLike("value", min: 1, max: 2)
			])
		)

		struct Body: Encodable {
			var key: [String]
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key: []), expectedStatus: 500)
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key: ["1", "2", "3"]), expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingEquals() async throws {
		try buildRequest(
			"equals",
			body: .like([
				"key1": .equals(234),
				"key2": .equals("string"),
				"key3": .equals([1,2,3])
			])
		)

		struct Body: Encodable {
			var key1: Int
			var key2: String
			var key3: [Int]
		}

		try await verify(body: Body(key1: 234, key2: "string", key3: [1,2,3]), expectedStatus: 200)
	}

	func testRequest_BodyMatchingEquals_Negative() async throws {
		try buildRequest(
			"equals",
			body: .like([
				"key1": .equals(234),
				"key2": .equals("string"),
				"key3": .equals([1,2,3])
			])
		)

		struct Body: Encodable {
			var key2: Int
			var key1: String
			var key3: [Int]
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key2: 234, key1: "string", key3: [1,2,3]), expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingIncludes() async throws {
		try buildRequest(
			"includes",
			body: .like([
				"key": .includes("sub")
			])
		)

		struct Body: Encodable {
			var key: String
		}

		try await verify(body: Body(key: "a string that includes substring"), expectedStatus: 200)
	}

	func testRequest_BodyMatchingIncludes_Negative() async throws {
		try buildRequest(
			"includes",
			body: .like([
				"key": .includes("sub")
			])
		)

		struct Body: Encodable {
			var key: String
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key: "a string without"), expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingRegex() async throws {
		try buildRequest(
			"regex",
			body: .like([
				"key1": .regex(#"\d+"#, example: "1234"),
				"key2": .regex(#"\S+"#, example: "non-white-space"),
				"ip4": .ip4Address(),
				"ip6": .ip6Address(),
				"hex": .hexadecimal(),
				"base64": .base64()
			])
		)

		struct Body: Encodable {
			var key1: Int
			var key2: String
			var ip4: String
			var ip6: String
			var hex: String
			var base64: String
		}

		let body = Body(key1: 1234, key2: "stuff-but-no-spaces", ip4: "192.168.1.1", ip6: "fdda:5cc1:23:4::1f", hex: "DEADBEEF", base64: "dGVzdCB2YWwK")
		try await verify(body: body, expectedStatus: 200)
	}

	func testRequest_BodyMatchingRegex_Negative() async throws {
		try buildRequest(
			"regex",
			body: .like([
				"key1": .regex(#"\d+"#, example: "1234"),
				"key2": .regex(#"\S+"#, example: "non-white-space"),
				"ip4": .ip4Address(),
				"ip6": .ip6Address(),
				"hex": .hexadecimal(),
				"base64": .base64()
			])
		)

		struct Body: Encodable {
			var key1: Int
			var key2: String
			var ip4: String
			var ip6: String
			var hex: String
			var base64: String
		}

		let body = Body(key1: 1234, key2: "no-spaces", ip4: "192.8.600.1", ip6: "not ip6", hex: "not hex", base64: "not base 64")

		try await suppressingPactFailure {
			try await verify(body: body, expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingInteger() async throws {
		try buildRequest(
			"integer",
			body: .like([
				"key": .integer(1)
			])
		)

		struct Body: Encodable {
			var key: Int
		}

		try await verify(body: Body(key: 10), expectedStatus: 200)
	}

	func testRequest_BodyMatchingInteger_Negative() async throws {
		try buildRequest(
			"integer",
			body: .like([
				"key": .integer(1)
			])
		)

		struct Body: Encodable {
			var key: String
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key: "10"), expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingDecimal() async throws {
		try buildRequest(
			"decimal",
			body: .like([
				"key": .decimal(123.1)
			])
		)

		struct Body: Encodable {
			var key: Double
		}

		try await verify(body: Body(key: 321.1), expectedStatus: 200)
	}

	func testRequest_BodyMatchingDecimal_Negative() async throws {
		try buildRequest(
			"decimal",
			body: .like([
				"key": .decimal(123)
			])
		)

		struct Body: Encodable {
			var key: Int
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key: 123), expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingNumber() async throws {
		try buildRequest(
			"number",
			body: .like([
				"key1": .number(123.1),
				"key2": .number(321)
			])
		)

		struct Body: Encodable {
			var key1: Double
			var key2: Int
		}

		try await verify(body: Body(key1: 321.1, key2: 456), expectedStatus: 200)
	}

	func testRequest_BodyMatchingNumber_Negative() async throws {
		try buildRequest(
			"number",
			body: .like([
				"key1": .number(123.1),
				"key2": .number(321)
			])
		)

		struct Body: Encodable {
			var key1: String
			var key2: String
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key1: "321.1", key2: "456"), expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingDatetime() async throws {
		try buildRequest(
			"datetime",
			body: .like([
				"key": .datetime("2022-01-01 12:33:22", format: "yyyy-MM-dd HH:mm:ss")
			])
		)

		struct Body: Encodable {
			var key: String
		}

		try await verify(body: Body(key: "1999-02-28 14:22:11"), expectedStatus: 200)
	}

	func testRequest_BodyMatchingDatetime_Negative() async throws {
		try buildRequest(
			"datetime",
			body: .like([
				"key": .datetime("2022-01-01 12:33:22", format: "yyyy-MM-dd HH:mm:ss")
			])
		)

		struct Body: Encodable {
			var key: String
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key: "not a datetime"), expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingDate() async throws {
		try buildRequest(
			"date",
			body: .like([
				"key": .date("2022-01-01", format: "yyyy-MM-dd")
			])
		)

		struct Body: Encodable {
			var key: String
		}

		try await verify(body: Body(key: "1999-02-28"), expectedStatus: 200)
	}

	func testRequest_BodyMatchingDate_Negative() async throws {
		try buildRequest(
			"date",
			body: .like([
				"key": .date("2022-01-01", format: "yyyy-MM-dd")
			])
		)

		struct Body: Encodable {
			var key: String
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key: "not a date"), expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingTime() async throws {
		try buildRequest(
			"time",
			body: .like([
				"key": .time("12:33:22", format: "HH:mm:ss")
			])
		)

		struct Body: Encodable {
			var key: String
		}

		try await verify(body: Body(key: "14:22:11"), expectedStatus: 200)
	}

	func testRequest_BodyMatchingTime_Negative() async throws {
		try buildRequest(
			"time",
			body: .like([
				"key": .time("12:33:22", format: "HH:mm:ss")
			])
		)

		struct Body: Encodable {
			var key: String
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key: "not a time"), expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingNull() async throws {
		try buildRequest(
			"null",
			body: .like([
				"key": .null()
			])
		)

		struct Body: Encodable {
			@NullEncodable var key: String?
		}

		try await verify(body: Body(key: nil), expectedStatus: 200)
	}

	func testRequest_BodyMatchingNull_Negative() async throws {
		try buildRequest(
			"null",
			body: .like([
				"key": .null()
			])
		)

		struct Body: Encodable {
			var key: String?
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key: "not null"), expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingBool() async throws {
		try buildRequest(
			"bool",
			body: .like([
				"key1": .bool(true),
				"key2": .bool(false),
				"key3": .like(true)
			])
		)

		struct Body: Encodable {
			var key1: Bool
			var key2: String
			var key3: Bool
		}

		try await verify(body: Body(key1: true, key2: "false", key3: false), expectedStatus: 200)
	}

	func testRequest_BodyMatchingBool_Negative() async throws {
		try buildRequest(
			"bool",
			body: .like([
				"key1": .bool(true),
				"key2": .bool(false),
				"key3": .like(true)
			])
		)

		struct Body: Encodable {
			var key1: String
			var key2: String
			var key3: Bool
		}

		try await suppressingPactFailure {
		try await verify(body: Body(key1: "not a bool", key2: "false", key3: false), expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingNotEmpty() async throws {
		try buildRequest(
			"notEmpty",
			body: .like([
				"key1": .notEmpty(),
				"key2": .notEmpty()
			])
		)

		struct Body: Encodable {
			@NullEncodable var key1: String?
			var key2: String
		}

		try await verify(body: Body(key1: "not empty", key2: "not empty"), expectedStatus: 200)
	}

	func testRequest_BodyMatchingNotEmpty_Negative() async throws {
		try buildRequest(
			"notEmpty",
			body: .like([
				"key1": .notEmpty(),
				"key2": .notEmpty()
			])
		)

		struct Body: Encodable {
			@NullEncodable var key1: String?
			var key2: String
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key1: nil, key2: "not empty"), expectedStatus: 500)
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key1: "not empty", key2: ""), expectedStatus: 500)
		}
	}

	func testRequest_BodyMatchingSemVer() async throws {
		try buildRequest(
			"semVer",
			body: .like([
				"key": .semver("1.0.0")
			])
		)

		struct Body: Encodable {
			var key: String
		}

		try await verify(body: Body(key: "1.0.0-beta1"), expectedStatus: 200)
	}

	func testRequest_BodyMatchingSemVer_Negative() async throws {
		try buildRequest(
			"semVer",
			body: .like([
				"key": .semver("1.0.0")
			])
		)

		struct Body: Encodable {
			var key: String
		}

		try await suppressingPactFailure {
			try await verify(body: Body(key: "not semver"), expectedStatus: 500)
		}
	}

	// MARK: - Helpers

	func buildRequest(_ matcher: String, body: AnyMatcher) throws {
		try builder
			.uponReceiving("a request for a known path with a body matching \(matcher)")
			.withRequest(method: .POST, path: "/jsonbody") { request in
				try request.jsonBody(body)
			}
			.willRespond(with: 200)
	}

	func verify<T: Encodable>(body: T, expectedStatus: Int) async throws {
		try await builder.verify { ctx in
			let request = try buildURLRequest(for: ctx, path: "/jsonbody", body: body)
			let (_, response) = try await session.data(for: request)

			let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
			XCTAssertEqual(httpResponse.statusCode, expectedStatus)
		}
	}

	func buildURLRequest<T: Encodable>(for context: PactBuilder.ConsumerContext, path: String, body: T) throws -> URLRequest {
		var components = try XCTUnwrap(URLComponents(url: context.mockServerURL, resolvingAgainstBaseURL: false))
		components.path = path

		var request = URLRequest(url: try XCTUnwrap(components.url))
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpMethod = "POST"
		request.httpBody = try JSONEncoder().encode(body)

		return request
	}

}

@propertyWrapper
private struct NullEncodable<T>: Encodable where T: Encodable {

	var wrappedValue: T?

	init(wrappedValue: T?) {
		self.wrappedValue = wrappedValue
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch wrappedValue {
		case .some(let value): try container.encode(value)
		case .none: try container.encodeNil()
		}
	}
}
