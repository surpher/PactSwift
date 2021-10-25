//
//  Created by Marko Justinek on 11/4/20.
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

class IntegerLikeTests: XCTestCase {

	func testMatcher_IntegerLike_InitsWithValue() throws {
		let testResult = try XCTUnwrap((Matcher.IntegerLike(1234).value as Any) as? Int)
		XCTAssertEqual(testResult, 1234)
	}

	func testMatcher_IntegerLike_SetsRules() throws {
		let sut = Matcher.IntegerLike(123)
		let result = try MatcherTestHelpers.encodeDecode(sut.rules)

		XCTAssertEqual(result.first?.match, "integer")
	}

}
