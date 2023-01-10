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

class MatcherRandomUUIDTests: MatcherTestCase {

	func testRandomUUID_SerializesToJSON() throws {
		let uuid = UUID()
		let json = try jsonString(for: .randomUUID(uuid))
		
		XCTAssertEqual(
			json,
			"""
			{
			  "format" : "upper-case-hyphenated",
			  "pact:generator:type" : "Uuid",
			  "pact:matcher:type" : "type",
			  "value" : "\(uuid.uuidString)"
			}
			"""
		)
	}
	
	func testRandomUUIDWithFormat_SerializesToJSON() throws {
		let json = try jsonString(for: .randomUUID("936DA01f9abd4d9d80c702af85c822a8", format: .simple))
		
		XCTAssertEqual(
			json,
			"""
			{
			  "format" : "simple",
			  "pact:generator:type" : "Uuid",
			  "pact:matcher:type" : "type",
			  "value" : "936DA01f9abd4d9d80c702af85c822a8"
			}
			"""
		)
	}
}
