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

class EachLikeTests: XCTestCase {

	func testMatcher_EachLike_InitsWithValue() throws {
		// Array of Strings
		let testStringResult = try XCTUnwrap(Matcher.EachLike("foo").value as? [String])
		XCTAssertEqual(testStringResult, ["foo"])

		// Array of Ints
		let testIntResult = try XCTUnwrap(Matcher.EachLike(12345).value as? [Int])
		XCTAssertEqual(testIntResult, [12345])

		// Array of Dictionaries
		let testDictResult = try XCTUnwrap((Matcher.EachLike(["foo": 123.45]).value as? [[String: Double]])?.first)
		XCTAssertEqual(testDictResult["foo"], 123.45)
	}

	func testMatcher_EachLike_InitsWithDefault_MinValue() throws {
		// Array of Strings
		let testResult = try XCTUnwrap(Matcher.EachLike("foo").min)
		XCTAssertEqual(testResult, 1)
	}

	func testMatcher_EachLike_InitsWithProvided_MinValue() throws {
		// Array of Strings
		let testResult = try XCTUnwrap(Matcher.EachLike("foo", min: 99).min)
		XCTAssertEqual(testResult, 99)
	}

	func testMatcher_EachLike_InitsWithout_MaxValue() {
		XCTAssertNil(Matcher.EachLike("foo").max)
	}

	func testMatcher_EachLike_InitsWithProvided_MaxValue() throws {
		// Array of Strings
		let testResult = try XCTUnwrap(Matcher.EachLike("foo", max: 5).max)
		XCTAssertEqual(testResult, 5)
	}

	func testMatcher_EachLike_InitsWithMinAndMaxValue() throws {
		// Array of Strings
		let testResult = try XCTUnwrap(Matcher.EachLike("foo", min: 1, max: 5))
		XCTAssertEqual(testResult.min, 1)
		XCTAssertEqual(testResult.max, 5)
	}

	func testMatcher_EachLike_InitsWithCount() throws {
		// Array of count
		let testResult = try XCTUnwrap(Matcher.EachLike("foo", count: 3).value as? [String])
		XCTAssertEqual(testResult.count, 3)
	}

	func testMatcher_EachLike_SetsMinMaxRules() throws {
		let sut = Matcher.EachLike("test", min: 0, max: 666, count: 123)
		let result = try MatcherTestHelpers.encodeDecode(sut.rules)

		XCTAssertTrue(result.contains {
			$0.match == "type" && $0.min == 0 && $0.max == 666
		})
	}

	func testMatcher_EachLike_SetsDefaultMinParametersRules() throws {
		let sut = Matcher.EachLike("test")
		let result = try MatcherTestHelpers.encodeDecode(sut.rules)

		XCTAssertTrue(result.contains { $0.match == "type" && $0.min == 1})
		XCTAssertFalse(result.first(where: { $0.max != nil }) != nil)
	}

	func testMatcher_EachLike_OmitsMaxParametersRules() throws {
		let sut = Matcher.EachLike("test", min: 5)
		let result = try MatcherTestHelpers.encodeDecode(sut.rules)

		XCTAssertTrue(result.contains { $0.match == "type" && $0.min == 5})
		XCTAssertFalse(result.first(where: { $0.max != nil }) != nil)
	}

	func testMatcher_EachLike_OmitsDefaultMinParametersRules() throws {
		let sut = Matcher.EachLike("test", max: 10)
		let result = try MatcherTestHelpers.encodeDecode(sut.rules)

		XCTAssertTrue(result.contains { $0.match == "type" && $0.max == 10})
		XCTAssertFalse(result.first(where: { $0.min != nil }) != nil)
	}

	func testMatcher_EachLike_HandlesBogusMinMax() throws {
		let sut = Matcher.EachLike("test", min: 5, max: 3)
		let result = try MatcherTestHelpers.encodeDecode(sut.rules)

		XCTAssertTrue(result.contains { $0.match == "type" && $0.min == 3 && $0.max == 5 })
	}

}
