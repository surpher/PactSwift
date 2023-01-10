//
//  Created by Marko Justinek on 18/9/20.
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

class MatcherRandomDateTimeTests: MatcherTestCase {

	func testRandomDate_SerializesToJSON() throws {
		let json = try jsonString(for: .randomDate("2023-01-09", format: "yyyy-MM-dd", expression: "today"))
		
		XCTAssertEqual(
			json,
			#"""
			{
			  "expression" : "today",
			  "format" : "yyyy-MM-dd",
			  "pact:generator:type" : "Date",
			  "pact:matcher:type" : "type",
			  "value" : "2023-01-09"
			}
			"""#
		)
	}
	
	func testRandomTime_SerializesToJSON() throws {
		let json = try jsonString(for: .randomDate("14:34:12", format: "HH:mm:ss", expression: "today"))
		
		XCTAssertEqual(
			json,
			#"""
			{
			  "expression" : "today",
			  "format" : "HH:mm:ss",
			  "pact:generator:type" : "Date",
			  "pact:matcher:type" : "type",
			  "value" : "14:34:12"
			}
			"""#
		)
	}
	
	func testRandomDatetime_SerializesToJSON() throws {
		let json = try jsonString(for: .randomDatetime("2023-01-09 14:34:12", format: "yyyy-MM-dd HH:mm:ss", expression: "today"))
		
		XCTAssertEqual(
			json,
			#"""
			{
			  "expression" : "today",
			  "format" : "yyyy-MM-dd HH:mm:ss",
			  "pact:generator:type" : "DateTime",
			  "pact:matcher:type" : "type",
			  "value" : "2023-01-09 14:34:12"
			}
			"""#
		)
	}
}
