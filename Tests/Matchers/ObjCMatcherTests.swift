//
//  Created by Marko Justinek on 27/10/20.
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

class ObjCMatcherTests: XCTestCase {

	func testObjCMatcher_InitsWith_DecimalLike() throws {
		let testSubject = ObjcDecimalLike(value: Decimal(string: "42")!)

		XCTAssertTrue((testSubject.type as Any) is Matcher.DecimalLike)
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? Decimal), Decimal(string: "42")!)
	}

	func testObjCMatcher_InitsWith_EachLike() throws {
		var testSubject = ObjcEachLike(value: "foo")

		XCTAssertTrue((testSubject.type as Any) is Matcher.EachLike)
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? [String]), ["foo"])

		testSubject = ObjcEachLike(value: Int(1))
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? [Int]), [1])

		testSubject = ObjcEachLike(value: ["foo": "bar"])
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? [[String: String]]), [["foo": "bar"]])
	}

	func testObjCMatcher_InitsWith_EachLike_MinMax() throws {
		let testSubject = ObjcEachLike(value: "foo", min: 2, max: 9)

		XCTAssertTrue((testSubject.type as Any) is Matcher.EachLike)
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? [String]), ["foo", "foo"])
		XCTAssertEqual(try XCTUnwrap(testSubject.type as? Matcher.EachLike).min, 2)
		XCTAssertEqual(try XCTUnwrap(testSubject.type as? Matcher.EachLike).max, 9)
	}

	func testObjcMatcher_EachKeyLike() throws {
		var testSubject = ObjcEachKeyLike(value: "bar")
		XCTAssertEqual(try XCTUnwrap((testSubject.type as? Matcher.EachKeyLike)?.value as? String), "bar")

		testSubject = ObjcEachKeyLike(value: ["bar": 123])
		XCTAssertEqual(try XCTUnwrap((testSubject.type as? Matcher.EachKeyLike)?.value as? [String: Int]), ["bar": 123])
	}

	func testObjCMatcher_InitsWith_EqualTo() throws {
		var testSubject = ObjcEqualTo(value: "foo")

		XCTAssertTrue((testSubject.type as Any) is Matcher.EqualTo)
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? String), "foo")

		testSubject = ObjcEqualTo(value: 42)
		XCTAssertTrue((testSubject.type as Any) is Matcher.EqualTo)
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? Int), 42)
	}

	func testObjCMatcher_InitsWith_IncludesLikeAll() throws {
		let testSubject = ObjcIncludesLike(includesAll: ["foo", "bar"], generate: "This bar is totally foo")

		XCTAssertTrue((testSubject.type as Any) is Matcher.IncludesLike)
		XCTAssertEqual(try XCTUnwrap((testSubject.type as? Matcher.IncludesLike)?.combine), .AND)
		XCTAssertEqual(try XCTUnwrap((testSubject.type as? Matcher.IncludesLike)?.value as? String), "This bar is totally foo")
	}

	func testObjCMatcher_InitsWith_IncludesLikeAny() throws {
		let testSubject = ObjcIncludesLike(includesAny: ["foo", "bar"], generate: "This bar is totally foo")

		XCTAssertTrue((testSubject.type as Any) is Matcher.IncludesLike)
		XCTAssertEqual(try XCTUnwrap((testSubject.type as? Matcher.IncludesLike)?.combine), .OR)
		XCTAssertEqual(try XCTUnwrap((testSubject.type as? Matcher.IncludesLike)?.value as? String), "This bar is totally foo")
	}

	func testObjcMatcher_InitsWith_IntegerLike() throws {
		let testSubject = ObjcIntegerLike(value: 42)

		XCTAssertTrue((testSubject.type as Any) is Matcher.IntegerLike)
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? Int), 42)
	}

	func testObjcMatcher_InitsWith_MatchNull() {
		let testSubject = ObjcMatchNull()

		XCTAssertTrue((testSubject.type as Any) is Matcher.MatchNull)
	}

	func testObjcMatcher_InitsWith_RegexLike() {
		let testSubject = ObjcRegexLike(value: "31-01-2016", pattern: #"\d{2}-\d{2}-\d{4}"#)

		XCTAssertTrue((testSubject.type as Any) is Matcher.RegexLike)
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? String), "31-01-2016")
	}

	func testObjcMatcher_InitsWith_SomethingLike() {
		var testSubject = ObjcSomethingLike(value: "foo")

		XCTAssertTrue((testSubject.type as Any) is Matcher.SomethingLike)
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? String), "foo")

		testSubject = ObjcSomethingLike(value: 42)
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? Int), 42)
	}

	func testObjcMatcher_InitsWith_OneOf() {
		var testSubject = ObjcOneOf(values: [5, 1, 2, 3, 4])

		XCTAssertTrue((testSubject.type as Any) is Matcher.OneOf)
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? Int), 5)

		testSubject = ObjcOneOf(values: ["five", "one", "two", "three"])
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? String), "five")
	}

	func testObjcMatcher_FromProviderState_String() {
		let testSubject = ObjcFromProviderState(parameter: "testString", value: "string")

		XCTAssertTrue((testSubject.type as Any) is Matcher.FromProviderState)
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? String), "string")
	}

	func testObjcMatcher_FromProviderState_Int() {
		let testSubject = ObjcFromProviderState(parameter: "testInt", value: 666)

		XCTAssertTrue((testSubject.type as Any) is Matcher.FromProviderState)
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? Int), 666)
	}

	func testObjcMatcher_FromProviderState_Bool() {
		let testSubject = ObjcFromProviderState(parameter: "testBool", value: false)

		XCTAssertTrue((testSubject.type as Any) is Matcher.FromProviderState)
		XCTAssertFalse(try XCTUnwrap(testSubject.type.value as? Bool))
	}

	func testObjcMatcher_FromProviderState_Decimal() {
		let testSubject = ObjcFromProviderState(parameter: "testDecimal", value: Decimal(1234.56))

		XCTAssertTrue((testSubject.type as Any) is Matcher.FromProviderState)
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? Decimal), Decimal(1234.56))
	}

	func testObjcMatcher_FromProviderState_Float() {
		let testSubject = ObjcFromProviderState(parameter: "testFloat", value: Float(123.45))

		XCTAssertTrue((testSubject.type as Any) is Matcher.FromProviderState)
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? Float), 123.45, accuracy: 0.0001)
	}

	func testObjcMatcher_FromProviderState_Double() {
		let testSubject = ObjcFromProviderState(parameter: "testDouble", value: Double(123.45))

		XCTAssertTrue((testSubject.type as Any) is Matcher.FromProviderState)
		XCTAssertEqual(try XCTUnwrap(testSubject.type.value as? Double), 123.45)
	}

}
