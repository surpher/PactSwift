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
			
			let request = try buildURLRequest(for: ctx, path: "/interaction", headers: ["x-header": "value"])
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
			
			let request = try buildURLRequest(for: ctx, path: "/interaction", headers: ["x-header": "value"])
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
			
			let request = try buildURLRequest(for: ctx, path: "/interaction", headers: ["x-header": "value"])
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
				let request = try buildURLRequest(for: ctx, path: "/interaction", headers: ["x-header": "wrong value"])
				let (_, response) = try await session.data(for: request)
				
				let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
				XCTAssertEqual(httpResponse.statusCode, 500)
			}
		}
	}
	
	func buildURLRequest(for context: PactBuilder.ConsumerContext, path: String, headers: [String: String?] = [:]) throws -> URLRequest {
		var components = try XCTUnwrap(URLComponents(url: context.mockServerURL, resolvingAgainstBaseURL: false))
		components.path = path
		
		var request = URLRequest(url: try XCTUnwrap(components.url))
		for header in headers {
			request.setValue(header.value, forHTTPHeaderField: header.key)
		}
		
		return request
	}
}
