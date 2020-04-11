//
//  MatchIntegerTests.swift
//  PactSwiftTests
//
//  Created by Marko Justinek on 11/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import XCTest

@testable import PactSwift

class IntegerLikeTests: XCTestCase {

	func testMatcher_IntegerLike_InitsWithValue() {
		do {
			let testResult = try XCTUnwrap((IntegerLike(1234).value as Any) as? Int)
			XCTAssertEqual(testResult, 1234)
		} catch {
			XCTFail("Failed to unwrap a IntegerLike matcher's value")
		}
	}

}
