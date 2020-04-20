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
		mockService = MockService(consumer: "pactswift-unit-tests", provider: "api-provider", errorReporter: errorCapture)
	}

	override func tearDown() {
		mockService = nil
		errorCapture = nil

		super.tearDown()
	}

	// MARK: - Tests

	func testMockService_SuccessfulGETRequest() {
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

	func testMockService_Failing_WhenRequestMissing() {
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

	func testMockService_Failing_WhenRequestUnexpected() {
		let expectedValues = [
			"Failed to verify Pact:",
			"Pact verification error! Actual request does not match expected interactions...",
			"Unexpected request",
			"Expected",
			"/user",
			"Actual",
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

}

private extension MockServiceTests {

	struct TestModel: Decodable {
		let foo: String
	}

	func decodeResponse(data: Data) -> TestModel? {
		try? JSONDecoder().decode(TestModel.self, from: data)
	}

}
