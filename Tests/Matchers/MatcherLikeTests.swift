//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
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

class MatcherLikeTests: MatcherTestCase {

	func testMatcher_LikeEncodable_SerializesToJSON() throws {
		let json = try jsonString(for: .like(1234))
		
		XCTAssertEqual(
			json,
			#"""
			{
			  "pact:matcher:type" : "type",
			  "value" : 1234
			}
			"""#
		)
	}

	func testMatcher_LikeArrayEncodable_SerializesToJSON() throws {
		let json = try jsonString(for: .like([1234, 5678]))
		
		XCTAssertEqual(
			json,
			#"""
			{
			  "pact:matcher:type" : "type",
			  "value" : [
			    1234,
			    5678
			  ]
			}
			"""#
		)
	}
	
	func testMatcher_LikeArrayEncodableMin_SerializesToJSON() throws {
		let json = try jsonString(for: .like([1234, 5678], min: 1))
		
		XCTAssertEqual(
			json,
			#"""
			{
			  "min" : 1,
			  "pact:matcher:type" : "type",
			  "value" : [
			    1234,
			    5678
			  ]
			}
			"""#
		)
	}
	
	func testMatcher_LikeArrayEncodableMax_SerializesToJSON() throws {
		let json = try jsonString(for: .like([1234, 5678], max: 2))
		
		XCTAssertEqual(
			json,
			#"""
			{
			  "max" : 2,
			  "pact:matcher:type" : "type",
			  "value" : [
			    1234,
			    5678
			  ]
			}
			"""#
		)
	}
	
	func testMatcher_LikeArrayEncodableMinMax_SerializesToJSON() throws {
		let json = try jsonString(for: .like([1234, 5678], min: 1, max: 2))
		
		XCTAssertEqual(
			json,
			#"""
			{
			  "max" : 2,
			  "min" : 1,
			  "pact:matcher:type" : "type",
			  "value" : [
			    1234,
			    5678
			  ]
			}
			"""#
		)
	}
	
	func testMatcher_LikeDictionaryEncodable_SerializesToJSON() throws {
		let json = try jsonString(for: .like(["a": 1234, "b": 5678]))
		
		XCTAssertEqual(
			json,
			#"""
			{
			  "pact:matcher:type" : "type",
			  "value" : {
			    "a" : 1234,
			    "b" : 5678
			  }
			}
			"""#
		)
	}
	
	func testMatcher_LikeDictionaryAnyMatcher_SerializesToJSON() throws {
		let json = try jsonString(for: .like(["a": .integer(1234), "b": .equals(5678)]))
		
		XCTAssertEqual(
			json,
			#"""
			{
			  "pact:matcher:type" : "type",
			  "value" : {
			    "a" : {
			      "pact:matcher:type" : "integer",
			      "value" : 1234
			    },
			    "b" : {
			      "pact:matcher:type" : "equality",
			      "value" : 5678
			    }
			  }
			}
			"""#
		)
	}
	
}
