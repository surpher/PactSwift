//
//  Created by Marko Justinek on 15/4/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
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
@_implementationOnly import PactSwiftToolbox

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
					completion()
					testExpectation.fulfill()
				} else {
					XCTFail("Expecting response code 200 in \(#function)")
				}
			}
			task.resume()
		}
		waitForExpectations(timeout: 1)
	}

	func testMockService_SimpleGetRequest_WithExplicitPort() {
		mockService = MockService(consumer: "Explicit-Port-Consumer", provider: "Explicit-Port-Provider", scheme: .standard, port: 12345, errorReporter: errorCapture)
		mockService
			.uponReceiving("Request for a list (explicit port)")
			.given("elements exist (explicit port)")
			.withRequest(method: .GET, path: "/elements/on-port")
			.willRespondWith(status: 200)

		let testExpectation = expectation(description: #function)

		mockService.run(waitFor: 1) { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "http://0.0.0.0:12345/elements/on-port")!) { data, response, error in
				if let response = response as? HTTPURLResponse {
					XCTAssertEqual(200, response.statusCode)
					completion()
					testExpectation.fulfill()
				} else {
					XCTFail("Expecting response code 200 in \(#function)")
				}
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
					do {
						let testResult: TestModel = try XCTUnwrap(self.decodeResponse(data: data))
						XCTAssertEqual(testResult.foo, "bar")
						completion()
						testExpectation.fulfill()
					} catch {
						XCTFail("Expected TestModel in \(#function)")
					}
				} else {
					XCTFail("Expecting a decodable response data in \(#function)")
				}
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
					do {
						let testResult: TestModel  = try XCTUnwrap(self.decodeResponse(data: data))
						XCTAssertEqual(testResult.foo, "bar")
						completion()
						testExpectation.fulfill()
					} catch {
						XCTFail("Expecting a TestModel in \(#function)")
					}
				}
				if let error = error {
					XCTFail(error.localizedDescription)
				}
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
			XCTFail("Expecting an errorCapture object to intercept the failing tests message in \(#function)")
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
			.withRequest(method: .GET, path: "/user", query: ["state": [Matcher.EqualTo("NSW")], "page": ["2"]])
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

	func testMockService_Succeeds_ForGetWithMatcherInRequestPath() {
		mockService
			.uponReceiving("Request for a list of foo")
			.given("foos exist")
			.withRequest(
				method: .GET,
				path: Matcher.RegexLike("/hello/dear/world", term: #"^/\w+/([a-z])+/world$"#)
			)
			.willRespondWith(status: 200)

		let testExpectation = expectation(description: #function)

		mockService.run { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/hello/cruel/world")!) { data, response, error in
				if let response = response as? HTTPURLResponse {
					XCTAssertEqual(response.statusCode, 200)
				}
				testExpectation.fulfill()
				completion()
			}
			task.resume()
		}

		waitForExpectations(timeout: 1)
	}

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
				headers: ["Content-Type": Matcher.EqualTo("application/json")],
				body: [
					"name": Matcher.SomethingLike("Joe"),
					"age": Matcher.SomethingLike(42)
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

	func testMockService_Succeeds_WithMatchersInEachLike() {
		mockService
			.uponReceiving("Request to get a user with options")
			.given("user with options exists")
			.withRequest(
				method: .GET,
				path: "/user/options"
			)
			.willRespondWith(
				status: 200,
				body: [
					"options": Matcher.EachLike(
						Matcher.SomethingLike("option_one"),
						min: 3
					)
				]
			)

		let testExpectation = expectation(description: #function)

		mockService.run { completion in
			let requestURL = URL(string: "\(self.mockService.baseUrl)/user/options")!
			let session = URLSession.shared

			let task = session.dataTask(with: URLRequest(url: requestURL)) { data, response, error in
				if let data = data {
					do {
						let testResult: EmbeddedMatcherTestModel = try XCTUnwrap(self.decodeResponse(data: data))

						XCTAssertEqual(testResult.options.count, 3)
						XCTAssertTrue(testResult.options.contains("option_one"))
					} catch {
						XCTFail("Expecting an EmbeddedMatcherTestModel object in \(#function)")
					}
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
						let testResult: TestModel = try XCTUnwrap(self.decodeResponse(data: data))
						XCTAssertEqual(testResult.foo, "bar")
						XCTAssertEqual(testResult.baz?.first, 123)
						XCTAssertNil(testResult.nullable_key)

						let responseData = try XCTUnwrap(String(data: data, encoding: .utf8))
						XCTAssertTrue(responseData.contains("nullable_key"))
					} catch {
						XCTFail("Expecting a nullable_key key with null value for Match.MatchNull() in \(#function)")
					}
				}
				testExpectation.fulfill()
				completion()
			}
			task.resume()
		}

		waitForExpectations(timeout: 1)
	}

	func testMockService_Succeeds_WithMatcherInHeaders() throws {
		mockService
			.uponReceiving("Request for list of movies")
			.withRequest(
				method: .GET,
				path: "/movies",
				query: nil,
				headers: ["Authorization": Matcher.RegexLike("Bearer abcd12345", term: #"^Bearer \w+$"#)],
				body: nil
			)
			.willRespondWith(status: 200, body: [
				"foo": "bar",
				"baz": Matcher.EachLike(1)
			])

		let testExpectation = expectation(description: #function)

		mockService.run { completion in
			let requestURL = URL(string: "\(self.mockService.baseUrl)/movies")!
			var request = URLRequest(url: requestURL)
			let session = URLSession.shared

			request.setValue("Bearer bdjksl1234352", forHTTPHeaderField: "Authorization")

			let task = session.dataTask(with: request) { data, response, error in
				if let data = data {
					do {
						let testResult: TestModel = try XCTUnwrap(self.decodeResponse(data: data))
						XCTAssertEqual(testResult.foo, "bar")
					} catch {
						XCTFail("Expecting a valid response object when asking for a list of /movies in \(#function)")
					}
				}

				testExpectation.fulfill()
				completion()
			}
			task.resume()
		}

		waitForExpectations(timeout: 5)
	}

	func testMockService_Succeeds_WithMatchersInRequestQuery() throws {
		mockService
			.uponReceiving("Request for list of songs")
			.withRequest(
				method: .GET,
				path: "/songs",
				query: [
					"page": [Matcher.SomethingLike("5")],
					"size": [Matcher.SomethingLike("25")]
				]
			)
			.willRespondWith(status: 200, body: [
				"foo": "bar",
				"array_example": [
					Matcher.EachLike("one", min: 2, max: 10, count: 5),
					Matcher.EachLike(1, min: 1, max: 25),
				]
			])

		let testExpectation = expectation(description: #function)

		mockService.run { completion in
			let requestURL = URL(string: "\(self.mockService.baseUrl)/songs?page=&size=25")!
			var request = URLRequest(url: requestURL)
			let session = URLSession.shared

			request.setValue("Bearer bdjksl1234352", forHTTPHeaderField: "Authorization")

			let task = session.dataTask(with: request) { data, response, error in
				if let data = data {
					do {
						let testResult: TestModel = try XCTUnwrap(self.decodeResponse(data: data))
						XCTAssertEqual(testResult.foo, "bar")
					} catch {
						XCTFail("Expecting a valid response object when asking for a list of /movies in \(#function)")
					}
				}

				testExpectation.fulfill()
				completion()
			}
			task.resume()
		}

		waitForExpectations(timeout: 5)
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
					do {
						let testResult: GeneratorsTestModel = try XCTUnwrap(self.decodeResponse(data: data))

						// Verify Bool example generator
						XCTAssertTrue(((testResult.randomBool) as Any) is Bool)

						// Verify UUID example generator
						let uuidResult = try XCTUnwrap(testResult.randomUUID)
						if uuidResult.contains("-") {
							XCTAssertNotNil(UUID(uuidString: uuidResult))
						} else {
							XCTAssertNotNil(uuidResult.uuid)
						}

						// Verify RandomInt example generator
						let intResult = try XCTUnwrap(testResult.randomInt)
						XCTAssertTrue((-42...4242).contains(intResult))

						// Verify Decimal example generator
						let decimalResult = try XCTUnwrap(testResult.randomDecimal)
						XCTAssertTrue((decimalResult as Any) is Decimal)

						// TODO - Investigate why MockServer sometimes returns 1 digit less than defined in ExampleGenerator.Decimal(digits: X)
						// XCTAssertEqual(String(describing: decimalResult).count, 4, accuracy: 1)

						// Verify Hexadecimal value
						let hexValue = try XCTUnwrap(testResult.randomHex)
						XCTAssertEqual(hexValue.count, 14)

						// Verify Random String value
						let stringValue = try XCTUnwrap(testResult.randomString)
						XCTAssertEqual(stringValue.count, 38)

						// Verify Regex value
						let regexValue = try XCTUnwrap(testResult.randomRegex)
						let regex = try! NSRegularExpression(pattern: testRegex)
						let range = NSRange(location: 0, length: regexValue.utf16.count)
						XCTAssertNotNil(regex.firstMatch(in: regexValue, options: [], range: range))

						// Verify random date value
						let dateValue = try XCTUnwrap(testResult.randomDate)
						let dateRegex = try! NSRegularExpression(pattern: #"\d{4}/\d{2}"#)
						let dateRange = NSRange(location: 0, length: dateValue.utf16.count)
						XCTAssertNotNil(dateRegex.firstMatch(in: dateValue, options: [], range: dateRange))

						// Verify random time value
						let timeValue = try XCTUnwrap(testResult.randomTime)
						let timeRegex = try! NSRegularExpression(pattern: #"\d{2}:\d{2} - \d{2}"#)
						let timeRange = NSRange(location: 0, length: timeValue.utf16.count)
						XCTAssertNotNil(timeRegex.firstMatch(in: timeValue, options: [], range: timeRange))

						// Verify random date time value
						let dateTimeValue = try XCTUnwrap(testResult.randomDateTime)
						let dateTimeRegex = try! NSRegularExpression(pattern: #"\d{2}:\d{2} - \d{2}.\d{2}.\d{2}"#)
						let dateTimeRange = NSRange(location: 0, length: dateTimeValue.utf16.count)
						XCTAssertNotNil(dateTimeRegex.firstMatch(in: dateTimeValue, options: [], range: dateTimeRange))
					} catch {
						XCTFail("Expecting GeneratorsTestModel in \(#function)")
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

	func testMockService_Writes_PactContract() throws {
		let expectedFileName = "pactswift_unit_tests_write_file-with_api_provider.json"
		removeFile(expectedFileName)

		mockService = MockService(consumer: "pactswift_unit_tests_write_file", provider: "with_api_provider", errorReporter: errorCapture)

		mockService
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .GET, path: "/user")
			.willRespondWith(
				status: 200,
				body: [
					"foo": Matcher.SomethingLike("bar"),
					"baz": Matcher.EachLike(123, min: 1, max: 5, count: 3),
					"array": Matcher.EachLike(
						[
							Matcher.SomethingLike("array_value"),
							Matcher.RegexLike("2021-05-15", term: #"\d{4}-\d{2}-d{2}"#),
							ExampleGenerator.RandomUUID(),
							Matcher.EachLike(
								[
									"3rd_level_nested": Matcher.EachLike(Matcher.IntegerLike(369))
								]
							)
						]
					),
					"regex_array": Matcher.EachLike(
						[
							"regex_key": Matcher.EachLike(
								Matcher.RegexLike("1234", term: #"\d{4}"#),
								min: 2
							),
							"regex_nested_object": Matcher.EachLike(
								[
									"regex_nested_key": Matcher.RegexLike("12345678", term: #"\d{8}"#)
								]
							)
						]
					)
				]
			)

		let testExpectation = expectation(description: #function)

		mockService.run { completion in
			let session = URLSession.shared
			let task = session.dataTask(with: URL(string: "\(self.mockService.baseUrl)/user")!) { data, response, error in
				if let data = data {
					do {
						let testResult: TestModel = try XCTUnwrap(self.decodeResponse(data: data))
						XCTAssertEqual(testResult.foo, "bar")
						XCTAssertEqual(testResult.baz?.first, 123)
						XCTAssertEqual(testResult.baz?.count, 3)
						XCTAssertEqual(testResult.regex_array?.first?.regex_key.first, "1234")
						XCTAssertEqual(testResult.regex_array?.first?.regex_key.count, 2)
					} catch {
						XCTFail("Expecting a TestModel in \(#function)")
					}
				}

				completion()
			}
			task.resume()
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			XCTAssertTrue(self.fileExists(expectedFileName))
			testExpectation.fulfill()
		}

		waitForExpectations(timeout: 1)
	}

}

private extension MockServiceTests {

	func decodeResponse<D: Decodable>(data: Data) -> D? {
		try? JSONDecoder().decode(D.self, from: data)
	}

	struct TestModel: Decodable {
		struct TestRegex: Decodable {
			let regex_key: [String]
		}
		let foo: String
		let baz: [Int]?
		let nullable_key: String?
		let options: [String]?
		let regex_array: [TestRegex]?
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

	struct EmbeddedMatcherTestModel: Decodable {
		let options: [String]
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

	// FileManager

	@discardableResult
	func fileExists(_ filename: String) -> Bool {
		FileManager.default.fileExists(atPath: PactFileManager.pactDirectoryPath + "/\(filename)")
	}

	@discardableResult
	func removeFile(_ filename: String) -> Bool {
		if fileExists(filename) {
			do {
				try FileManager.default.removeItem(at: URL(fileURLWithPath: PactFileManager.pactDirectoryPath + "/\(filename)"))
				return true
			} catch {
				debugPrint("Could not remove file \(PactFileManager.pactDirectoryPath + "/\(filename)")")
				return false
			}
		}
		return false
	}

}
