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

final class InteractionRequestTests: InteractionTestCase {

	func testRequest_KnownPath() async throws {
		try builder
			.uponReceiving("a request for a known path")
			.withRequest(path: "/known")
			.willRespond(with: 200)

		try await builder.verify { ctx in
			let url = try ctx.buildRequestURL(path: "/known")
			let (data, response) = try await URLSession(configuration: .ephemeral).data(from: url)

			let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
			XCTAssertEqual(httpResponse.statusCode, 200)
			XCTAssertTrue(data.isEmpty)
		}
	}

	func testRequest_UnknownPath() async throws {
		try builder
			.uponReceiving("a request for a known path")
			.withRequest(path: "/known")
			.willRespond(with: 200)

		try await suppressingPactFailure {
			try await builder.verify { ctx in
				let url = try ctx.buildRequestURL(path: "/unknown")
				let (_, response) = try await URLSession(configuration: .ephemeral).data(from: url)

				let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
				XCTAssertEqual(httpResponse.statusCode, 500)
			}
		}
	}

	func testRequest_WrongMethod() async throws {
		try builder
			.uponReceiving("a request for a known path")
			.withRequest(method: .GET, path: "/known")
			.willRespond(with: 200)

		try await suppressingPactFailure {
			try await builder.verify { ctx in
				let url = try ctx.buildRequestURL(path: "/unknown")
				var request = URLRequest(url: url)
				request.httpMethod = "POST"
				let (_, response) = try await URLSession(configuration: .ephemeral).data(for: request)

				let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
				XCTAssertEqual(httpResponse.statusCode, 500)
			}
		}
	}

	func testRequest_KnownRegexPath() async throws {
		try builder
			.uponReceiving("a request for a known regex path")
			.withRequest(regex: #"^/\w\d$"#, example: "/a1")
			.willRespond(with: 200)

		try await builder.verify { ctx in
			let url = try ctx.buildRequestURL(path: "/b2")
			let (data, response) = try await URLSession(configuration: .ephemeral).data(from: url)

			let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
			XCTAssertEqual(httpResponse.statusCode, 200)
			XCTAssertTrue(data.isEmpty)
		}
	}

	func testRequest_UnknownRegexPath() async throws {
		try builder
			.uponReceiving("a request for a known regex path")
			.withRequest(regex: #"^/\w\d$"#, example: "/a1")
			.willRespond(with: 200)

		try await suppressingPactFailure {
			try await builder.verify { ctx in
				let url = try ctx.buildRequestURL(path: "/something")
				let (_, response) = try await URLSession(configuration: .ephemeral).data(from: url)

				let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
				XCTAssertEqual(httpResponse.statusCode, 500)
			}
		}
	}
}

extension PactBuilder.ConsumerContext {
	func buildRequestURL(path: String) throws -> URL {
		var components = try XCTUnwrap(URLComponents(url: mockServerURL, resolvingAgainstBaseURL: false))
		components.path = path
		return try XCTUnwrap(components.url)
	}
}
