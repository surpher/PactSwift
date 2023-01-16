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

class MatcherEqualityTests: MatcherTestCase {
	
	func testMatcher_EqualityString_SerializesToJSON() throws {
		let json = try jsonString(for: .equals("test"))
		
		XCTAssertEqual(
			json,
			#"""
			{
			  "pact:matcher:type" : "equality",
			  "value" : "test"
			}
			"""#
		)
	}
	
	func testMatcher_EqualityInteger_SerializesToJSON() throws {
		let json = try jsonString(for: .equals(1234))
		
		XCTAssertEqual(
			json,
			#"""
			{
			  "pact:matcher:type" : "equality",
			  "value" : 1234
			}
			"""#
		)
	}
	
	func testMatcher_EqualityArray_SerializesToJSON() throws {
		let json = try jsonString(for: .equals(["one", "two"]))
		
		XCTAssertEqual(
			json,
			#"""
			{
			  "pact:matcher:type" : "equality",
			  "value" : [
			    "one",
			    "two"
			  ]
			}
			"""#
		)
	}

	func testMatcher_EmptyArray_SerializesToJSON() throws {
		// We discard whitespace lines here to work around issue where Xcode is causing whitespace issues in string literal below.
		let json = try jsonString(for: .emptyArray())
			.split(separator: "\n")
			.filter { $0.isEmpty == false }
			.joined(separator: "\n")

		XCTAssertEqual(
			json,
			#"""
			{
			  "pact:matcher:type" : "equality",
			  "value" : [
			  ]
			}
			"""#
		)
	}
}
