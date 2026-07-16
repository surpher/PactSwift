//
//  Created by José Jeria on 8/7/2026.
//  Copyright © 2026 José Jeria. All rights reserved.
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

class MatcherArrayContainsTests: MatcherTestCase {

	func testMatcher_ArrayContainsObjectVariants_SerializesToJSON() throws {
		let json = try jsonString(
			for: .arrayContains([
				[
					"name": .regex("add\\-item", example: "add-item"),
					"method": .regex("POST", example: "POST"),
				],
				[
					"name": .regex("delete\\-item", example: "delete-item"),
					"method": .regex("DELETE", example: "DELETE"),
				],
			])
		)

		XCTAssertEqual(
			json,
			#"""
			{
			  "pact:matcher:type" : "arrayContains",
			  "variants" : [
			    {
			      "method" : {
			        "pact:matcher:type" : "regex",
			        "regex" : "POST",
			        "value" : "POST"
			      },
			      "name" : {
			        "pact:matcher:type" : "regex",
			        "regex" : "add\\-item",
			        "value" : "add-item"
			      }
			    },
			    {
			      "method" : {
			        "pact:matcher:type" : "regex",
			        "regex" : "DELETE",
			        "value" : "DELETE"
			      },
			      "name" : {
			        "pact:matcher:type" : "regex",
			        "regex" : "delete\\-item",
			        "value" : "delete-item"
			      }
			    }
			  ]
			}
			"""#
		)
	}

	func testMatcher_ArrayContainsScalarVariants_SerializesToJSON() throws {
		let json = try jsonString(
			for: .arrayContains([.equals("Thing1"), .equals("Thing2")])
		)

		XCTAssertEqual(
			json,
			#"""
			{
			  "pact:matcher:type" : "arrayContains",
			  "variants" : [
			    {
			      "pact:matcher:type" : "equality",
			      "value" : "Thing1"
			    },
			    {
			      "pact:matcher:type" : "equality",
			      "value" : "Thing2"
			    }
			  ]
			}
			"""#
		)
	}

	func testMatcher_ArrayContainsEmptyVariants_SerializesToJSON() throws {
		let json = try jsonString(for: .arrayContains([AnyMatcher]()))

		XCTAssertEqual(
			json,
			#"""
			{
			  "pact:matcher:type" : "arrayContains",
			  "variants" : [

			  ]
			}
			"""#
		)
	}

}
