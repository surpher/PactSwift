//
//  Created by Marko Justinek on 15/5/21.
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

#if os(Linux)
import FoundationNetworking
#endif

private class MockServiceWrapper {
	static let shared = MockServiceWrapper()

	let errorCapture = ErrorCapture()
	let consumer = "sanity-consumer"
	let provider = "sanity-provider"

	var mockService: MockService

	init() {
		mockService = MockService(consumer: consumer, provider: provider, errorReporter: errorCapture)
	}

}

class PactContractTests: XCTestCase {

	var mockService = MockServiceWrapper.shared.mockService

	#if os(Linux)
	let session = URLSession.shared
	#else
	let session = URLSession(configuration: .ephemeral)
	#endif

	static var errorCapture = MockServiceWrapper.shared.errorCapture
	static let pactContractFileName = "\(MockServiceWrapper.shared.consumer)-\(MockServiceWrapper.shared.provider).json"

	// MARK: - Validate Pact contract at the end

	override class func setUp() {
		super.setUp()

		// Remove any previously generated Pact contracts for this test case
		PactContractTests.removeFile(pactContractFileName)
	}

	override class func tearDown() {
			do {
				let fileContents = try XCTUnwrap(FileManager.default.contents(atPath: PactFileManager.pactDirectoryPath + "/" + self.pactContractFileName))
				let jsonObject = try JSONSerialization.jsonObject(with: fileContents, options: []) as! [String: Any]

				// Validate the final Pact contract file contains values that were specified in tests' expectations

				// MARK: - Validate Interactions

				let interactions = try XCTUnwrap(jsonObject["interactions"] as? [Any])
				let numOfExpectedInteractions = 9

				assert(
					interactions.count == numOfExpectedInteractions,
					"Expected \(numOfExpectedInteractions) interactions in Pact contract but got \(interactions.count)!"
				)

				// MARK: - Validate Matchers for Interactions

				// Validate interaction "bug example"
				let bugExampleInteraction = try PactContractTests.extract(.matchingRules, in: .response, interactions: interactions, description: "bug example")
				// print("\nMATCHERS:\n\(matchersOne)")
				let expectedMatchersOne = [
					"$.array_of_objects",
					"$.array_of_objects[*].key_for_explicit_array[0]",
					"$.array_of_objects[*].key_for_explicit_array[1]",
					"$.array_of_objects[*].key_for_explicit_array[2]",
					"$.array_of_objects[*].key_for_explicit_array[3]",
					"$.array_of_objects[*].key_for_explicit_array[4]",
					"$.array_of_objects[*].key_for_matcher_array",
					"$.array_of_objects[*].key_for_matcher_array[*]",
					"$.array_of_objects[*].key_int",
					"$.array_of_objects[*].key_string",
					"$.array_of_strings",
					"$.array_of_strings[*]",
					"$.includes_like",
				]
				assert(
					expectedMatchersOne.allSatisfy { expectedKey -> Bool in
						bugExampleInteraction.contains { generatedKey, _ -> Bool in
							expectedKey == generatedKey
						}
					},
					"Not all expected generators found in Pact contract file"
				)

				// Validate interaction "a request for roles with sub-roles"
				let arrayOnRootInteraction = try PactContractTests.extract(.matchingRules, in: .response, interactions: interactions, description: "a request for roles with sub-roles")
				let expectedNodesForArrayOnRoot = [
					"$[*].id"
				]
				assert(
					expectedNodesForArrayOnRoot.allSatisfy { expectedKey -> Bool in
						arrayOnRootInteraction.contains { generatedKey, _ -> Bool in
							expectedKey == generatedKey
						}
					},
					"Not all expected generators found in Pact contract file"
				)

				// Validate interaction "Request for animals with children"
				let animalsWithChildrenInteraction = try PactContractTests.extract(.matchingRules, in: .response, interactions: interactions, description: "a request for animals with children")
				let expectedNodesForAnimalsWithChildren = [
					"$.animals",
					"$.animals[*].children",
					"$.animals[*].children[*]",
				]
				assert(
					expectedNodesForAnimalsWithChildren.allSatisfy { expectedKey -> Bool in
						animalsWithChildrenInteraction.contains { generatedKey, _ -> Bool in
							expectedKey == generatedKey
						}
					}
				)

				// Validate interaction "Request for list of users in state"
				let requestMatchers = try PactContractTests.extract(.matchingRules, in: .request, interactions: interactions, description: "Request for list of users in state")
				let expectedMatchersTwo = [
					"$.foo"
				]
				assert(
					expectedMatchersTwo.allSatisfy { expectedKey -> Bool in
						requestMatchers.contains { generatedKey, _ -> Bool in
							expectedKey == generatedKey
						}
					}
					, "Not all expected generators found in Pact contract file"
				)

				// MARK: - Validate Generators

				let responseGenerators = try extract(.generators, in: .response, interactions: interactions, description: "Request for list of users")
				let expectedGeneratorsType = [
					"$.array_of_arrays[*][2]": [
						"type": "Uuid",
						"format": "upper-case-hyphenated"
					]
				]

				assert(
					expectedGeneratorsType.allSatisfy { expectedKey, expectedValue -> Bool in
						responseGenerators.contains { generatedKey, generatedValue -> Bool in
							expectedKey == generatedKey
							&& expectedValue["type"] == (generatedValue as? [String: String])?["type"]
							&& expectedValue["format"] == (generatedValue as? [String: String])?["format"]
						}
					},
					"Not all expected generators found in Pact contract file"
				)

				// MARK: - Test two of same matchers used

				let twoMatchersTest = try PactContractTests.extract(.matchingRules, in: .response, interactions: interactions, description: "Request for a simple object")
				let expectedTwoMatchers = [
					"$.identifier",
					"$.group_identifier",
				]

				assert(expectedTwoMatchers.allSatisfy { expectedKey -> Bool in
					twoMatchersTest.contains { generatedKey, _ -> Bool in
						expectedKey == generatedKey
					}
				},
				 "Not all expected matchers are found in Pact interaction"
				)

			} catch {
				XCTFail(error.localizedDescription)
			}

		super.tearDown()
	}

	// MARK: - Tests that write the Pact contract

	func testBugExample() {
		mockService
			.uponReceiving("bug example")
			.given("some state")
			.withRequest(method: .GET, path: "/bugfix")
			.willRespondWith(
				status: 200,
				body: [
					"array_of_objects": Matcher.EachLike(
						[
							"key_string": Matcher.SomethingLike("String value"),
							"key_int": Matcher.IntegerLike(123),
							"key_for_matcher_array": Matcher.EachLike(
								Matcher.SomethingLike("matcher_array_value")
							),
							"key_for_explicit_array": [
								Matcher.SomethingLike("explicit_array_value_one"),
								Matcher.SomethingLike(1),
								Matcher.IntegerLike(936),
								Matcher.DecimalLike(123.23),
								Matcher.RegexLike(value: "2021-05-17", pattern: #"\d{4}-\d{2}-\d{2}"#),
								Matcher.IncludesLike("in", "array", generate: "Included in explicit array")
							],
							"key_for_datetime_expression": ExampleGenerator.DateTimeExpression(expression: "today +1 day", format: "yyyy-MM-dd")
						]
					),
					"array_of_strings": Matcher.EachLike(
						Matcher.SomethingLike("A string")
					),
					"includes_like": Matcher.IncludesLike("included", generate: "Value _included_ is included in this string")
				]
			)

		mockService.run { [unowned self] baseURL, completed in
			let url = URL(string: "\(baseURL)/bugfix")!
			self.session
				.dataTask(with: url) { data, response, error in
					guard
						error == nil,
						(response as? HTTPURLResponse)?.statusCode == 200
					else {
						self.fail(function: #function, request: url.absoluteString, response: response.debugDescription, error: error)
						return
					}
					// We don't care about the network response here, so we tell PactSwift we're done with the Pact test
					// This is tested in `MockServiceTests.swift`
					completed()
				}
				.resume()
		}
	}

	func testExample_AnimalsWithChildren() {
		mockService
			.uponReceiving("a request for animals with children")
			.given("animals have children")
			.withRequest(method: .GET, path: "/animals")
			.willRespondWith(
				status: 200,
				body: [
					"animals": Matcher.EachLike(
						[
							"children": Matcher.EachLike(
								Matcher.SomethingLike("Mary"),
								min: 0
							),
						]
					)
				]
			)

		mockService.run { [unowned self] baseURL, completed in
			let url = URL(string: "\(baseURL)/animals")!
			session
				.dataTask(with: url) { data, response, error in
					guard
						error == nil,
						(response as? HTTPURLResponse)?.statusCode == 200
					else {
						self.fail(function: #function, request: url.absoluteString, response: response.debugDescription, error: error)
						return
					}
					// We don't care about the network response here, so we tell PactSwift we're done with the Pact test
					// This is tested in `MockServiceTests.swift`
					completed()
				}
				.resume()
		}
	}

	func testExample_AnimalsWithChildrenMultipleInteractionsInOneTest() {
		let firstInteraction = mockService
			.uponReceiving("a request for animals with children")
			.given("animals have children")
			.withRequest(method: .GET, path: "/animals1")
			.willRespondWith(
				status: 200,
				body: [
					"animals": Matcher.EachLike(
						[
							"children": Matcher.EachLike(
								Matcher.SomethingLike("Mary"),
								min: 0
							),
						]
					)
				]
			)

		let secondInteraction = mockService
			.uponReceiving("a request for animals with Children")
			.given("animals have children")
			.withRequest(method: .GET, path: "/animals2")
			.willRespondWith(
				status: 200,
				body: [
					"animals": Matcher.EachLike(
						[
							"children": Matcher.EachLike(
								Matcher.SomethingLike("Mary"),
								min: 0
							),
						]
					)
				]
			)

		mockService.run(verify: [firstInteraction, secondInteraction]) { [unowned self] baseURL, completed in
			let urlOne = URL(string: "\(baseURL)/animals1")!
			let urlTwo = URL(string: "\(baseURL)/animals2")!

			let expOne = expectation(description: "one")
			let expTwo = expectation(description: "two")

			session
				.dataTask(with: urlOne) { data, response, error in
					guard
						error == nil,
						(response as? HTTPURLResponse)?.statusCode == 200
					else {
						self.fail(function: #function, request: urlOne.absoluteString, response: response.debugDescription, error: error)
						return
					}
					// We don't care about the network response here, so we tell PactSwift we're done with the Pact test
					// This is tested in `MockServiceTests.swift`
					expOne.fulfill()
				}
				.resume()

			session
				.dataTask(with: urlTwo) { data, response, error in
					guard
						error == nil,
						(response as? HTTPURLResponse)?.statusCode == 200
					else {
						self.fail(function: #function, request: urlOne.absoluteString, response: response.debugDescription, error: error)
						return
					}
					// We don't care about the network response here, so we tell PactSwift we're done with the Pact test
					// This is tested in `MockServiceTests.swift`
					expTwo.fulfill()
				}
				.resume()

			waitForExpectations(timeout: 5) { _ in
				completed()
			}
		}
	}

	func testExample_ArrayOnRoot() {
		mockService
			.uponReceiving("a request for roles with sub-roles")
			.given("roles have sub-rules")
			.withRequest(method: .GET, path: "/roles")
			.willRespondWith(
				status: 200,
				body:
					Matcher.EachLike(
						[
							"id": Matcher.RegexLike(
								value: "1234abcd-1234-abcf-12ab-abcdef1234567",
								pattern: #"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"#
							)
						]
					)
			)

		mockService.run { [unowned self] baseURL, completed in
			let url = URL(string: "\(baseURL)/roles")!
			session
				.dataTask(with: url) { data, response, error in
					guard
						error == nil,
						(response as? HTTPURLResponse)?.statusCode == 200
					else {
						self.fail(function: #function, request: url.absoluteString, response: response.debugDescription, error: error)
						return
					}
					// We don't care about the network response here, so we tell PactSwift we're done with the Pact test
					// This is tested in `MockServiceTests.swift`
					completed()
				}
				.resume()
		}
	}

	func testPactContract_WritesMatchersAndGenerators() {
		mockService
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .GET, path: "/users")
			.willRespondWith(
				status: 200,
				body: [
					"foo": Matcher.SomethingLike("bar"),
					"baz": Matcher.EachLike(123, min: 1, max: 5, count: 3),
					"array_of_arrays": Matcher.EachLike(
						[
							Matcher.SomethingLike("array_value"),
							Matcher.RegexLike(value: "2021-05-15", pattern: #"\d{4}-\d{2}-\d{2}"#),
							ExampleGenerator.RandomUUID(format: .uppercaseHyphenated),
							Matcher.EachLike(
								[
									"3rd_level_nested": Matcher.EachLike(Matcher.IntegerLike(369), count: 2)
								]
							)
						]
					),
					"regex_array": Matcher.EachLike(
						[
							"regex_key": Matcher.EachLike(
								Matcher.RegexLike(value: "1235", pattern: #"\d{4}"#),
								min: 2
							),
							"regex_nested_object": Matcher.EachLike(
								[
									"regex_nested_key": Matcher.RegexLike(value: "12345678", pattern: #"\d{8}"#)
								]
							)
						]
					),
					"enum_value": Matcher.OneOf("night", "morning", "mid-day", "afternoon", "evening")
				]
			)

		mockService.run { [unowned self] baseURL, completed in
			let url = URL(string: "\(baseURL)/users")!
			session
				.dataTask(with: url) { data, response, error in
					guard
						error == nil,
						(response as? HTTPURLResponse)?.statusCode == 200
					else {
						self.fail(function: #function, request: url.absoluteString, response: response.debugDescription, error: error)
						return
					}
					// We don't care about the network response here, so we tell PactSwift we're done with the Pact test
					// This is tested in `MockServiceTests.swift`
					completed()
				}
				.resume()
			}
	}

	func testPactContract_ArrayAsRoot() {
		mockService
			.uponReceiving("Request for an explicit array")
			.given("array exist")
			.withRequest(
				method: .GET,
				path: Matcher.RegexLike(value: "/arrays/explicit", pattern: #"^/arrays/e\w+$"#)
			)
			.willRespondWith(
				status: 200,
				body:
					[
						[
							"id": Matcher.SomethingLike(19231421)
						],
						[
							"id": Matcher.SomethingLike(49817231)
						]
					]
			)

		mockService.run { [unowned self] baseURL, completed in
			let url = URL(string: "\(baseURL)/arrays/explicit")!
			session
				.dataTask(with: url) { data, response, error in
					guard
						error == nil,
						(response as? HTTPURLResponse)?.statusCode == 200
					else {
						self.fail(function: #function, request: url.absoluteString, response: response.debugDescription, error: error)
						return
					}
					// We don't care about the network response here, so we tell PactSwift we're done with the Pact test
					// This is tested in `MockServiceTests.swift`
					completed()
				}
				.resume()
			}
	}

	func testPactContract_WithMatcherInRequestBody() {
		mockService
			.uponReceiving("Request for list of users in state")
			.given("users in that state exist")
			.withRequest(
				method: .POST,
				path: Matcher.FromProviderState(parameter: "/users/state/${stateIdentifier}", value: .string("/users/state/nsw")),
				body: ["foo": Matcher.SomethingLike("bar")]
			)
			.willRespondWith(
				status: 200,
				body: [
					"identifier": Matcher.FromProviderState(parameter: "userId", value: .int(100)),
					"randomCode": Matcher.FromProviderState(parameter: "rndCode", value: .string("some-random-code")),
					"foo": Matcher.SomethingLike("bar"),
					"baz": Matcher.SomethingLike("qux")
				]
			)

		mockService.run { [unowned self] baseURL, completed in
			var request = URLRequest(url: URL(string: "\(baseURL)/users/state/nsw")!)
			request.httpMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = #"{"foo": "bar"}"#.data(using: .utf8)

			session
				.dataTask(with: request) { _, response, error in
					guard
						error == nil,
						(response as? HTTPURLResponse)?.statusCode == 200
					else {
						self.fail(function: #function, request: request.debugDescription, response: response.debugDescription, error: error)
						return
					}
					// We don't care about the network response here, so we tell PactSwift we're done with the Pact test
					// This is tested in `MockServiceTests.swift`
					completed()
				}
				.resume()
		}
	}

	func testPactContract_WithTwoMatchersOfSameType() {
		mockService
			.uponReceiving("Request for a simple object")
			.given("data exists")
			.withRequest(method: .GET, path: "/users/data")
			.willRespondWith(
				status: 200,
				body: [
					"identifier": Matcher.SomethingLike(1),
					"group_identifier": Matcher.SomethingLike(1)
				]
			)

		mockService.run { [unowned self] baseURL, completed in
			let url = URL(string: "\(baseURL)/users/data")!
			session
				.dataTask(with: url) { data, response, error in
					guard
						error == nil,
						(response as? HTTPURLResponse)?.statusCode == 200
					else {
						self.fail(function: #function, request: url.absoluteString, response: response.debugDescription, error: error)
						return
					}
					// We don't care about the network response here, so we tell PactSwift we're done with the Pact test
					// This is tested in `MockServiceTests.swift`
					completed()
				}
				.resume()
		}
	}

}

private extension PactContractTests {

	enum PactNode: String {
		case matchingRules
		case generators
	}

	enum Direction: String {
		case request
		case response
	}

	func fail(function: String, request: String? = nil, response: String? = nil, error: Error? = nil) {
		XCTFail(
		"""
		Expected network request to succeed in \(function)!
		Request URL: \t\(String(describing: request))
		Response:\t\(String(describing: response))
		Reason: \t\(String(describing: error?.localizedDescription))
		"""
		)
	}

	static func extract(_ type: PactNode,  in direction: Direction, interactions: [Any], description: String) throws -> [String: Any] {
		let interaction = interactions.first { interaction -> Bool in
			(interaction as! [String: Any])["description"] as! String == description
		}
		return try XCTUnwrap((((interaction as? [String: Any])?[direction.rawValue] as? [String: Any])?[type.rawValue] as? [String: Any])?["body"] as? [String: Any])
	}

	@discardableResult
	static func fileExists(_ filename: String) -> Bool {
		FileManager.default.fileExists(atPath: PactFileManager.pactDirectoryPath + "/\(filename)")
	}

	@discardableResult
	static func removeFile(_ filename: String) -> Bool {
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
