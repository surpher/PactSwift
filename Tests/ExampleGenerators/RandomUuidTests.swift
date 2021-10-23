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
		XCTAssertNil(sut.rules)
	}

	func testSimpleRandomUUIDExampleGenerator() throws {
		let sut = ExampleGenerator.RandomUUID(format: .simple)

		let uuid = try XCTUnwrap(sut.value as? String)
		XCTAssertEqual(uuid.count, 32)
		XCTAssert(uuid.allSatisfy {
			$0.isNumber || $0.isASCIILetter
		})
	}

	func testLowercaseHyphenatedRandomUUIDExampleGenerator() throws {
		let sut = ExampleGenerator.RandomUUID(format: .lowercaseHyphenated)

		let uuid = try XCTUnwrap(sut.value as? String)
		XCTAssertEqual(uuid.count, 36)
		XCTAssert(uuid.allSatisfy {
			$0 == "-" || $0.isNumber || $0.isASCIILetter && $0.isLowercase
		})
	}

	func testUppercaseHyphenatedRandomUUIDExampleGenerator() throws {
		let sut = ExampleGenerator.RandomUUID(format: .uppercaseHyphenated)

		let uuid = try XCTUnwrap(sut.value as? String)
		XCTAssertEqual(uuid.count, 36)
		XCTAssert(uuid.allSatisfy {
			$0 == "-" || $0.isNumber || $0.isASCIILetter && $0.isUppercase
		})
	}

	func testURNRandomUUIDExampleGenerator() throws {
		let sut = ExampleGenerator.RandomUUID(format: .urn)

		let urn = try XCTUnwrap(sut.value as? String)
		XCTAssertEqual(urn.prefix(9), "urn:uuid:")
		let uuid = urn.dropFirst(9)
		XCTAssertEqual(uuid.count, 36)
		XCTAssert(uuid.allSatisfy {
			$0 == "-" || $0.isNumber || $0.isASCIILetter && $0.isLowercase
		})
	}

	func testSimpleUUID() {
		let sut = UUID()
		XCTAssertEqual(sut.uuidString.count, 36)
		XCTAssertEqual(sut.uuidStringSimple.count, 32)
	}
}

private extension Character {
	var isASCIILetter: Bool {
		isASCII && isLetter
	}
}
