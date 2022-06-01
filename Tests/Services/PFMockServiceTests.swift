//
//  Created by Marko Justinek on 31/7/21.
//  Copyright © 2021 Marko Justinek. All rights reserved.
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

#if !os(Linux)

import XCTest

@testable import PactSwift
@_implementationOnly import PactSwiftToolbox

class PFMockServiceTests: XCTestCase {

	var testSubject: PFMockService!
	var errorCapture: ErrorCapture!

	override func setUpWithError() throws {
		try super.setUpWithError()

		errorCapture = ErrorCapture()
		testSubject = PFMockService(consumer: "pfpactswift-consumer", provider: "pfpactswift-provider", scheme: .standard)
	}

	override func tearDownWithError() throws {
		errorCapture = nil
		testSubject = nil

		try super.tearDownWithError()
	}

	// MARK: - Tests
	func testSimpleGETRequest() {
		testSubject
			.uponReceiving("Request for a list")
			.given("elements exist")
			.withRequest(method: .GET, path: "/elements")
			.willRespondWith(status: 200)

		let testExpectation = expectation(description: #function)

		testSubject.objCRun { baseURL, done in
			let session = URLSession.shared

			session.dataTask(with: URL(string: "\(baseURL)/elements")!) { data, response, error in
				if let response = response as? HTTPURLResponse {
					XCTAssertEqual(200, response.statusCode)
					done()
					testExpectation.fulfill()
				} else {
					XCTFail("Expecting response code 200 in \(#function)")
				}
			}
			.resume()
		}

		waitForExpectations(timeout: 1)
	}

	func testSimplePOSTRequestWithTimeout() {
		testSubject
			.uponReceiving("Request for a list")
			.given("elements exist")
			.withRequest(method: .POST, path: "/elements", body: ["name": Matcher.SomethingLike("John")])
			.willRespondWith(status: 201)

		let testExpectation = expectation(description: #function)

		testSubject.objCRun(
			testFunction: { baseURL, done in
				let session = URLSession.shared
				var request = URLRequest(url: URL(string: "\(baseURL)/elements")!)
				request.httpBody = Data("{\"name\":\"George\"}".utf8)
				request.setValue("application/json", forHTTPHeaderField: "Content-Type")
				request.httpMethod = "POST"

				session
					.dataTask(with: request) { data, response, error in
						if let response = response as? HTTPURLResponse {
							XCTAssertEqual(201, response.statusCode)
							done()
							testExpectation.fulfill()
						} else {
							XCTFail("Expecting response code 200 in \(#function)")
						}
					}
					.resume()
			},
			timeout: 2
		)
		waitForExpectations(timeout: 5)
	}

	func testTwoRequestsInOneTest() {
		let firstExpectation = expectation(description: "first")
		let firstInteraction = testSubject
			.uponReceiving("Request for a list")
			.given("elements exist")
			.withRequest(method: .POST, path: "/first", body: ["name": Matcher.SomethingLike("John")])
			.willRespondWith(status: 201)

		let secondExpectation = expectation(description: "second")
		let secondInteraction = testSubject
			.uponReceiving("Request for a list")
			.given("elements exist")
			.withRequest(method: .GET, path: "/second")
			.willRespondWith(status: 200)

		testSubject.objCRun(
			testFunction: { [unowned self] url, done in
				let session = URLSession.shared
				var request = URLRequest(url: URL(string: "\(url)/first")!)
				request.httpBody = Data("{\"name\":\"George\"}".utf8)
				request.setValue("application/json", forHTTPHeaderField: "Content-Type")
				request.httpMethod = "POST"

				session
					.dataTask(with: request) { data, response, error in
						if let response = response as? HTTPURLResponse {
							XCTAssertEqual(201, response.statusCode)
							firstExpectation.fulfill()
						} else {
							XCTFail("Expecting response code 200 in \(#function)")
						}
					}
					.resume()

				let secondRequest = URLRequest(url: URL(string: "\(url)/second")!)
				session
					.dataTask(with: secondRequest) { data, response, error in
						if let response = response as? HTTPURLResponse {
							XCTAssertEqual(200, response.statusCode)
							secondExpectation.fulfill()
						} else {
							XCTFail("Expecting response code 200 in \(#function)")
						}
					}
					.resume()

				self.waitForExpectations(timeout: 10) { _ in done() }
			},
			verify: [firstInteraction, secondInteraction],
			timeout: 10
		)
	}

}

#endif
