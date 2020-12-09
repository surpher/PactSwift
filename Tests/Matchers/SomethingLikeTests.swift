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

class SomethingLikeTests: XCTestCase {

	func testMatcher_SomethingLike_InitsWithValue() throws {
		XCTAssertEqual(try XCTUnwrap((Matcher.SomethingLike("TestString").value as Any) as? String), "TestString")
		XCTAssertEqual(try XCTUnwrap((Matcher.SomethingLike(200).value as Any) as? Int), 200)
		XCTAssertEqual(try XCTUnwrap((Matcher.SomethingLike(123.45).value as Any) as? Double), 123.45)

		let dictResult = try XCTUnwrap((Matcher.SomethingLike(["foo": "bar"]).value as Any) as? [String: String])
		XCTAssertEqual(dictResult["foo"], "bar")

		let testArray = [1, 3, 2]
		let arrayResult = try XCTUnwrap((Matcher.SomethingLike([1, 2, 3]).value as Any) as? [Int])
		XCTAssertEqual(arrayResult.count, 3)
		XCTAssertTrue(arrayResult.allSatisfy { testArray.contains($0) })
	}

}
