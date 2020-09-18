//
//  Created by Marko Justinek on 11/4/20.
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

class PactBuilderTests: XCTestCase {

	// MARK: - EqualTo()

	func testPact_SetsMatcher_EqualTo() throws {
		let testBody: Any = [
			"data": Matcher.EqualTo("2016-07-19")
		]

		let testPact = prepareTestPact(for: testBody)

		let testResult = try XCTUnwrap(try XCTUnwrap(try JSONDecoder().decode(GenericLikeTestModel.self, from: testPact.data!).interactions.first).request.matchingRules.body.node.matchers.first)
		XCTAssertEqual(testResult.match, "equality")
	}

	// MARK: - SomethingLike()

	func testPact_SetsMatcher_SomethingLike() throws {
		let testBody: Any = [
			"data": Matcher.SomethingLike("2016-07-19")
		]

		let testPact = prepareTestPact(for: testBody)

		let testResult = try XCTUnwrap(try XCTUnwrap(try JSONDecoder().decode(GenericLikeTestModel.self, from: testPact.data!).interactions.first).request.matchingRules.body.node.matchers.first)
		XCTAssertEqual(testResult.match, "type")
	}

	// MARK: - EachLike()

	func testPact_SetsDefaultMin_ForEachLikeMatcher() throws {
		let testBody: Any = [
			"data": [
				"array1": Matcher.EachLike(
					[
						"dob": Matcher.SomethingLike("2016-07-19"),
						"id": Matcher.SomethingLike("1600309982"),
						"name": Matcher.SomethingLike("FVsWAGZTFGPLhWjLuBOd")
					]
				)
			]
		]

		let testPact = prepareTestPact(for: testBody)

		let testResult = try XCTUnwrap(try XCTUnwrap(try JSONDecoder().decode(SetLikeTestModel.self, from: testPact.data!).interactions.first).request.matchingRules.body.node.matchers.first)
		XCTAssertEqual(testResult.min, 1)
		XCTAssertEqual(testResult.match, "type")
	}

	func testPact_SetsProvidedMin_ForEachLikeMatcher() throws {
		let testBody: Any = [
			"data": [
				"array1": Matcher.EachLike(
					[
						"dob": Matcher.SomethingLike("2016-07-19"),
						"id": Matcher.SomethingLike("1600309982"),
						"name": Matcher.SomethingLike("FVsWAGZTFGPLhWjLuBOd")
					]
					, min: 3
				)
			]
		]

		let testPact = prepareTestPact(for: testBody)

		let testResult = try XCTUnwrap(try XCTUnwrap(try JSONDecoder().decode(SetLikeTestModel.self, from: testPact.data!).interactions.first).request.matchingRules.body.node.matchers.first)
		XCTAssertEqual(testResult.min, 3)
		XCTAssertEqual(testResult.match, "type")
	}

	func testPact_SetsProvidedMax_ForEachLikeMatcher() throws {
		let testBody: Any = [
			"data": [
				"array1": Matcher.EachLike(
					[
						"dob": Matcher.SomethingLike("2016-07-19"),
						"id": Matcher.SomethingLike("1600309982"),
						"name": Matcher.SomethingLike("FVsWAGZTFGPLhWjLuBOd")
					]
					, max: 5
				)
			]
		]

		let testPact = prepareTestPact(for: testBody)

		let testResult = try XCTUnwrap(try XCTUnwrap(try JSONDecoder().decode(SetLikeTestModel.self, from: testPact.data!).interactions.first).request.matchingRules.body.node.matchers.first)
		XCTAssertEqual(testResult.max, 5)
		XCTAssertEqual(testResult.match, "type")
	}

	func testPact_SetsMinMax_ForEachLikeMatcher() throws {
		let testBody: Any = [
			"data": [
				"array1": Matcher.EachLike(
					[
						"dob": Matcher.SomethingLike("2016-07-19"),
						"id": Matcher.SomethingLike("1600309982"),
						"name": Matcher.SomethingLike("FVsWAGZTFGPLhWjLuBOd")
					],
					min: 1,
					max: 5
				)
			]
		]

		let testPact = prepareTestPact(for: testBody)

		let testResult = try XCTUnwrap(try XCTUnwrap(try JSONDecoder().decode(SetLikeTestModel.self, from: testPact.data!).interactions.first).request.matchingRules.body.node.matchers.first)
		XCTAssertEqual(testResult.min, 1)
		XCTAssertEqual(testResult.max, 5)
		XCTAssertEqual(testResult.match, "type")
	}

	// MARK: - IntegerLike()

	func testPact_SetsMatcher_IntegerLike() throws {
		let testBody: Any = [
			"data": Matcher.IntegerLike(1234)
		]

		let testPact = prepareTestPact(for: testBody)

		let testResult = try XCTUnwrap(try XCTUnwrap(try JSONDecoder().decode(GenericLikeTestModel.self, from: testPact.data!).interactions.first).request.matchingRules.body.node.matchers.first)
		XCTAssertEqual(testResult.match, "integer")
	}

	// MARK: - DecimalLike()

	func testPact_SetsMatcher_DecimalLike() throws {
		let testBody: Any = [
			"data": Matcher.DecimalLike(1234)
		]

		let testPact = prepareTestPact(for: testBody)

		let testResult = try XCTUnwrap(try XCTUnwrap(try JSONDecoder().decode(GenericLikeTestModel.self, from: testPact.data!).interactions.first).request.matchingRules.body.node.matchers.first)
		XCTAssertEqual(testResult.match, "decimal")
	}

	// MARK: - RegexLike()

	func testPact_SetsMatcher_RegexLike() throws {
		let testBody: Any = [
			"data": Matcher.RegexLike("2020-12-31", term: "\\d{4}-\\d{2}-\\d{2}")
		]

		let testPact = prepareTestPact(for: testBody)

		let matchers = try XCTUnwrap(try XCTUnwrap(try JSONDecoder().decode(GenericLikeTestModel.self, from: testPact.data!).interactions.first).request.matchingRules.body.node)

		XCTAssertEqual(matchers.matchers.first?.match, "regex")
		XCTAssertEqual(matchers.matchers.first?.regex, "\\d{4}-\\d{2}-\\d{2}")
		XCTAssertNil(matchers.combine)
	}

	// MARK: - IncludesLike()

	func testPact_SetsMatcher_IncludesLike_DefaultsToAND() throws {
		let expectedValues = ["2020-12-31", "2019-12-31"]
		let testBody: Any = [
			"data": Matcher.IncludesLike("2020-12-31", "2019-12-31")
		]

		let testPact = prepareTestPact(for: testBody)


		let testResult = try XCTUnwrap(try XCTUnwrap(try JSONDecoder().decode(GenericLikeTestModel.self, from: testPact.data!).interactions.first).request.matchingRules.body.node)

		XCTAssertEqual(testResult.combine, "AND")
		XCTAssertEqual(testResult.matchers.count, 2)
		XCTAssertTrue(testResult.matchers.allSatisfy { expectedValues.contains($0.value ?? "FAIL!") })
		XCTAssertTrue(testResult.matchers.allSatisfy { $0.match == "include" })
	}

	func testPact_SetsMatcher_IncludesLike_CombineMatchersWithOR() throws {
		let expectedValues = ["2020-12-31", "2019-12-31"]
		let testBody: Any = [
			"data": Matcher.IncludesLike("2020-12-31", "2019-12-31", combine: .OR)
		]

		let testPact = prepareTestPact(for: testBody)

		let testResult = try XCTUnwrap(try XCTUnwrap(try JSONDecoder().decode(GenericLikeTestModel.self, from: testPact.data!).interactions.first).request.matchingRules.body.node)

		XCTAssertEqual(testResult.combine, "OR")
		XCTAssertEqual(testResult.matchers.count, 2)
		XCTAssertTrue(testResult.matchers.allSatisfy { expectedValues.contains($0.value ?? "FAIL!") })
		XCTAssertTrue(testResult.matchers.allSatisfy { $0.match == "include" })
	}

}

// MARK: - Private Utils -

private extension PactBuilderTests {

	// This test model is tightly coupled with the SomethingLike Matcher for the purpouse of these tests
	struct GenericLikeTestModel: Decodable {
		let interactions: [TestInteractionModel]
		struct TestInteractionModel: Decodable {
			let request: TestRequestModel
			struct TestRequestModel: Decodable {
				let matchingRules: TestMatchingRulesModel
				struct TestMatchingRulesModel: Decodable {
					let body: TestNodeModel
					struct TestNodeModel: Decodable {
						let node: TestMatchersModel
						enum CodingKeys: String, CodingKey {
							case node = "$.data"
						}
						struct TestMatchersModel: Decodable {
							let matchers: [TestTypeModel]
							let combine: String?
							struct TestTypeModel: Decodable {
								let match: String
								let regex: String?
								let value: String?
							}
						}
					}
				}
			}
		}
	}

	// This test model is tightly coupled with the EachLike Matcher for the purpouse of these tests
	struct SetLikeTestModel: Decodable {
		let interactions: [TestInteractionModel]
		struct TestInteractionModel: Decodable {
			let request: TestRequestModel
			struct TestRequestModel: Decodable {
				let matchingRules: TestMatchingRulesModel
				struct TestMatchingRulesModel: Decodable {
					let body: TestNodeModel
					struct TestNodeModel: Decodable {
						let node: TestMatchersModel
						enum CodingKeys: String, CodingKey {
							case node = "$.data.array1"
						}
						struct TestMatchersModel: Decodable {
							let matchers: [TestMinModel]
							struct TestMinModel: Decodable {
								let min: Int?
								let max: Int?
								let match: String
							}
						}
					}
				}
			}
		}
	}

	func prepareTestPact(for body: Any) -> Pact {
		let firstProviderState = ProviderState(description: "an alligator with the given name exists", params: ["name": "Mary"])

		let interaction = Interaction(
			description: "test Encodable Pact",
			providerStates: [firstProviderState],
			request: Request(
				method: .GET,
				path: "/",
				query: ["max_results": ["100"]],
				headers: ["Content-Type": "applicatoin/json; charset=UTF-8", "X-Value": "testCode"],
				body: body
			),
			response: Response(
				statusCode: 200
			)
		)

		return Pact(
			consumer: Pacticipant.consumer("test-consumer"),
			provider: Pacticipant.provider("test-provider"),
			interactions: [interaction]
		)
	}

}
