//
//  Created by Marko Justinek on 3/4/2022.
//  Copyright © 2022 PACT Foundation. All rights reserved.
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

class EachKeyLikeTests: XCTestCase {

	func testMatcher_EachKeyLike_InitsWithStringValue() throws {
		let sut = try XCTUnwrap(Matcher.EachKeyLike("bar").value as? String)
		XCTAssertEqual(sut, "bar")
	}

	func testMatcher_EachKeyLike_InitsWithIntValue() throws {
		let sut = try XCTUnwrap(Matcher.EachKeyLike(123).value as? Int)
		XCTAssertEqual(sut, 123)
	}

}
