//
//  RegexLikeTests.swift
//  PactSwiftTests
//
//  Created by Marko Justinek on 11/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import XCTest

@testable import PactSwift

class RegexLikeTests: XCTestCase {

	func testMatcher_RegexLike_InitsWithValue() {
		do {
			let testResult = try XCTUnwrap((RegexLike("2020-11-04", term: "\\d{4}-\\d{2}-\\d{2}").value as Any) as? String)
			XCTAssertEqual(testResult, "2020-11-04")
		} catch {
			XCTFail("Failed to unwrap a RegexLike matcher's value")
		}
	}

}
