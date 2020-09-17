//
//  MockServiceTests.swift
//  PactSwiftTests
//
//  Created by Marko Justinek on 15/4/20.
//  Copyright © 2020 Itty Bitty Apps Pty Ltd / PACT Foundation. All rights reserved.
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

	private var secureProtocol: Bool = false

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

		mockService.run(waitFor: 1) { completion in
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

	func testMockService_SuccessfulGETRequest_OverSSL() {
		mockService = MockService(
			consumer: "pactswift-unit-tests",
			provider: "unit-test-api-provider",
			scheme: .secure,
			errorReporter: errorCapture
		)

		_ = mockService
			.uponReceiving("Request for list of users over SSL connection")
			.given("users exist")
			.withRequest(method: .GET, path: "/user")
			.willRespondWith(
				status: 200,
				body: [
					"foo": "bar"
				]
			)

		mockService.run { completion in
			self.secureProtocol = true
			let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main)
			XCTAssertTrue(self.mockService.baseUrl.contains("https://"))
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/user")!) { data, response, error in
				if let data = data {
					let testResult = self.decodeResponse(data: data)
					XCTAssertEqual(testResult?.foo, "bar")
				}
				if let error = error {
					XCTFail(error.localizedDescription)
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

	func testMockService_Fails_WhenRequestPathInvalid() throws {
		let expectedValues = [
			"Failed to verify Pact!",
			"Actual request does not match expected interactions...",
			"Missing request",
			"Expected",
			"GET /user",
			"Actual",
			"GET /invalidPath"
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

		let testResult = try XCTUnwrap(errorCapture.error?.message)
		XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })
	}

	func testMockService_Fails_WhenUnexpectedQuery() throws {
		let expectedValues = [
			"Failed to verify Pact!",
			"Actual request does not match expected interactions...",
			"Request does not match",
			"Request",
			"GET /user",
			"state", "NSW",
			"Actual",
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

		let testResult = try XCTUnwrap(errorCapture.error?.message)
		XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })
	}

	func testMockService_Fails_WhenBodyMismatch() throws {
		let expectedValues = [
			"Failed to verify Pact!",
			"Actual request does not match expected interactions...",
			"Request does not match",
			"Body does not match the expected body definition"
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

		let testResult = try XCTUnwrap(errorCapture.error?.message)
		XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })
	}

	func testMockService_Fails_WhenBodyIsEmptyObject() throws {
		let expectedValues = [
			"Failed to verify Pact!",
			"Actual request does not match expected interactions...",
			"Request does not match",
			"Body does not match the expected body definition"
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

		let testResult = try XCTUnwrap(errorCapture.error?.message)
		XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })
	}

	func testMockService_Fails_WhenRequestBodyMissing() throws {
		let expectedValues = [
			"Failed to verify Pact!",
			"Actual request does not match expected interactions...",
			"Request does not match",
			"Body does not match the expected body definition"
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

		let testResult = try XCTUnwrap(errorCapture.error?.message)
		XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })
	}

	func testMockService_Fails_WithHeaderMismatch() throws {
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

		let testResult = try XCTUnwrap(errorCapture.error?.message)
		XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })
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
					"foo": Matcher.SomethingLike("bar"),
					"baz": Matcher.EachLike(123, min: 1, max: 5)
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

	// MARK: - Using Example Generators

	func testMockService_Succeeds_WithGenerators() {
			_ = mockService
				.uponReceiving("Request for list of pets")
				.given("animals exist")
				.withRequest(method: .GET, path: "/pet")
				.willRespondWith(
					status: 200,
					body: [
						"foo": Matcher.SomethingLike("bar"),
						"bar": ExampleGenerator.Boolean(),
						"uuid": ExampleGenerator.Uuid(),
						"baz": ExampleGenerator.RandomInt(min: -42, max: 4242),
						"quux": ExampleGenerator.Decimal(digits: 4),
						"hex": ExampleGenerator.Hexadecimal(digits: 14),
						"randoStr": ExampleGenerator.RandomString(size: 38)
					]
				)

			mockService.run { completion in
				let session = URLSession.shared
				let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/pet")!) { data, response, error in
					if let data = data {
						let testResult = self.decodeGeneratorsResponse(data: data)

						// Verify Bool example generator
						XCTAssertTrue(((testResult?.bar) as Any) is Bool)
						do {
							// Verify UUID example generator
							let uuidResult = try XCTUnwrap(testResult?.uuid)
							if uuidResult.contains("-") {
								XCTAssertNotNil(UUID(uuidString: uuidResult))
							} else {
								XCTAssertNotNil(uuidResult.uuid)
							}

							// Verify RandomInt example generator
							let intResult = try XCTUnwrap(testResult?.baz)
							XCTAssertTrue((-42...4242).contains(intResult))

							// Verify Decimal example generator
							let decimalResult = try XCTUnwrap(testResult?.quux)
							XCTAssertTrue((decimalResult as Any) is Decimal)

							// TODO - Investigate why MockServer sometimes returns 1 digit less than defined in ExampleGenerator.Decimal(digits: X)
							XCTAssertEqual(String(describing: decimalResult).count, 4, accuracy: 1)

							// Verify Hexadecimal value
							let hexValue = try XCTUnwrap(testResult?.hex)
							XCTAssertEqual(hexValue.count, 14)

							// Verify Random String value
							let randomString = try XCTUnwrap(testResult?.randoStr)
							XCTAssertEqual(randomString.count, 38)
						} catch {
							XCTFail("Failed to successfully decode test model with example generators and extract all expected values")
						}
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
					"foo": Matcher.SomethingLike("bar"),
					"baz": Matcher.EachLike(123, min: 1, max: 5)
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

	struct GeneratorsTestModel: Decodable {
		let foo: String
		let bar: Bool
		let baz: Int
		let hex: String
		let qux: Double?
		let quux: Decimal
		let uuid: String
		let randoStr: String
	}

	func decodeGeneratorsResponse(data: Data) -> GeneratorsTestModel? {
		try? JSONDecoder().decode(GeneratorsTestModel.self, from: data)
	}

}

extension MockServiceTests: URLSessionDelegate {

	func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		guard
			secureProtocol,
			challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
			(challenge.protectionSpace.host.contains("0.0.0.0") || challenge.protectionSpace.host.contains("localhost")),
			let serverTrust = challenge.protectionSpace.serverTrust
		else {
			completionHandler(.performDefaultHandling, nil)
			return
		}

		let credential = URLCredential(trust: serverTrust)
		completionHandler(.useCredential, credential)
	}

}
