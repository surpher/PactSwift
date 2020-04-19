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
			.withRequest(method: .GET, path: "/users")
			.willRespondWith(
				status: 200,
				body: [
					"foo": "bar"
				]
			)

		mockService.run { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/users")!) { data, response, error in
				if let data = data {
					let testResult = self.decodeResponse(data: data)
					XCTAssertEqual(testResult?.foo, "bar")
				}
				completion()
			}
			task.resume()
		}
	}

	func testMockService_Failing_WhenNoRequestReceived() {
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

		mockService.run { $0() }

		do {
			let testResult = try XCTUnwrap(errorCapture.error?.message)
			XCTAssertTrue(testResult.contains("missing-request"))
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
		do {
			let result = try JSONDecoder().decode(TestModel.self, from: data)
			return result
		} catch {
			debugPrint("ERROR")
		}
		return nil
	}

}
