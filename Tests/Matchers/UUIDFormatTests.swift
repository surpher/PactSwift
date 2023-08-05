//
//  Created by Oliver Jones on 16/1/2023.
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

@available(macOS 13, *)
class UUIDFormatTests: XCTestCase {
	func testExampleMatchesRegex() throws {
		for format in UUIDFormat.allCases {
			let regex = try Regex(format.matchingRegex)
			let match = try XCTUnwrap(format.example.wholeMatch(of: regex))
			XCTAssertFalse(match.isEmpty)
		}
	}

	func testExampleMatchesRegex_Negative() throws {
		for format in UUIDFormat.allCases {
			let regex = try Regex(format.matchingRegex)
			let match = "not a uuid".wholeMatch(of: regex)
			XCTAssertNil(match)
		}
	}
}
