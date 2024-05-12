//
//  MatchNullTests.swift
//  PactSwift
//
//  Created by Marko Justinek on 9/10/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//

import XCTest

@testable import PactSwift

class MatchNullTests: XCTestCase {

	func testMatcher_MatchNull() throws {
		let matcherValue = try XCTUnwrap((Matcher.MatchNull().value as Any) as? String)
		XCTAssertEqual(matcherValue, "pact_matcher_null")

		let matcherRules = try XCTUnwrap(Matcher.MatchNull().rules.first)
		XCTAssertTrue(matcherRules.contains { key, value in
			key == "match"
		})
	}

	func testMatcher_MatchNull_SetsRules() throws {
		let sut = Matcher.MatchNull()
		let result = try MatcherTestHelpers.encodeDecode(sut.rules)

		XCTAssertEqual(result.first?.match, "null")
	}

}
