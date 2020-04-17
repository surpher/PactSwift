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

	func testMockService_SuccessfulGETRequest() {
		let mockService = MockService(consumer: "consumer-app", provider: "api-provider")

		// Prepare the API interaction expectations:
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

		// Run my API Client code and test:
		// - that my request matches the above defined expectations in `withRequest`,
		// - and test that my request code handles the response correctly
		//   (mockService will respond with what I defined in the `.willRespondWith`, given the request matches)
		//
		mockService.run { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(mockService.baseUrl)/users")!) { data, response, error in
				if let data = data {
					let testResult = self.decodeResponse(data: data)
					XCTAssertEqual(testResult?.foo, "bar")
				}
				completion()
			}
			task.resume()
		}
	}

	// ###################################################
	//
	// CRASHING TEST
	// GIVEN MockService.run {  also calls .verify() within it }
	//
	// ###################################################

//	func testMockService_FailingGETRequest_invalidPath() {
//		let mockService = MockService(consumer: "consumer-app", provider: "api-provider")
//
//		// Prepare the API interactino expectations:
//		_ = mockService
//			.uponReceiving("Request for alligators")
//			.given("alligators exist")
//			.withRequest(method: .GET, path: "/user")
//			.willRespondWith(
//				status: 200,
//				body: [
//					"foo": "bar"
//				]
//			)
//
//		// Run my API client code and test:
//		// - that this test fails but does not crash! because the request path doesn't match what I've defined it should be in `.withRequest`
//		// -
//		mockService.run { completion in
//			let session = URLSession.shared
//			let task = session.dataTask(with: URL(string: "\(mockService.baseUrl)/invalidPath")!) { data, response, error in
//				// TODO: - WIP
//				// MockService should throw error - { error: unexpected-request : { Request: { method: GET, path: /users... }}
//				// And fail this test even if caller is not doing test assertions!
//				completion()
//			}
//			task.resume()
//		}
//	}

	// NON-CRASHING TEST but using waitForExpectations and only then running verify :((((
	func testMockService_FailingGETRequest_invalidPath() {
		let mockService = MockService(consumer: "consumer-app", provider: "api-provider")

		// Prepare the API interactino expectations:
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

		// Run my API client code and test:
		// - that this test fails but does not crash! because the request path doesn't match what I've defined it should be in `.withRequest`
		// -
		let exp = expectation(description: "nonCrashingFailingTest")

		mockService.run { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(mockService.baseUrl)/invalidPath")!) { data, response, error in
				// TODO: - WIP
				// MockService should throw error - { error: unexpected-request : { Request: { method: GET, path: /users... }}
				// And fail this test even if caller is not doing test assertions!
				completion()
				exp.fulfill()
			}
			task.resume()
		}

		waitForExpectations(timeout: 30) { _ in
			mockService.verify { _ in }
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
