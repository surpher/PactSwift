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

import XCTest

@testable import PactSwift

final class InteractionTests: InteractionTestCase {

	func testGetEvents() async throws {
		try builder
			.uponReceiving("a request to retrieve all events with no authorization")
			.given("There are events")
			.withRequest(path: "/events") { request in
				try request
					.queryParam(name: "something", value: "orOther")
					.queryParam(name: "limit", matching: .decimal(100))
					.queryParam(name: "includeOthers", matching: .bool(false))
			}
			.willRespond(with: 200) { response in
				try response.htmlBody()
			}

		try await builder.verify { ctx in
			var components = try XCTUnwrap(URLComponents(url: ctx.mockServerURL, resolvingAgainstBaseURL: false))
			components.path = "/events"
			components.queryItems = [
				URLQueryItem(name: "something", value: "orOther"),
				URLQueryItem(name: "limit", value: "100"),
				URLQueryItem(name: "includeOthers", value: "false")
			]

			let (data, response) = try await session.data(from: try XCTUnwrap(components.url))

			let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
			XCTAssertEqual(httpResponse.statusCode, 200)
			XCTAssertEqual(httpResponse.value(forHTTPHeaderField: "Content-Type"), "text/html")
			XCTAssertTrue(data.isEmpty)
		}
	}

	func testCreateEvent() async throws {
		try builder
			.uponReceiving("a request to create an event with no authorization")
			.given("There are events")
			.withRequest(method: .POST, path: "/events") { request in
				try request.header("Accept", value: "application/json")
			}
			.willRespond(with: 201) { response in
				try response.htmlBody("OK")
			}

		try await builder.verify { ctx in
			var components = try XCTUnwrap(URLComponents(url: ctx.mockServerURL, resolvingAgainstBaseURL: false))
			components.path = "/events"

			var request = URLRequest(url: try XCTUnwrap(components.url))
			request.httpMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Accept")

			let (data, response) = try await session.data(for: request)

			let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
			XCTAssertEqual(httpResponse.statusCode, 201)
			XCTAssertEqual(httpResponse.value(forHTTPHeaderField: "Content-Type"), "text/html")
			XCTAssertEqual(data, "OK".data(using: .utf8))
		}
	}

	func testGetEvent() async throws {

		struct Response: Decodable {
			var id: String
			var age: Int
			var name: String
			var postcodes: [Int]
			var something: String
			var hex: String
			var birthday: String
		}

		try builder
			.uponReceiving("a request for an event with no authorization")
			.given("There are events")
			.withRequest(method: .GET, regex: #"/events/\d+"#, example: "/events/100") { request in
				try request
					.queryParam(name: "sorted", matching: .bool(true))
					.header("Accept", value: "application/json")
					.header("X-Version", matching: .integer(1))
			}
			.willRespond(with: 200) { response in
				try response.jsonBody(
					.like([
						"id": .randomUUID("urn:uuid:\(UUID())", format: .urn),
						"age": .randomInteger(like: 1, range: 1...100),
						"name": .randomString("An name", size: 50),
						"postcodes": .like([AnyMatcher.integer(1234)], max: 2),
						"something": .regex(#"\d{4}"#, example: "1234"),
						"hex": .randomHexadecimal("DEADBEEF", digits: 8),
						"birthday": .randomDate("2022-12-11", format: "yyyy-MM-dd", expression: "+ 1 day")
					])
				)
			}

		try await builder.verify { ctx in
			var components = try XCTUnwrap(URLComponents(url: ctx.mockServerURL, resolvingAgainstBaseURL: false))
			components.path = "/events/23"
			components.queryItems = [URLQueryItem(name: "sorted", value: "true")]

			var request = URLRequest(url: try XCTUnwrap(components.url))
			request.setValue("application/json", forHTTPHeaderField: "Accept")
			request.setValue("1", forHTTPHeaderField: "X-Version")

			let (data, response) = try await session.data(for: request)

			let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
			XCTAssertEqual(httpResponse.statusCode, 200)
			XCTAssertEqual(httpResponse.value(forHTTPHeaderField: "Content-Type"), "application/json")

			let body = try JSONDecoder().decode(Response.self, from: data)

			XCTAssertEqual(body.id.prefix(9), "urn:uuid:")
			XCTAssertGreaterThanOrEqual(body.age, 1)
			XCTAssertLessThanOrEqual(body.age, 100)
			XCTAssertEqual(body.name.count, 50)
			XCTAssertFalse(body.postcodes.isEmpty)
			XCTAssertGreaterThanOrEqual(body.postcodes.count, 1)
			XCTAssertEqual(body.something, "1234")
			XCTAssertEqual(body.hex.count, 8)
		}
	}

}
