//
//  Created by Marko Justinek on 16/9/20.
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

class RandomUUIDTests: XCTestCase {

	func testRandomUUIDExampleGenerator() throws {
		let sut = ExampleGenerator.RandomUUID()

		XCTAssertNotNil(UUID(uuidString: try XCTUnwrap(sut.value as? String)))
		XCTAssertEqual(sut.generator, .uuid)
		XCTAssertNotNil(sut.rules)
	}

	func testRandomUUIDDefaultFormat() throws {
		let sut = ExampleGenerator.RandomUUID()
		let result = try ExampleGeneratorTestHelpers.encodeDecode(sut.rules!)

		XCTAssertEqual(result.format, "upper-case-hyphenated")
	}

	func testRandomUUIDUpperCaseHyphenatedFormat() throws {
		let sut = ExampleGenerator.RandomUUID()
		let result = try ExampleGeneratorTestHelpers.encodeDecode(sut.rules!)

		XCTAssertEqual(result.format, "upper-case-hyphenated")
	}

	func testRandomUUIDSimpleFormat() throws {
		let sut = ExampleGenerator.RandomUUID(format: .simple)
		let result = try ExampleGeneratorTestHelpers.encodeDecode(sut.rules!)

		XCTAssertEqual(result.format, "simple")
	}

	func testRandomUUIDLowerCaseHyphenatedFormat() throws {
		let sut = ExampleGenerator.RandomUUID(format: .lowercaseHyphenated)
		let result = try ExampleGeneratorTestHelpers.encodeDecode(sut.rules!)

		XCTAssertEqual(result.format, "lower-case-hyphenated")
	}

	func testRandomUUIDURNFormat() throws {
		let sut = ExampleGenerator.RandomUUID(format: .urn)
		let result = try ExampleGeneratorTestHelpers.encodeDecode(sut.rules!)

		XCTAssertEqual(result.format, "URN")
	}

}
