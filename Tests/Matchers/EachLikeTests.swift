//
//  EachLikeTests.swift
//  PactSwiftTests
//
//  Created by Marko Justinek on 11/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import XCTest

@testable import PactSwift

class EachLikeTests: XCTestCase {

	func testMatcher_EachLike_InitsWithValue() {
		do {
			// Array of Strings
			let testStringResult = try XCTUnwrap(EachLike("foo").value as? [String])
			XCTAssertEqual(testStringResult, ["foo"])

			// Array of Ints
			let testIntResult = try XCTUnwrap(EachLike(12345).value as? [Int])
			XCTAssertEqual(testIntResult, [12345])

			// Array of Dictionaries
			let testDictResult = try XCTUnwrap((EachLike(["foo": 123.45]).value as? [[String: Double]])?.first)
			XCTAssertEqual(testDictResult["foo"], 123.45)
		} catch {
			XCTFail("Failed to unwrap a EachLike matcher's value")
		}
	}

	func testMatcher_EachLike_InitsWithDefault_MinValue() {
		do {
			// Array of Strings
			let testResult = try XCTUnwrap(EachLike("foo").min)
			XCTAssertEqual(testResult, 1)
		} catch {
			XCTFail("Failed to unwrap a EachLike matcher's value")
		}
	}

	func testMatcher_EachLike_InitsWithProvided_MinValue() {
		do {
			// Array of Strings
			let testResult = try XCTUnwrap(EachLike("foo", min: 99).min)
			XCTAssertEqual(testResult, 99)
		} catch {
			XCTFail("Failed to unwrap a EachLike matcher's value")
		}
	}

	func testMatcher_EachLike_InitsWithout_MaxValue() {
		XCTAssertNil(EachLike("foo").max)
	}

	func testMatcher_EachLike_InitsWithProvided_MaxValue() {
		do {
			// Array of Strings
			let testResult = try XCTUnwrap(EachLike("foo", max: 5).max)
			XCTAssertEqual(testResult, 5)
		} catch {
			XCTFail("Failed to unwrap a EachLike matcher's value")
		}
	}

	func testMatcher_EachLike_InitsWithMinAndMaxValue() {
		do {
			// Array of Strings
			let testResult = try XCTUnwrap(EachLike("foo", min: 1, max: 5))
			XCTAssertEqual(testResult.min, 1)
			XCTAssertEqual(testResult.max, 5)
		} catch {
			XCTFail("Failed to unwrap a EachLike matcher's value")
		}
	}

}
