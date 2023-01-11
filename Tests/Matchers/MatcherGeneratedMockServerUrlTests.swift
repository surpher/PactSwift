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

class MatcherGeneratedMockServerUrlTests: MatcherTestCase {

	func testGeneratedMockServerUrl_SerializesToJSON() throws {
		let json = try jsonString(for: .generatedMockServerUrl(example: "https://example.com/orders/1234", regex: #".*(/orders/\d+)$"#))

		XCTAssertEqual(
			json,
			#"""
			{
			  "example" : "https://example.com/orders/1234",
			  "pact:generator:type" : "MockServerURL",
			  "pact:matcher:type" : "type",
			  "regex" : ".*(/orders/\\d+)$",
			  "value" : "https://example.com/orders/1234"
			}
			"""#
		)
	}
}
