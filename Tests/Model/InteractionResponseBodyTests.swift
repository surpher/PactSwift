//
//  Created by Oliver Jones on 11/1/2023.
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

final class InteractionResponseBodyTests: InteractionTestCase {

	func testRequest_Body() async throws {
		try buildRequest(
			"like",
			responseBody: .like([
				"url": .generatedMockServerUrl(example: "http://example.com/orders/1234", regex: #".*(/orders/\d+)$"#),
				"string": .randomString(like: "example"),
				"int": .randomInteger(1...100),
				"decimal": .randomDecimal(like: 2.7, digits: 2),
				"hex": .randomHexadecimal(like: "DEADBEEF"),
				"bool": .randomBoolean(),
				"uuid": .randomUUID(like: UUID())
			])
		)

		struct Body: Decodable {
			var url: URL
			var string: String
			var int: Int
			var decimal: Decimal
			var hex: String
			var bool: Bool?
			var uuid: UUID?
		}

		try await verify(Body.self, expectedStatus: 200) { body in
			XCTAssertTrue(body.url.absoluteString.hasSuffix("/orders/1234"))
			XCTAssertEqual(body.string.count, "example".count)
			XCTAssertGreaterThanOrEqual(body.int, 1)
			XCTAssertLessThanOrEqual(body.int, 100)
			XCTAssertGreaterThanOrEqual(body.decimal, 0)
			XCTAssertLessThan(body.decimal, 10.0)
			XCTAssertEqual(body.hex.count, 8)
			XCTAssertNotNil(body.bool)
			XCTAssertNotNil(body.uuid)
		}
	}

	func testRequest_BodyDates() async throws {
		try buildRequest(
			"like",
			responseBody: .like([
				"datetime": .generatedDatetime("20020228234532", format: "yyyyMMddHHmmss", expression:"+ 1 day @ noon"),
				"date": .generatedDate("20020228", format: "yyyyMMdd", expression:"+ 1 day"),
				"time": .generatedTime("234532", format: "HHmmss", expression:"noon")
			])
		)

		struct Body: Decodable {
			var datetime: String
			var date: String
			var time: String
		}

		let dateTimeFormatString: Date.FormatString = "\(year: .defaultDigits)\(month: .twoDigits)\(day: .twoDigits)\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased))\(minute: .twoDigits)\(second: .twoDigits)"
		let dateFormatString: Date.FormatString = "\(year: .defaultDigits)\(month: .twoDigits)\(day: .twoDigits)"
		let timeFormatString: Date.FormatString = "\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased))\(minute: .twoDigits)\(second: .twoDigits)"

		let calendar = Calendar.current
		let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
		let tomorrow = calendar.date(byAdding: DateComponents(day: 1), to: noon)

		let expectedDatetime = try XCTUnwrap(tomorrow?.formatted(.verbatim(dateTimeFormatString, timeZone: TimeZone.current, calendar: calendar)))
		let expectedDate = try XCTUnwrap(tomorrow?.formatted(.verbatim(dateFormatString, timeZone: TimeZone.current, calendar: calendar)))
		let expectedTime = try XCTUnwrap(tomorrow?.formatted(.verbatim(timeFormatString, timeZone: TimeZone.current, calendar: calendar)))

		try await verify(Body.self, expectedStatus: 200) { body in
			XCTAssertEqual(body.datetime, expectedDatetime)
			XCTAssertEqual(body.date, expectedDate)
			XCTAssertEqual(body.time, expectedTime)
		}
	}

	func testRequest_LikeArrayBody() async throws {
		try buildRequest(
			"eachLike",
			responseBody: .like([1,2,3])
		)

		try await verify([Int].self, expectedStatus: 200) { body in
			XCTAssertEqual(body.count, 3)
		}
	}

	func testRequest_NestedBody() async throws {
		try buildRequest(
			"eachLike",
			responseBody: .like(
				[
					"nest": .like(["key": "value"])
				]
			)
		)

		struct Body: Decodable {
			struct Nest: Decodable {
				var key: String
			}
			var nest: Nest
		}

		try await verify(Body.self, expectedStatus: 200) { body in
			XCTAssertEqual(body.nest.key, "value")
		}
	}

	func testRequest_EmptyArrayBody() async throws {
		try buildRequest(
			"emptyArray",
			responseBody: .emptyArray()
		)

		try await verify([Int].self, expectedStatus: 200) { body in
			XCTAssertTrue(body.isEmpty)
		}
	}

	func testRequest_EmptyNestedArrayBody() async throws {
		try buildRequest(
			"emptyNestedArray",
			responseBody: .like(
				[
					"nest" : .emptyArray()
				]
			)
		)

		struct Body: Decodable {
			struct Nest: Decodable {
				var key: String
			}
			var nest: [Nest]
		}

		try await verify(Body.self, expectedStatus: 200) { body in
			XCTAssertTrue(body.nest.isEmpty)
		}
	}

	// MARK: - Helpers

	func buildRequest(_ matcher: String, responseBody: AnyMatcher) throws {
		try builder
			.uponReceiving("a response for a known path with a body matching \(matcher)")
			.withRequest(method: .GET, path: "/jsonresponse")
			.willRespond(with: 200) { response in
				try response.jsonBody(responseBody)
			}
	}

	func verify<T: Decodable & Sendable>(_ type: T.Type, expectedStatus: Int, verifyBody: @Sendable (T) -> Void) async throws {
		try await builder.verify { ctx in
			let request = try ctx.buildURLRequest(path: "/jsonresponse")
			let (data, response) = try await URLSession(configuration: .ephemeral).data(for: request)

			let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
			XCTAssertEqual(httpResponse.statusCode, expectedStatus)

			let body = try JSONDecoder().decode(T.self, from: data)
			verifyBody(body)
		}
	}
}

extension PactBuilder.ConsumerContext {
	func buildURLRequest(path: String) throws -> URLRequest {
		var components = try XCTUnwrap(URLComponents(url: mockServerURL, resolvingAgainstBaseURL: false))
		components.path = path

		var request = URLRequest(url: try XCTUnwrap(components.url))
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")

		return request
	}
}
