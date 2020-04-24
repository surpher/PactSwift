//
//  MockServiceTests.swift
//  PactSwiftTests
//
//  Created by Marko Justinek on 15/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
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

class MockServiceTests: XCTestCase {

	var mockService: MockService!
	var errorCapture: ErrorCapture!

	// MARK: - Lifecycle

	override func setUp() {
		super.setUp()

		errorCapture = ErrorCapture()
		mockService = MockService(consumer: "pactswift-unit-tests", provider: "unit-test-api-provider", errorReporter: errorCapture)
	}

	override func tearDown() {
		mockService.finalize()
		
		mockService = nil
		errorCapture = nil

		super.tearDown()
	}

	// MARK: - Tests

	func testMockService_SuccessfulGETRequest() {
		_ = mockService
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .GET, path: "/user")
			.willRespondWith(
				status: 200,
				body: [
					"foo": "bar"
				]
			)

		mockService.run { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/user")!) { data, response, error in
				if let data = data {
					let testResult = self.decodeResponse(data: data)
					XCTAssertEqual(testResult?.foo, "bar")
				}
				completion()
			}
			task.resume()
		}
	}

	func testMockService_Fails_WhenRequestMissing() {
		_ = mockService
			.uponReceiving("Request for alligators")
			.given("alligators exist")
			.withRequest(method: .GET, path: "/actors")
			.willRespondWith(
				status: 200
			)

		mockService.run { $0() }

		do {
			let testResult = try XCTUnwrap(errorCapture.error?.message)
			XCTAssertTrue(testResult.contains("Missing request"))
		} catch {
			XCTFail("Expected errorCapture object to intercept the failing tests message")
		}
	}

	func testMockService_Fails_WhenRequestPathInvalid() {
		let expectedValues = [
			"Failed to verify Pact!",
			"Actual request does not match expected interactions...",
			"Missing request",
			"Request",
			"/user",
			"Error",
			"/invalidPath"
		]

		_ = mockService
			.uponReceiving("Request for alligators")
			.given("alligators exist")
			.withRequest(method: .GET, path: "/user")
			.willRespondWith(
				status: 200,
				body: [
					"foo": "bar"
				]
			)

		mockService.run { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/invalidPath")!) { data, response, error in
				completion()
			}
			task.resume()
		}

		do {
			let testResult = try XCTUnwrap(errorCapture.error?.message)
			XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })
		} catch {
			XCTFail("Expected errorCapture object to intercept the failing tests message")
		}
	}

	func testMockService_Fails_WhenUnexpectedQuery() {
		let expectedValues = [
			"Failed to verify Pact!",
			"Actual request does not match expected interactions...",
			"Request does not match",
			"Request",
			"GET /user",
			"state", "NSW",
			"Error",
			"query param 'page'",
			"query param 'state'"
		]

		_ = mockService
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .GET, path: "/user", query: ["state": ["NSW"], "page": ["2"]])
			.willRespondWith(
				status: 200
			)

		mockService.run { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/user?state=VIC")!) { data, response, error in
				completion()
			}
			task.resume()
		}

		do {
			let testResult = try XCTUnwrap(errorCapture.error?.message)
			XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })
		} catch {
			XCTFail("Expected errorCapture object to intercept the failing tests message")
		}
	}

	func testMockService_Fails_WhenBodyMismatch() {
		let expectedValues = [
			"Failed to verify Pact!",
			"Actual request does not match expected interactions...",
			"Request does not match",
			"Body in request does not match the expected body definition"
		]

		_ = mockService
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .POST, path: "/user", body: ["foo": "bar"])
			.willRespondWith(
				status: 201
			)

		mockService.run { completion in
			let requestURL = URL(string: "\(self.mockService.baseUrl)/user")!
			let session = URLSession.shared
			var request = URLRequest(url: requestURL)

			request.httpMethod = "POST"
			request.httpBody = "{\"foo\":\"baz\"}".data(using: .utf8)!

			let task = session.dataTask(with: request) { data, response, error in
				completion()
			}
			task.resume()
		}

		do {
			let testResult = try XCTUnwrap(errorCapture.error?.message)
			XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })
		} catch {
			XCTFail("Expected errorCapture object to intercept the failing tests message")
		}
	}

	func testMockService_Fails_WhenBodyIsEmptyObject() {

		let expectedValues = [
			"Failed to verify Pact!",
			"Actual request does not match expected interactions...",
			"Request does not match",
			"Body in request does not match the expected body definition"
		]

		_ = mockService
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .POST, path: "/user", body: ["foo": "bar"])
			.willRespondWith(
				status: 201
			)

		mockService.run { completion in
			let requestURL = URL(string: "\(self.mockService.baseUrl)/user")!
			let session = URLSession.shared
			var request = URLRequest(url: requestURL)

			request.httpMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = "{\n\n}".data(using: .utf8)!

			let task = session.dataTask(with: request) { data, response, error in
				completion()
			}
			task.resume()
		}

		do {
			let testResult = try XCTUnwrap(errorCapture.error?.message)
			XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })
		} catch {
			XCTFail("Expected errorCapture object to intercept the failing tests message")
		}
	}

	func testMockService_Fails_WhenRequestBodyMissing() {
		let expectedValues = [
			"Failed to verify Pact!",
			"Actual request does not match expected interactions...",
			"Request does not match",
			"Body in request does not match the expected body definition"
		]

		_ = mockService
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .POST, path: "/user", body: ["foo": "bar"])
			.willRespondWith(
				status: 201
			)

		mockService.run { completion in
			let requestURL = URL(string: "\(self.mockService.baseUrl)/user")!
			let session = URLSession.shared
			var request = URLRequest(url: requestURL)
			request.httpMethod = "POST"
			let task = session.dataTask(with: request) { data, response, error in
				completion()
			}
			task.resume()
		}

		do {
			let testResult = try XCTUnwrap(errorCapture.error?.message)
			XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })
		} catch {
			XCTFail("Expected errorCapture object to intercept the failing tests message")
		}
	}

	func testMockService_Fails_WithHeaderMismatch() {
		let expectedValues = [
			"Failed to verify Pact!",
			"Actual request does not match expected interactions...",
			"Request does not match",
			"header",
			"'testKey'"
		]

		_ = mockService
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .GET, path: "/user", headers: ["testKey": "test/value"])
			.willRespondWith(
				status: 200
			)

		mockService.run { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/user")!) { data, response, error in
				completion()
			}
			task.resume()
		}

		do {
			let testResult = try XCTUnwrap(errorCapture.error?.message)
			XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })
		} catch {
			XCTFail("Expected errorCapture object to intercept the failing tests message")
		}
	}

	// MARK: - Using matchers

	func testMockService_Succeeds_WithMatchers() {
		_ = mockService
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .GET, path: "/user")
			.willRespondWith(
				status: 200,
				body: [
					"foo": SomethingLike("bar"),
					"baz": EachLike(123, min: 1, max: 5)
				]
			)

		mockService.run { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/user")!) { data, response, error in
				if let data = data {
					let testResult = self.decodeResponse(data: data)
					XCTAssertEqual(testResult?.foo, "bar")
					XCTAssertEqual(testResult?.baz?.first, 123)
				}
				completion()
			}
			task.resume()
		}
	}

	// MARK: - Write pact contract

	func testMockService_Writes_PactContract() {
		_ = mockService
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .GET, path: "/user")
			.willRespondWith(
				status: 200,
				body: [
					"foo": SomethingLike("bar"),
					"baz": EachLike(123, min: 1, max: 5)
				]
			)

		mockService.run { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/user")!) { data, response, error in
				if let data = data {
					let testResult = self.decodeResponse(data: data)
					XCTAssertEqual(testResult?.foo, "bar")
					XCTAssertEqual(testResult?.baz?.first, 123)
				}
				completion()
			}
			task.resume()
		}
	}

}

private extension MockServiceTests {

	struct TestModel: Decodable {
		let foo: String
		let baz: [Int]?
	}

	func decodeResponse(data: Data) -> TestModel? {
		try? JSONDecoder().decode(TestModel.self, from: data)
	}

}
