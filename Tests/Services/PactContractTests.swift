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
				// print("\nINTERACTIONS:\n\(interactions)")
				let numOfExpectedInteractions = 3
				assert(
					interactions.count == numOfExpectedInteractions,
					"Expected \(numOfExpectedInteractions) interactions in Pact contract"
				)

				// MARK: - Validate Matchers

				let responseMatchers = try PactContractTests.extract(.matchingRules, in: .response, interactions: interactions, description: "Request for list of users")
				// print("\nMATCHERS:\n\(matchersOne)")
				let expectedMatchersOne = [
					"$.foo",
					"$.baz",
					"$.array",
					"$.array[0][1]",
					"$.array[0][3][0].3rd_level_nested",
					"$.array[0][3][0].3rd_level_nested[0]",
					"$.regex_array[0].regex_nested_object[0].regex_nested_key",
					"$.regex_array[0].regex_key"
				]
				assert(
					expectedMatchersOne.allSatisfy { expectedKey -> Bool in
						responseMatchers.contains { generatedKey, _ -> Bool in
							expectedKey == generatedKey
						}
					},
					"Not all expected generators found in Pact contract file"
				)

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
				let expectedGenerators = [
					"$.array[0][2]": "Uuid"
				]

				assert(
					expectedGenerators.allSatisfy { expectedKey, expectedValue -> Bool in
						responseGenerators.contains { generatedKey, generatedValue -> Bool in
							expectedKey == generatedKey
							&& expectedValue == (generatedValue as? [String: String])?["type"]
						}
					},
					"Not all expected generators found in Pact contract file"
				)
			} catch {
				XCTFail(error.localizedDescription)
			}

		super.tearDown()
	}

	// MARK: - Tests that write the Pact contract

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

		mockService.run { [mockService] completed in
			URLSession(configuration: .ephemeral)
				.dataTask(with: URL(string: "\(mockService.baseUrl)/users")!) { data, response, error in
					guard
						error == nil,
						(response as? HTTPURLResponse)?.statusCode == 200
					else {
						XCTFail("Expected network request to succeed in \(#function)!")
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
			.uponReceiving("Request for an array")
			.given("users exist")
			.withRequest(method: .GET, path: "/arrays")
			.willRespondWith(
				status: 200,
				body:
					Matcher.EachLike(
						[
							"dob": Matcher.RegexLike("2016-17-19", term: #"\d{4}-\d{2}-\d{2}"#),
							"id": Matcher.SomethingLike(19231421),
							"name": Matcher.SomethingLike("ZSAICmTmiwgFFInuEuiK")
						],
						min: 3,
						max: 7
					)
			)

		mockService.run { [mockService] completed in
			URLSession(configuration: .ephemeral)
				.dataTask(with: URL(string: "\(mockService.baseUrl)/arrays")!) { data, response, error in
					guard
						error == nil,
						(response as? HTTPURLResponse)?.statusCode == 200
					else {
						XCTFail("Expected network request to succeed in \(#function)!")
						return
					}
					// We don't care about the network response here, so we tell PactSwift we're done with the Pact test
					// This is tested in `MockServiceTests.swift`
					completed()
				}
				.resume()
			}
	}

	func testPactContract_WithMatcherInRequestBody () {
		mockService
			.uponReceiving("Request for list of users in state")
			.given("users in that state exist")
			.withRequest(method: .POST, path: "/users/state/nsw", body: ["foo": Matcher.SomethingLike("bar")])
			.willRespondWith(
				status: 200
			)

		mockService.run { [mockService] completed in
			var request = URLRequest(url: URL(string: "\(mockService.baseUrl)/users/state/nsw")!)
			let session = URLSession(configuration: .ephemeral)

			request.httpMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = #"{"foo": "bar"}"#.data(using: .utf8)

			session
				.dataTask(with: request) { _, response, error in
					guard
						error == nil,
						(response as? HTTPURLResponse)?.statusCode == 200
					else {
						XCTFail("Expected network request to succeed in \(#function)!")
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
