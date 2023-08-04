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

class ObjCExampleGeneratorTests: XCTestCase {

	func testObjCExampleGenerator_InitsWith_RandomBool() {
		let testSubject = ObjcRandomBool()

		XCTAssertTrue((testSubject.type as Any) is ExampleGenerator.RandomBool)
	}

	func testObjCExampleGenerator_InitsWith_RandomDate() throws {
		let testSubject = ObjcRandomDate(format: "MM-YYYY")

		XCTAssertTrue((testSubject.type as Any) is ExampleGenerator.RandomDate)
		XCTAssertEqual(testSubject.type.generator, .date)
	}

	func testObjCExampleGenerator_InitsWith_DateTime() {
		let testSubject = ObjcRandomDateTime()

		XCTAssertTrue((testSubject.type as Any) is ExampleGenerator.RandomDateTime)
		XCTAssertEqual(testSubject.type.generator, .dateTime)
	}

	func testObjCExampleGenerators_InitsWith_Decimal() {
		let testSubject = ObjcRandomDecimal(digits: 4)

		XCTAssertTrue((testSubject.type as Any) is ExampleGenerator.RandomDecimal)
	}

	func testObjCExampleGenerators_InitsWith_Hexadecimal() {
		let testSubject = ObjcRandomHexadecimal(digits: 7)

		XCTAssertTrue((testSubject.type as Any) is ExampleGenerator.RandomHexadecimal)
	}

	func testObjCExampleGenerators_InitsWith_Int() {
		var testSubject = ObjcRandomInt(min: 1, max: 256)
		testSubject = ObjcRandomInt()
		XCTAssertTrue((testSubject.type as Any) is ExampleGenerator.RandomInt)
	}

	func testObjCExampleGenerators_InitsWith_RandomString() {
		let testSubject = ObjcRandomString(size: 10)

		XCTAssertTrue((testSubject.type as Any) is ExampleGenerator.RandomString)
	}

	func testObjCExampleGenerators_InitsWith_RandomRegexString() {
		let testSubject = ObjcRandomString(regex: #"\{d}2"#)

		XCTAssertTrue((testSubject.type as Any) is ExampleGenerator.RandomString)
	}

	func testObjCExampleGenerators_InitsWith_RandomTime() {
		let testSubject = ObjcRandomTime(format: #"MM-YYYY"#)

		XCTAssertTrue((testSubject.type as Any) is ExampleGenerator.RandomTime)
	}

	func testObjCExampleGenerators_InitsWith_RandomUUID() {
		let testSubject = ObjcRandomUUID()

		XCTAssertTrue((testSubject.type as Any) is ExampleGenerator.RandomUUID)
	}

	func testObjCExampleGenerators_InitsWith_RandomUUIDFormat() {
		let testSubject = ObjcRandomUUID(format: .uppercaseHyphenated)

		XCTAssertTrue((testSubject.type as Any) is ExampleGenerator.RandomUUID)
	}

}
