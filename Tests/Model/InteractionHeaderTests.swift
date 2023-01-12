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

import XCTest
@testable import PactSwift

final class InteractionHeaderTests: InteractionTestCase {
	
	func testRequestHeaderWithValue() async throws {
		try builder
			.uponReceiving("an interaction with header value")
			.withRequest(path: "/interaction") { request in
				try request.header("x-header", value: "value")
			}
			.willRespond(with: 200)
		
		try await builder.verify { ctx in
			
			let request = try buildURLRequest(for: ctx, path: "/interaction", headers: [("x-header", "value")])
			let (data, response) = try await session.data(for: request)
			
			let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
			XCTAssertEqual(httpResponse.statusCode, 200)
			XCTAssertTrue(data.isEmpty)
		}
	}
	
	func testResponseHeaderWithValue() async throws {
		try builder
			.uponReceiving("an interaction with header value")
			.withRequest(path: "/interaction")
			.willRespond(with: 200) { response in
				try response.header("x-header", value: "value")
			}
		
		try await builder.verify { ctx in
			
			let request = try buildURLRequest(for: ctx, path: "/interaction", headers: [("x-header", "value")])
			let (data, response) = try await session.data(for: request)
			
			let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
			XCTAssertEqual(httpResponse.statusCode, 200)
			XCTAssertEqual(httpResponse.value(forHTTPHeaderField: "x-header"), "value")
			XCTAssertTrue(data.isEmpty)
		}
	}
	
	func testResponseHeaderWithGeneratedValue() async throws {
		try builder
			.uponReceiving("an interaction with header value")
			.withRequest(path: "/interaction")
			.willRespond(with: 200) { response in
				try response.header("x-header", matching: .randomString(like: "something", size: 20))
			}
		
		try await builder.verify { ctx in
			
			let request = try buildURLRequest(for: ctx, path: "/interaction", headers: [("x-header", "value")])
			let (data, response) = try await session.data(for: request)
			
			let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
			XCTAssertEqual(httpResponse.statusCode, 200)
			XCTAssertEqual(httpResponse.value(forHTTPHeaderField: "x-header")?.count, 20)
			XCTAssertTrue(data.isEmpty)
		}
	}
	
	func testRequestHeaderWithMissingValue() async throws {
		try builder
			.uponReceiving("an interaction with header value")
			.withRequest(path: "/interaction") { request in
				try request.header("x-header", value: "value")
			}
			.willRespond(with: 200)
		
		try await suppressingPactFailure {
			try await builder.verify { ctx in
				let request = try buildURLRequest(for: ctx, path: "/interaction")
				let (_, response) = try await session.data(for: request)
				
				let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
				XCTAssertEqual(httpResponse.statusCode, 500)
			}
		}
	}
	
	func testRequestHeaderWithWrongValue() async throws {
		try builder
			.uponReceiving("an interaction with header value")
			.withRequest(path: "/interaction") { request in
				try request.header("x-header", value: "value")
			}
			.willRespond(with: 200)
		
		try await suppressingPactFailure {
			try await builder.verify { ctx in
				let request = try buildURLRequest(for: ctx, path: "/interaction", headers: [("x-header", "wrong value")])
				let (_, response) = try await session.data(for: request)
				
				let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
				XCTAssertEqual(httpResponse.statusCode, 500)
			}
		}
	}

	func testRequestHeaderWithMultipleValues() async throws {
		try builder
			.uponReceiving("an interaction with header value")
			.withRequest(path: "/interaction") { request in
				try request.header("x-header", values: ["value1", "value2"])
			}
			.willRespond(with: 200)

		try await suppressingPactFailure {
			try await builder.verify { ctx in
				let request = try buildURLRequest(for: ctx, path: "/interaction", headers: [("x-header", "value1"), ("x-header", "value2")])
				let (_, response) = try await session.data(for: request)

				let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
				XCTAssertEqual(httpResponse.statusCode, 200)
			}
		}
	}

	func testRequestHeaderWithMultipleValues_Negative() async throws {
		try builder
			.uponReceiving("an interaction with header value")
			.withRequest(path: "/interaction") { request in
				try request.header("x-header", values: ["value1", "value2"])
			}
			.willRespond(with: 200)

		try await suppressingPactFailure {
			try await builder.verify { ctx in
				let request = try buildURLRequest(for: ctx, path: "/interaction", headers: [("x-header", "value1")])
				let (_, response) = try await session.data(for: request)

				let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
				XCTAssertEqual(httpResponse.statusCode, 500)
			}
		}
	}

	func testHeaderMatchingBoolean() async throws {
		try await performMatcherTest(named: "bool(true)", matcher: .bool(true), value: "true")
	}

	func testHeaderMatchingBoolean_Negative() async throws {
		try await performMatcherNegativeTest(named: "bool(true)", matcher: .bool(true), value: "not a bool")
	}

	func testHeaderMatchingNotEmpty() async throws {
		try await performMatcherTest(named: "notEmpty", matcher: .notEmpty(), value: "not-empty")
	}

	func testHeaderMatchingNotEmpty_Negative() async throws {
		try await performMatcherNegativeTest(named: "notEmpty", matcher: .notEmpty(), value: "")
	}

	func testHeaderMatchingSemVer() async throws {
		try await performMatcherTest(named: "semver", matcher: .semver("1.2.3"), value: "1.2.3-beta1")
	}

	func testHeaderMatchingSemVer_Negative() async throws {
		try await performMatcherNegativeTest(named: "semver", matcher: .semver("1.2.3"), value: "not semver")
	}

	func testHeaderMatchingDate() async throws {
		try await performMatcherTest(named: "date", matcher: .date("1999-12-01", format: "yyyy-MM-dd"), value: "2000-01-12")
	}

	func testHeaderMatchingDate_Negative() async throws {
		try await performMatcherNegativeTest(named: "date", matcher: .date("1999-12-01", format: "yyyy-MM-dd"), value: "not a date")
	}

	func testHeaderMatchingTime() async throws {
		try await performMatcherTest(named: "time", matcher: .time("12:02", format: "HH:mm"), value: "10:12")
	}

	func testHeaderMatchingTime_Negative() async throws {
		try await performMatcherNegativeTest(named: "time", matcher: .time("12:02", format: "HH:mm"), value: "not a time")
	}

	func testHeaderMatchingDateTime() async throws {
		try await performMatcherTest(named: "datetime", matcher: .datetime("2022-01-09 12:02:12", format: "yyyy-MM-dd HH:mm:ss"), value: "2034-02-01 10:12:33")
	}

	func testHeaderMatchingDateTime_Negative() async throws {
		try await performMatcherNegativeTest(named: "datetime", matcher: .datetime("2022-01-09 12:02:12", format: "yyyy-MM-dd HH:mm:ss"), value: "not timestamp")
	}

	func testHeaderMatchingNumber() async throws {
		try await performMatcherTest(named: "number", matcher: .number(1234), value: "1234")
	}

	func testHeaderMatchingNumber_Negative() async throws {
		try await performMatcherNegativeTest(named: "number", matcher: .number(1234), value: "not a number")
	}

	func testHeaderMatchingInteger() async throws {
		try await performMatcherTest(named: "integer", matcher: .integer(4567), value: "4567")
	}

	func testHeaderMatchingInteger_Negative() async throws {
		try await performMatcherNegativeTest(named: "integer", matcher: .integer(4567), value: "not a number")
	}

	func testHeaderMatchingDecimal() async throws {
		try await performMatcherTest(named: "decimal", matcher: .decimal(4567.78), value: "4567.78")
	}

	func testHeaderMatchingDecimal_Negative() async throws {
		try await performMatcherNegativeTest(named: "decimal", matcher: .decimal(4567.78), value: "not a decimal")
	}

	func testHeaderMatchingIncludes() async throws {
		try await performMatcherTest(named: "includes", matcher: .includes("sub"), value: "substring")
	}

	func testHeaderMatchingIncludes_Negative() async throws {
		try await performMatcherNegativeTest(named: "includes", matcher: .includes("sub"), value: "string")
	}

	func testHeaderMatchingLikeString() async throws {
		try await performMatcherTest(named: "like", matcher: .like("string"), value: "a string")
	}

	func testHeaderMatchingRegex() async throws {
		try await performMatcherTest(named: "regex", matcher: .regex(#"\w+"#, example: "wordchars"), value: "stuff_that_is_words")
	}

	func testHeaderMatchingRegex_Negative() async throws {
		try await performMatcherNegativeTest(named: "regex", matcher: .regex(#"\d+"#, example: "1234"), value: "not numbers")
	}

	func testHeaderMatchingEquals() async throws {
		try await performMatcherTest(named: "equals", matcher: .equals("a string"), value: "a string")
	}

	func testHeaderMatchingEquals_Negative() async throws {
		try await performMatcherNegativeTest(named: "equals", matcher: .equals("a string"), value: "not equal")
	}

	// MARK: - Helpers

	private func performMatcherTest(named: String, matcher: AnyMatcher, value: String) async throws {
		try builder
			.uponReceiving("a header interaction with item matching \(named) ")
			.withRequest(path: "/headerinteraction") { request in
				try request.header("item", matching: matcher)
			}
			.willRespond(with: 200)

		try await builder.verify { ctx in
			let request = try buildURLRequest(for: ctx, path: "/headerinteraction", headers: [("item", value)])
			let (_, response) = try await session.data(for: request)

			let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
			XCTAssertEqual(httpResponse.statusCode, 200)
		}
	}

	private func performMatcherNegativeTest(named: String, matcher: AnyMatcher, value: String) async throws {
		try builder
			.uponReceiving("a header interaction with item matching \(named)")
			.withRequest(path: "/headerinteraction") { request in
				try request.header("item", matching: matcher)
			}
			.willRespond(with: 200)

		try await suppressingPactFailure {
			try await builder.verify { ctx in
				let request = try buildURLRequest(for: ctx, path: "/headerinteraction", headers: [("item", value)])
				let (_, response) = try await session.data(for: request)

				let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
				XCTAssertEqual(httpResponse.statusCode, 500)
			}
		}
	}

	private func buildURLRequest(for context: PactBuilder.ConsumerContext, path: String, headers: [(String, String)] = []) throws -> URLRequest {
		var components = try XCTUnwrap(URLComponents(url: context.mockServerURL, resolvingAgainstBaseURL: false))
		components.path = path
		
		var request = URLRequest(url: try XCTUnwrap(components.url))
		for header in headers {
			request.addValue(header.1, forHTTPHeaderField: header.0)
		}
		
		return request
	}
}
