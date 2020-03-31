//
//  MatcherTests.swift
//  PACTSwiftTests
//
//  Created by Marko Justinek on 31/3/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import XCTest

@testable import PACTSwift

class MatcherTests: XCTestCase {

	let jsonClass = "json_class"
	let contents = "contents"

	// MARK: - Type Matcher

	func testMatcher_SetsJSONClassForType() throws {
		let testResult = try XCTUnwrap(Matcher(SomethingLike("doesn't matter"))?.rule[jsonClass] as? String)
		XCTAssertEqual(testResult, "Pact::SomethingLike")
	}

	func testMatcher_SetsAtringContentsForType() throws {
		let testResult = try XCTUnwrap(Matcher(SomethingLike("aString"))?.rule[contents] as? String)
		XCTAssertEqual(testResult, "aString")
	}

	func testMatcher_SetsIntContentsForType() throws {
		let testResult = try XCTUnwrap(Matcher(SomethingLike(5))?.rule[contents] as? Int)
		XCTAssertEqual(testResult, 5)
	}

	func testMatcher_SetsDecimalContentsForType() throws {
		let testResult = try XCTUnwrap(Matcher(SomethingLike(Decimal(string: "1234.56")!))?.rule[contents] as? Decimal)
		XCTAssertEqual(testResult, Decimal(string:"1234.56"))
	}

	// MARK: - Each Like Matcher

	func testMatcher_SetsJSONClassForEachLike() throws {
		let testResult = try XCTUnwrap(Matcher(EachLike(value: ["Foo": "Bar"]))?.rule[jsonClass] as? String)
		XCTAssertEqual(testResult, "Pact::ArrayLike")
	}

	func testMatcher_SetsArrayLikeValueForEachLike() throws {
		let testResult = try XCTUnwrap(Matcher(EachLike(value: ["Foo": "Bar"]))?.rule[contents] as? NSDictionary)
		XCTAssertTrue(testResult.isEqual(to: ["Foo": "Bar"]))
	}

	func testMatcher_SetsDefaultMinValueForEachLike() throws {
		let testResult = try XCTUnwrap(Matcher(EachLike(value: ["Foo": "Bar"]))?.rule["min"] as? Int)
		XCTAssertEqual(testResult, 1)
	}

	func testMatcher_SetsProvidedMinValueForEachLike() throws {
		let testResult = try XCTUnwrap(Matcher(EachLike(value: ["Foo": "Bar"], min: 4))?.rule["min"] as? Int)
		XCTAssertEqual(testResult, 4)
	}

	// MARK: - Term Matcher

	func testMatcher_SetsJSONClassForExpression() throws {
		let testResult = try XCTUnwrap(Matcher(Expression(regex: #"\d{4}-\d{2}-\d{2}"#, generate: "2020-03-31"))?.rule[jsonClass] as? String)
		XCTAssertEqual(testResult, "Pact::Term")
	}

	func testMatcher_SetsValueToGenerateForExpression() throws {
		let testResult = try XCTUnwrap(Matcher(Expression(regex: #"\d{4}-\d{2}-\d{2}"#, generate: "2020-03-31"))?.rule["data"] as? [String: Any])["generate"] as? String
		XCTAssertEqual(testResult, "2020-03-31")
	}

	func testMatcher_SetsRegexForExpression() throws {
		let matcherResult = try XCTUnwrap(Matcher(Expression(regex: "\\d{4}-\\d{2}-\\d{2}", generate: "2020-03-31"))?.rule["data"] as? [String: Any])["matcher"] as? [String: Any]
		let testResult = try XCTUnwrap(matcherResult?["s"] as? String)
		XCTAssertEqual(testResult, "\\d{4}-\\d{2}-\\d{2}")
	}

}
