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
		mockService = nil
		errorCapture = nil

		super.tearDown()
	}

	// MARK: - Tests

	func testMockService_SimpleGetRequest() {
		mockService
			.uponReceiving("Request for a list")
			.given("elements exist")
			.withRequest(method: .GET, path: "/elements")
			.willRespondWith(status: 200)

		let testExpectation = expectation(description: #function)

		mockService.run(waitFor: 1) { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/elements")!) { data, response, error in
				if let response = response as? HTTPURLResponse {
					XCTAssertEqual(200, response.statusCode)
				}
				completion()
				testExpectation.fulfill()
			}
			task.resume()
		}
		waitForExpectations(timeout: 1)
	}

	func testMockService_SuccessfulGETRequest() {
		mockService
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .GET, path: "/user")
			.willRespondWith(
				status: 200,
				body: [
					"foo": "bar"
				]
			)

		let testExpectation = expectation(description: #function)

		mockService.run(waitFor: 1) { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/user")!) { data, response, error in
				if let data = data {
					let testResult = self.decodeResponse(data: data)
					XCTAssertEqual(testResult?.foo, "bar")
				}
				completion()
				testExpectation.fulfill()
			}
			task.resume()
		}

		waitForExpectations(timeout: 1)
	}

	func testMockService_SuccessfulGETRequest_OverSSL() {
		mockService = MockService(
			consumer: "pactswift-unit-tests",
			provider: "unit-test-api-provider",
			scheme: .secure,
			errorReporter: errorCapture
		)

		mockService
			.uponReceiving("Request for list of users over SSL connection")
			.given("users exist")
			.withRequest(method: .GET, path: "/user")
			.willRespondWith(
				status: 200,
				body: [
					"foo": "bar"
				]
			)

		let testExpectation = expectation(description: #function)

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
				testExpectation.fulfill()
			}
			task.resume()
		}

		waitForExpectations(timeout: 1)
	}

	func testMockService_Fails_WhenRequestMissing() {
		mockService
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

		mockService
			.uponReceiving("Request for alligators")
			.given("alligators exist")
			.withRequest(method: .GET, path: "/user")
			.willRespondWith(
				status: 200,
				body: [
					"foo": "bar"
				]
			)

		let testExpectation = expectation(description: #function)

		mockService.run { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/invalidPath")!) { data, response, error in
				completion()
				testExpectation.fulfill()
			}
			task.resume()
		}

		let testResult = try XCTUnwrap(errorCapture.error?.message)
		XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })

		waitForExpectations(timeout: 1)
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

		mockService
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .GET, path: "/user", query: ["state": ["NSW"], "page": ["2"]])
			.willRespondWith(
				status: 200
			)

		let testExpectation = expectation(description: #function)

		mockService.run { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/user?state=VIC")!) { data, response, error in
				completion()
				testExpectation.fulfill()
			}
			task.resume()
		}

		let testResult = try XCTUnwrap(errorCapture.error?.message)
		XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })

		waitForExpectations(timeout: 1)
	}

	func testMockService_Fails_WhenBodyMismatch() throws {
		let expectedValues = [
			"Failed to verify Pact!",
			"Actual request does not match expected interactions...",
			"Request does not match",
			"Body does not match the expected body definition"
		]

		mockService
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .POST, path: "/user", body: ["foo": "bar"])
			.willRespondWith(
				status: 201
			)

		let testExpectation = expectation(description: #function)

		mockService.run { completion in
			let requestURL = URL(string: "\(self.mockService.baseUrl)/user")!
			let session = URLSession.shared
			var request = URLRequest(url: requestURL)

			request.httpMethod = "POST"
			request.httpBody = "{\"foo\":\"baz\"}".data(using: .utf8)!

			let task = session.dataTask(with: request) { data, response, error in
				completion()
				testExpectation.fulfill()
			}
			task.resume()
		}

		let testResult = try XCTUnwrap(errorCapture.error?.message)
		XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })

		waitForExpectations(timeout: 1)
	}

	func testMockService_Fails_WhenBodyIsEmptyObject() throws {
		let expectedValues = [
			"Failed to verify Pact!",
			"Actual request does not match expected interactions...",
			"Request does not match",
			"Body does not match the expected body definition"
		]

		mockService
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .POST, path: "/user", body: ["foo": "bar"])
			.willRespondWith(
				status: 201
			)

		let testExpectation = expectation(description: #function)

		mockService.run { completion in
			let requestURL = URL(string: "\(self.mockService.baseUrl)/user")!
			let session = URLSession.shared
			var request = URLRequest(url: requestURL)

			request.httpMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = "{\n\n}".data(using: .utf8)!

			let task = session.dataTask(with: request) { data, response, error in
				completion()
				testExpectation.fulfill()
			}
			task.resume()
		}

		let testResult = try XCTUnwrap(errorCapture.error?.message)
		XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })

		waitForExpectations(timeout: 1)
	}

	func testMockService_Fails_WhenRequestBodyMissing() throws {
		let expectedValues = [
			"Failed to verify Pact!",
			"Actual request does not match expected interactions...",
			"Request does not match",
			"Body does not match the expected body definition"
		]

		mockService
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .POST, path: "/user", body: ["foo": "bar"])
			.willRespondWith(
				status: 201
			)

		let testExpectation = expectation(description: #function)

		mockService.run { completion in
			let requestURL = URL(string: "\(self.mockService.baseUrl)/user")!
			let session = URLSession.shared
			var request = URLRequest(url: requestURL)
			request.httpMethod = "POST"
			let task = session.dataTask(with: request) { data, response, error in
				completion()
				testExpectation.fulfill()
			}
			task.resume()
		}

		let testResult = try XCTUnwrap(errorCapture.error?.message)
		XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })

		waitForExpectations(timeout: 1)
	}

	func testMockService_Fails_WithHeaderMismatch() throws {
		let expectedValues = [
			"Failed to verify Pact!",
			"Actual request does not match expected interactions...",
			"Request does not match",
			"header",
			"'testKey'"
		]

		mockService
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .GET, path: "/user", headers: ["testKey": "test/value"])
			.willRespondWith(
				status: 200
			)

		let testExpectation = expectation(description: #function)

		mockService.run { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/user")!) { data, response, error in
				testExpectation.fulfill()
				completion()
			}
			task.resume()
		}

		let testResult = try XCTUnwrap(errorCapture.error?.message)
		XCTAssertTrue(expectedValues.allSatisfy { testResult.contains($0) })
		waitForExpectations(timeout: 1)
	}

	// MARK: - Using matchers

	func testMockService_Succeeds_ForPOSTRequestWithMatchersInRequestBody() {
		mockService
			.uponReceiving("Request to create a new user")
			.given("user does not exist")
			.withRequest(
				method: .POST,
				path: "/user/add",
				query: nil,
				headers: ["Content-Type": "application/json"],
				body: [
					"name": Matcher.SomethingLike("Joe"),
					"age": Matcher.IntegerLike(42)
				]
			)
			.willRespondWith(
				status: 201
			)

		let testExpectation = expectation(description: #function)

		mockService.run { completion in
			let requestURL = URL(string: "\(self.mockService.baseUrl)/user/add")!
			let session = URLSession.shared
			var request = URLRequest(url: requestURL)

			request.httpMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = #"{"name":"Joseph","age":24}"#.data(using: .utf8)

			let task = session.dataTask(with: request) { data, response, error in
				if let response = response as? HTTPURLResponse {
					XCTAssertEqual(response.statusCode, 201)
				}
				testExpectation.fulfill()
				completion()
			}
			task.resume()
		}

		waitForExpectations(timeout: 1)
	}

	func testMockService_Succeeds_WithMatchersInRequestBody() {
		mockService
			.uponReceiving("Request to update a user")
			.given("user exists")
			.withRequest(
				method: .PUT,
				path: "/user/update",
				headers: ["Content-Type": "application/json"],
				body: [
					"name": Matcher.SomethingLike("Joe"),
					"age": Matcher.IntegerLike(42)
				]
			)
			.willRespondWith(
				status: 201
			)

		let testExpectation = expectation(description: #function)

		mockService.run { completion in
			let requestURL = URL(string: "\(self.mockService.baseUrl)/user/update")!
			let session = URLSession.shared
			var request = URLRequest(url: requestURL)

			request.httpMethod = "PUT"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = #"{"name":"Joe","age":42}"#.data(using: .utf8)

			let task = session.dataTask(with: request) { data, response, error in 
				if let response = response as? HTTPURLResponse {
					XCTAssertEqual(response.statusCode, 201)
				}
				testExpectation.fulfill()
				completion()
			}
			task.resume()
		}

		waitForExpectations(timeout: 1)
	}

	func testMockService_Succeeds_WithMatchers() {
		mockService
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .GET, path: "/user")
			.willRespondWith(
				status: 200,
				body: [
					"foo": Matcher.SomethingLike("bar"),
					"baz": Matcher.EachLike(123, min: 1, max: 5),
					"nullable_key": Matcher.MatchNull(),
				]
			)

		let testExpectation = expectation(description: #function)

		mockService.run { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/user")!) { data, response, error in
				if let data = data {
					do {
						let testResult = try XCTUnwrap(self.decodeResponse(data: data))
						XCTAssertEqual(testResult.foo, "bar")
						XCTAssertEqual(testResult.baz?.first, 123)
						XCTAssertNil(testResult.nullable_key)

						let responseData = try XCTUnwrap(String(data: data, encoding: .utf8))
						XCTAssertTrue(responseData.contains("nullable_key"))
					} catch {
						XCTFail("Expected a nullable_key key with null value for Match.MatchNull()")
					}
				}
				testExpectation.fulfill()
				completion()
			}
			task.resume()
		}

		waitForExpectations(timeout: 1)
	}

	// MARK: - Using Example Generators

	func testMockService_Succeeds_WithGenerators() {
		let testRegex = #"\d{3}/\d{4,8}"#

		mockService
			.uponReceiving("Request for list of pets")
			.given("animals exist")
			.withRequest(method: .GET, path: "/pet")
			.willRespondWith(
				status: 200,
				body: [
					"randomBool": ExampleGenerator.RandomBool(),
					"randomUUID": ExampleGenerator.RandomUUID(),
					"randomInt": ExampleGenerator.RandomInt(min: -42, max: 4242),
					"randomDecimal": ExampleGenerator.RandomDecimal(digits: 4),
					"randomHex": ExampleGenerator.RandomHexadecimal(digits: 14),
					"randomString": ExampleGenerator.RandomString(size: 38),
					"randomRegex": ExampleGenerator.RandomString(regex: testRegex),
					"randomDate": ExampleGenerator.RandomDate(format: "yyyy/MM"),
					"randomTime": ExampleGenerator.RandomTime(format: "HH:mm - ss"),
					"randomDateTime": ExampleGenerator.RandomDateTime(format: "HH:mm - dd.MM.yy"),
				]
			)

		let testExpectation = expectation(description: #function)

		mockService.run { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/pet")!) { data, response, error in
				if let data = data {
					let testResult = self.decodeGeneratorsResponse(data: data)

					// Verify Bool example generator
					XCTAssertTrue(((testResult?.randomBool) as Any) is Bool)
					do {
						// Verify UUID example generator
						let uuidResult = try XCTUnwrap(testResult?.randomUUID)
						if uuidResult.contains("-") {
							XCTAssertNotNil(UUID(uuidString: uuidResult))
						} else {
							XCTAssertNotNil(uuidResult.uuid)
						}

						// Verify RandomInt example generator
						let intResult = try XCTUnwrap(testResult?.randomInt)
						XCTAssertTrue((-42...4242).contains(intResult))

						// Verify Decimal example generator
						let decimalResult = try XCTUnwrap(testResult?.randomDecimal)
						XCTAssertTrue((decimalResult as Any) is Decimal)

						// TODO - Investigate why MockServer sometimes returns 1 digit less than defined in ExampleGenerator.Decimal(digits: X)
						// XCTAssertEqual(String(describing: decimalResult).count, 4, accuracy: 1)

						// Verify Hexadecimal value
						let hexValue = try XCTUnwrap(testResult?.randomHex)
						XCTAssertEqual(hexValue.count, 14)

						// Verify Random String value
						let stringValue = try XCTUnwrap(testResult?.randomString)
						XCTAssertEqual(stringValue.count, 38)

						// Verify Regex value
						let regexValue = try XCTUnwrap(testResult?.randomRegex)
						let regex = try! NSRegularExpression(pattern: testRegex)
						let range = NSRange(location: 0, length: regexValue.utf16.count)
						XCTAssertNotNil(regex.firstMatch(in: regexValue, options: [], range: range))

						// Verify random date value
						let dateValue = try XCTUnwrap(testResult?.randomDate)
						let dateRegex = try! NSRegularExpression(pattern: #"\d{4}/\d{2}"#)
						let dateRange = NSRange(location: 0, length: dateValue.utf16.count)
						XCTAssertNotNil(dateRegex.firstMatch(in: dateValue, options: [], range: dateRange))

						// Verify random time value
						let timeValue = try XCTUnwrap(testResult?.randomTime)
						let timeRegex = try! NSRegularExpression(pattern: #"\d{2}:\d{2} - \d{2}"#)
						let timeRange = NSRange(location: 0, length: timeValue.utf16.count)
						XCTAssertNotNil(timeRegex.firstMatch(in: timeValue, options: [], range: timeRange))

						// Verify random date time value
						let dateTimeValue = try XCTUnwrap(testResult?.randomDateTime)
						let dateTimeRegex = try! NSRegularExpression(pattern: #"\d{2}:\d{2} - \d{2}.\d{2}.\d{2}"#)
						let dateTimeRange = NSRange(location: 0, length: dateTimeValue.utf16.count)
						XCTAssertNotNil(dateTimeRegex.firstMatch(in: dateTimeValue, options: [], range: dateTimeRange))
					} catch {
						XCTFail("Failed to successfully decode test model with example generators and extract all expected values")
					}
				}
				testExpectation.fulfill()
				completion()
			}
			task.resume()
		}

		waitForExpectations(timeout: 1)
	}

	// MARK: - Write pact contract

	func testMockService_Writes_PactContract() {
		mockService
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

		let testExpectation = expectation(description: #function)

		mockService.run { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/user")!) { data, response, error in
				if let data = data {
					let testResult = self.decodeResponse(data: data)
					XCTAssertEqual(testResult?.foo, "bar")
					XCTAssertEqual(testResult?.baz?.first, 123)
				}
				completion()
				testExpectation.fulfill()
			}
			task.resume()
		}

		waitForExpectations(timeout: 1)
	}

}

private extension MockServiceTests {

	struct TestModel: Decodable {
		let foo: String
		let baz: [Int]?
		let nullable_key: String?
	}

	func decodeResponse(data: Data) -> TestModel? {
		try? JSONDecoder().decode(TestModel.self, from: data)
	}

	struct GeneratorsTestModel: Decodable {
		let randomBool: Bool
		let randomInt: Int
		let randomHex: String
		let randomDecimal: Decimal
		let randomUUID: String
		let randomString: String
		let randomRegex: String
		let randomDate: String
		let randomTime: String
		let randomDateTime: String
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
