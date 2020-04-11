//
//  DecimalLikeTests.swift
//  PactSwiftTests
//
//  Created by Marko Justinek on 11/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
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
