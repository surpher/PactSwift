//
//  DecimalLikeTests.swift
//  PactSwiftTests
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

class DecimalLikeTests: XCTestCase {

	func testMatcher_DecimalLike_InitsWithValue() {
		do {
			let testResult = try XCTUnwrap((DecimalLike(1234).value as Any) as? Decimal)
			XCTAssertEqual(testResult, 1234)

			let testDecimalResult = try XCTUnwrap((DecimalLike(1234.56).value as Any) as? Decimal)
			XCTAssertEqual(testDecimalResult, 1234.56)
		} catch {
			XCTFail("Failed to unwrap a DecimalLike matcher's value")
		}
	}

}
