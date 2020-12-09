//
//  Created by Marko Justinek on 17/9/20.
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

class RandomHexadecimalTests: XCTestCase {

	func testRandomHexadecimal() throws {
		let sut = ExampleGenerator.RandomHexadecimal()

		XCTAssertEqual(sut.generator, .hexadecimal)

		let attributes = try XCTUnwrap(sut.rules)
		XCTAssertTrue(attributes.contains { key, _ in
			key == "digits"
		})

		let hexValue = try XCTUnwrap(sut.value as? String)
		XCTAssertEqual(hexValue.count, 8)
	}

	func testRandomHexadecimal_WithDigits() throws {
		let sut = ExampleGenerator.RandomHexadecimal(digits: 16)

		XCTAssertEqual(sut.generator, .hexadecimal)

		let attributes = try XCTUnwrap(sut.rules)
		XCTAssertTrue(attributes.contains { key, _ in
			key == "digits"
		})

		let hexValue = try XCTUnwrap(sut.value as? String)
		XCTAssertEqual(hexValue.count, 16)
	}

}
