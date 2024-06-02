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
import InlineSnapshotTesting
@testable import PactSwift

final class PactContractTests: XCTestCase {

	var pact: Pact!
	var builder: PactBuilder!

	static let consumerName = "sanity-consumer"
	static let providerName = "sanity-provider"
	static let pactDirectory = "/tmp/pacts"

	static var pactFilePath: String {
		"\(Self.pactDirectory)/\(Self.consumerName)-\(Self.providerName).json"
	}

	override class func setUp() {
		PactContractTests.removeFile(Self.pactFilePath)
	}

	override func setUpWithError() throws {
		try super.setUpWithError()

		guard builder == nil else { return }

		pact = try Pact(consumer: Self.consumerName, provider: Self.providerName)
			.withSpecification(.v4)

		let config = PactBuilder.Config(pactDirectory: Self.pactDirectory)
		builder = PactBuilder(pact: pact, config: config)
	}

	override class func tearDown() {
		do {
			let pactJson = try getJsonObject(pactFilePath)
			let interactions = try XCTUnwrap(pactJson["interactions"] as? [Any])


			assert(5 == interactions.count)
		} catch {
			assert(false, "Test failure during teardown")
		}
	}

	func testBugExample() async throws {
		let bugExampleDescription = "bug example"
		try builder
			.uponReceiving(bugExampleDescription)
			.given("some state")
			.withRequest(method: .GET, path: "/bugfix")
			.willRespond(with: 200) { response in
				try response.jsonBody(
					.like([
						"array_of_objects": .eachLike(
							[
								"key_string": .like("String value"),
								"key_int": .integer(123),
								"key_for_matcher_array": .eachLike("matcher_array_value", min: 0),
								"key_for_datetime_expression": .datetime("today +1 day", format: "yyyy-MM-dd")
							]
						),
						"array_of_strings": .eachLike("A string", min: 0),
						"includes_like": .includes("included")
					])
				)
			}
		try await builder.verify { context in
			let url = try context.buildRequestURL(path: "/bugfix")
			let request = URLRequest(url: url)
			_ = try await URLSession(configuration: .ephemeral).data(for: request)
		}

		try pact.writePactFile()

		let interaction = try extract(
			.matchingRules,
			in: .response,
			description: bugExampleDescription
		)

		assertInlineSnapshot(of: interaction, as: .json) {
			"""
			{
			  "$" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "match" : "type"
			      }
			    ]
			  },
			  "$.array_of_objects" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "match" : "type"
			      }
			    ]
			  },
			  "$.array_of_objects[*].key_for_datetime_expression" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "format" : "yyyy-MM-dd",
			        "match" : "datetime"
			      }
			    ]
			  },
			  "$.array_of_objects[*].key_for_matcher_array" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "match" : "type",
			        "min" : 0
			      }
			    ]
			  },
			  "$.array_of_objects[*].key_int" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "match" : "integer"
			      }
			    ]
			  },
			  "$.array_of_objects[*].key_string" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "match" : "type"
			      }
			    ]
			  },
			  "$.array_of_strings" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "match" : "type",
			        "min" : 0
			      }
			    ]
			  },
			  "$.includes_like" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "match" : "include",
			        "value" : "included"
			      }
			    ]
			  }
			}
			"""
		}
	}

	func testExample_AnimalsWithChildren() async throws {
		let animalsWithChildrenDescription = "a request for animals with children"
		try builder
			.uponReceiving(animalsWithChildrenDescription)
			.given("animals have children")
			.withRequest(method: .GET, path: "/animals")
			.willRespond(with: 200) { response in
				try response.jsonBody(
				  .like([
				    "animals": .eachLike(
				      [
				        "children": .eachLike("Mary", min: 0),
				      ]
				    )
				  ])
				)
			}
		try await builder.verify { context in
			let url = try context.buildRequestURL(path: "/animals")
			let request = URLRequest(url: url)
			_ = try await URLSession(configuration: .ephemeral).data(for: request)
		}

		try pact.writePactFile()

		let interaction = try extract(
			.matchingRules,
			in: .response,
			description: animalsWithChildrenDescription
		)

		assertInlineSnapshot(of: interaction, as: .json) {
			"""
			{
			  "$" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "match" : "type"
			      }
			    ]
			  },
			  "$.animals" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "match" : "type"
			      }
			    ]
			  },
			  "$.animals[*].children" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "match" : "type",
			        "min" : 0
			      }
			    ]
			  }
			}
			"""
		}
	}

	func testExample_AnimalsWithChildrenMultipleInteractionsInOneTest() async throws {
		throw XCTSkip("Unsure how to build multiple requests at once...")
		try builder
			.uponReceiving("a request for animals with children")
			.given("animals have children")
			.withRequest(method: .GET, path: "/animals1")
			.willRespond(with: 200) { response in
				try response.jsonBody(
				  .like([
				    "animals": .eachLike([
				      "children": .eachLike("Mary", min: 0),
				    ])
				  ])
				)}

		try builder
			.uponReceiving("a request for animals with Children")
			.given("animals have children")
			.withRequest(method: .GET, path: "/animals2")
			.willRespond(with: 200) { response in
				try response.jsonBody(
				  .like([
				    "animals": .eachLike([
				      "children": .eachLike("Mary", min: 0),
				    ])
				  ])
				)}

		try await builder.verify { context in
			let urlOne = try context.buildRequestURL(path: "/animals1")
			let urlTwo = try context.buildRequestURL(path: "/animals2")

			let requestOne = URLRequest(url: urlOne)
			_ = try await URLSession(configuration: .ephemeral).data(for: requestOne)

			let requestTwo = URLRequest(url: urlTwo)
			_ = try await URLSession(configuration: .ephemeral).data(for: requestTwo)
		}
	}

	func testExample_ArrayOnRoot() async throws {
		try builder
			.uponReceiving("a request for roles with sub-roles")
			.given("roles have sub-roles")
			.withRequest(method: .GET, path: "/roles")
			.willRespond(with: 200) { response in
				try response.jsonBody(
					.eachLike([
						"id": .regex(
							"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
							example: "1234abcd-1234-abcf-12ab-abcdef1234567"
						)]
									 )
				)}

		try await builder.verify { context in
			let url = try context.buildRequestURL(path: "/roles")
			let request = URLRequest(url: url)
			_ = try await URLSession(configuration: .ephemeral).data(for: request)
		}

		try pact.writePactFile()

		let interaction = try extract(
			.matchingRules,
			in: .response,
			description: "a request for roles with sub-roles")

		assertInlineSnapshot(of: interaction, as: .json) {
			"""
			{
			  "$" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "match" : "type"
			      }
			    ]
			  },
			  "$[*].id" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "match" : "regex",
			        "regex" : "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
			      }
			    ]
			  }
			}
			"""
		}
	}

	func testPactContract_WritesMatchersAndGenerators() async throws {
		throw XCTSkip(".eachLike does not work with array literals")
		try builder
			.uponReceiving("Request for list of users")
			.given("users exist")
			.withRequest(method: .GET, path: "/users")
			.willRespond(with: 200) { response in
				try response.jsonBody(
					.like([
						"foo": .like("bar"),
						"baz": .eachLike(123, min: 1, max: 5),
						//                "array_of_arrays": .eachLike(
						//                  [
						//                    .like("array_value"),
						//                    .regex("2021-05-15", pattern: #"\d{4}-\d{2}-\d{2}"#),
						//                    .randomUUID(like: "7FB8BD72-A818-4C5A-B342-9523BE40BF8F", format: .upperCaseHyphenated)
						//                    .eachLike(
						//                      [
						//                        "3rd_level_nested": .eachLike(.integer(369))
						//                      ]
						//                    )
						//                  ]
						//                ),
						//                "regex_array": .eachLike(
						//                  [
						//                    "regex_key": .eachLike(
						//                      .regex("1235", pattern: #"\d{4}"#),
						//                      min: 2
						//                    ),
						//                    "regex_nested_object": .eachLike(
						//                      [
						//                        "regex_nested_key": .regex("12345678", pattern: #"\d{8}"#)
						//                      ]
						//                    )
						//                  ]
						//                ),
						"enum_value": .oneOf(["night", "morning", "mid-day", "afternoon", "evening"])
					])
				)}

		try await builder.verify { context in
			let url = try context.buildRequestURL(path: "/users")
			let request = URLRequest(url: url)
			_ = try await URLSession(configuration: .ephemeral).data(for: request)
		}
	}

	func testPactContract_ArrayAsRoot() async throws {
		let description = "Request for an explicit array"
		try builder
			.uponReceiving(description)
			.given("array exist")
			.withRequest(
				method: .GET,
				path: "/arrays/explicit"
				// TODO: looks like path does not want a matcher
				//        path: .regex("/arrays/explicit", pattern: #"^/arrays/e\w+$"#)
			)
			.willRespond(with: 200) { response in
				try response.jsonBody(
					.eachLike([
						"id": .like(19231421)
					], min: 0)
				)}

		try await builder.verify { context in
			let url = try context.buildRequestURL(path: "/arrays/explicit")
			let request = URLRequest(url: url)
			_ = try await URLSession(configuration: .ephemeral).data(for: request)
		}

		try pact.writePactFile()

		let interactions = try getInteractions()
		let interaction = try getInteractionBy(description: description, from: interactions)
		let request = try XCTUnwrap(interaction["request"] as? [String: Any])
		let matchers = try extract(.matchingRules, in: .response, description: description)

		assertInlineSnapshot(of: request, as: .json) {
			#"""
			{
			  "method" : "GET",
			  "path" : "\/arrays\/explicit"
			}
			"""#
		}

		assertInlineSnapshot(of: matchers, as: .json) {
			"""
			{
			  "$" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "match" : "type",
			        "min" : 0
			      }
			    ]
			  },
			  "$[*].id" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "match" : "type"
			      }
			    ]
			  }
			}
			"""
		}
	}

	func testPactContract_WithMatcherInRequestBody() async throws {
		throw XCTSkip("Missing matcher for provider state")
		//    let description = "Request for list of users in state"
		//    try builder
		//      .uponReceiving(description)
		//      .given("users in that state exist")
		//      .withRequest(
		//        method: .POST,
		//        path: Matcher.FromProviderState(parameter: "/users/state/${stateIdentifier}", value: .string("/users/state/nsw")),
		//        builder: { request in
		//          try request.jsonBody(
		//            .like(["foo": .like("bar")])
		//          )
		//        }
		//      )
		//      .willRespond(with: 200) { response in
		//        try response.jsonBody(
		//          .eachlike([
		//            "identifier": Matcher.FromProviderState(parameter: "userId", value: .int(100)),
		//            "randomCode": Matcher.FromProviderState(parameter: "rndCode", value: .string("some-random-code")),
		//            "foo": .like("bar"),
		//            "baz": .like("qux")
		//          ])
		//        )}
		//    try await builder.verify { context in
		//      var request = URLRequest(url: try context.buildRequestURL(path: "/users/state/nsw"))
		//      request.httpMethod = "POST"
		//      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		//      request.httpBody = #"{"foo": "bar"}"#.data(using: .utf8)
		//
		//      session
		//        .dataTask(with: request) { _, response, error in
		//          guard
		//            error == nil,
		//            (response as? HTTPURLResponse)?.statusCode == 200
		//          else {
		//            self.fail(function: #function, request: request.debugDescription, response: response.debugDescription, error: error)
		//            return
		//          }
		//          // We don't care about the network response here, so we tell PactSwift we're done with the Pact test
		//          // This is tested in `MockServiceTests.swift`
		//          completed()
		//        }
		//        .resume()
		//    }
		//
		//    try pact.writePactFile()
		//
		//    let matchers = try extract(.matchingRules, in: .response, description: description)
		//
		//    assertInlineSnapshot(of: matchers, as: .json)
	}

	func testPactContract_WithTwoMatchersOfSameType() async throws {
		let description = "Request for a simple object"
		try builder
			.uponReceiving(description)
			.given("data exists")
			.withRequest(method: .GET, path: "/users/data")
			.willRespond(with: 200) { response in
				try response.jsonBody(
					.like([
					  "identifier": .like(1),
					  "group_identifier": .like(1)
					])
				)}

		try await builder.verify { context in
			let url = try context.buildRequestURL(path: "/users/data")
			let request = URLRequest(url: url)
			_ = try await URLSession(configuration: .ephemeral).data(for: request)
		}

		try pact.writePactFile()

		let matchers = try extract(.matchingRules, in: .response, description: description)

		assertInlineSnapshot(of: matchers, as: .json) {
			"""
			{
			  "$" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "match" : "type"
			      }
			    ]
			  },
			  "$.group_identifier" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "match" : "type"
			      }
			    ]
			  },
			  "$.identifier" : {
			    "combine" : "AND",
			    "matchers" : [
			      {
			        "match" : "type"
			      }
			    ]
			  }
			}
			"""
		}
	}

	func testPactContract_WithEachKeyLikeMatcher() async throws {
		throw XCTSkip("Missing matcher that ignores keys")
		let description = "Request for an object with wildcard matchers"
		try builder
			.uponReceiving(description)
			.given("keys in response itself are ignored")
			.withRequest(method: .GET, path: "/articles/nested/keyLikeMatcher")
			.willRespond(with: 200) { response in
				try response.jsonBody(
					.like([
						"articles": .eachLike([
							"variants": .like([
								"001": .like([
									"bundles": .eachLike([
										"001-A": .like([
											"description": .like("someDescription"),
											"referencedArticles": .eachLike([
												"bundleId": .like("someId")
											])
										])
									])
								])
							])
						], min: 0)
					])
				)}

		try await builder.verify { context in
			let url = try context.buildRequestURL(path: "/articles/nested/keyLikeMatcher")
			let request = URLRequest(url: url)
			_ = try await URLSession(configuration: .ephemeral).data(for: request)
		}

		try pact.writePactFile()

		let matchers = try extract(.matchingRules, in: .response, description: description)

		assertInlineSnapshot(of: matchers, as: .json)
	}

	func testPactContract_WithSimplerEachKeyLikeMatcher() async throws {
		throw XCTSkip("Missing matcher that ignores keys")
		let description = "Request for a simpler object with wildcard matchers"
		try builder
			.uponReceiving(description)
			.given("keys in response itself are ignored")
			.withRequest(method: .GET, path: "/articles/simpler/keyLikeMatcher")
			.willRespond(with: 200) { response in
				try response.jsonBody(
					.like([
						"abc": .eachLike([
							"field1": .like("value1"),
							"field2": .integer(123)
						]),
						"xyz": .eachLike([
							"field1": .like("value2"),
							"field2": .integer(456)
						])
					])

				)}
		try await builder.verify { context in
			let url = try context.buildRequestURL(path: "/articles/simpler/keyLikeMatcher")
			let request = URLRequest(url: url)
			_ = try await URLSession(configuration: .ephemeral).data(for: request)
		}

		try pact.writePactFile()

		let matchers = try extract(.matchingRules, in: .response, description: description)

		assertInlineSnapshot(of: matchers, as: .json)
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

	func extract(
		_ type: PactNode,
		in direction: Direction,
		description: String,
		file: StaticString = #file,
		line: UInt = #line
	) throws -> [String: Any] {
		let interactions = try getInteractions(file: file, line: line)
		let interaction = try getInteractionBy(
			description: description,
			from: interactions,
			file: file,
			line: line
		)
		let direction = try XCTUnwrap(
			interaction[direction.rawValue] as? [String: Any],
			"Could not unwrap \(direction.rawValue) property",
			file: file,
			line: line
		)
		let type = try XCTUnwrap(
			direction[type.rawValue] as? [String: Any],
			"Could not unwrap \(type.rawValue) property",
			file: file,
			line: line
		)
		return try XCTUnwrap(
			type["body"] as? [String: Any],
			"Could not unwrap body property",
			file: file,
			line: line
		)
	}

	func getInteractions(file: StaticString = #file, line: UInt = #line) throws -> [Any] {
		let pactJson = try getJsonObject()
		return try XCTUnwrap(pactJson["interactions"] as? [Any], file: file, line: line)
	}

	func getInteractionBy(
		description: String,
		from interactions: [Any],
		file: StaticString = #file,
		line: UInt = #line
	) throws -> [String: Any] {
		let filtered = interactions
			.map { $0 as! [String: Any] }
			.filter { $0["description"] as! String == description }
		XCTAssertEqual(1, filtered.count, "Did not find one and only one interaction", file: file, line: line)
		return try XCTUnwrap(
			filtered.first,
			"Interaction not found with description: \(description)",
			file: file,
			line: line
		)
	}

	func getJsonObject() throws -> [String: Any] {
		let fileContents = try String(contentsOfFile: Self.pactFilePath)
		guard
			let data = fileContents.data(using: .utf8),
			let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
		else {
			return [:]
		}
		return jsonObject
	}

}


private extension PactContractTests {
	
	static func getJsonObject(_ filename: String) throws -> [String: Any] {
		let fileContents = try String(contentsOfFile: filename)
		guard
			let data = fileContents.data(using: .utf8),
			let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
		else {
			return [:]
		}
		return jsonObject
	}

	static func fileExists(_ filename: String) -> Bool {
		FileManager.default.fileExists(atPath: filename)
	}

	static func removeFile(_ filename: String) {
		guard fileExists(filename) else { return }
		do {
			try FileManager.default.removeItem(at: URL(fileURLWithPath: filename))
		} catch {
			debugPrint("Could not remove file \(filename)")
		}
	}

}
