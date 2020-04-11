//
//  SomethingLikeTests.swift
//  PactSwiftTests
//
//  Created by Marko Justinek on 11/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import XCTest

@testable import PactSwift

class SomethingLikeTests: XCTestCase {

	func testMatcher_SomethingLike_InitsWithValue() {
		XCTAssertEqual(try XCTUnwrap((SomethingLike("TestString").value as Any) as? String), "TestString")
		XCTAssertEqual(try XCTUnwrap((SomethingLike(200).value as Any) as? Int), 200)
		XCTAssertEqual(try XCTUnwrap((SomethingLike(123.45).value as Any) as? Double), 123.45)

		do {
			let dictResult = try XCTUnwrap((SomethingLike(["foo": "bar"]).value as Any) as? [String: String])
			XCTAssertEqual(dictResult["foo"], "bar")

			let testArray = [1, 3, 2]
			let arrayResult = try XCTUnwrap((SomethingLike([1, 2, 3]).value as Any) as? [Int])
			XCTAssertEqual(arrayResult.count, 3)
			XCTAssertTrue(arrayResult.allSatisfy { testArray.contains($0) })
		} catch {
			XCTFail("Failed to unwrap a SomethingLike matcher's value")
		}
	}

}
