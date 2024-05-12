//
//  Created by Marko Justinek on 18/9/20.
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

class RandomStringTests: XCTestCase {

	func testRandomString() throws {
		let sut = ExampleGenerator.RandomString()

		let attributes = try XCTUnwrap(sut.rules)
		XCTAssertTrue(attributes.contains { key, _ in
			key == "size"
		})
		XCTAssertEqual(sut.generator, .string)
		let stringValue = try XCTUnwrap(sut.value as? String)
		XCTAssertEqual(stringValue.count, 20)
	}

	func testRandomString_WithSize() throws {
		let sut = ExampleGenerator.RandomString(size: 1145)

		let attributes = try XCTUnwrap(sut.rules)
		XCTAssertTrue(attributes.contains { key, _ in
			key == "size"
		})
		XCTAssertEqual(sut.generator, .string)
		let stringValue = try XCTUnwrap(sut.value as? String)
		XCTAssertEqual(stringValue.count, 1145)
	}

	func testRandomRegex() throws {
		let sut = ExampleGenerator.RandomString(regex: #"\d{1,2}/\d{1,2}"#)

		let attributes = try XCTUnwrap(sut.rules)
		XCTAssertTrue(attributes.contains { key, _ in
			key == "regex"
		})

		XCTAssertEqual(sut.generator, .regex)
	}

	func testRandomString_SetsSizeRules() throws {
		let sut = ExampleGenerator.RandomString(size: 20)
		let result = try ExampleGeneratorTestHelpers.encodeDecode(sut.rules!)

		XCTAssertEqual(result.size, 20)
	}

	func testRandomString_SetsRegexRules() throws {
		let regex = #"\d{1,2}/\d{1,2}"#
		let sut = ExampleGenerator.RandomString(regex: regex)
		let result = try ExampleGeneratorTestHelpers.encodeDecode(sut.rules!)

		XCTAssertEqual(result.regex, regex)
	}

}
