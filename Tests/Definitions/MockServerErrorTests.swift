//
//  Created by Marko Justinek on 25/5/20.
//  Copyright © 2020 Itty Bitty Apps Pty Ltd / PACT Foundation. All rights reserved.
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

class MockServerErrorTests: XCTestCase {

	func testFailedWithInvalidPactJSON() {
		let sut = MockServerError(code: -2)
		XCTAssertEqual(sut.description, "Mock Server Error: Pact JSON could not be parsed.")
	}

	func testFailedWithInvalidSocketAddress() {
		let sut = MockServerError(code: -5)
		XCTAssertEqual(sut.description, "Mock Server Error: Socket Address is invalid.")
	}

	func testFailedToStart() {
		let sut = MockServerError(code: -3)
		XCTAssertEqual(sut.description, "Mock Server Error: Could not start.")
	}

	func testFailedToWriteFile() {
		let sut = MockServerError(code: 2)
		XCTAssertEqual(sut.description, "Mock Server Error: Failed to write Pact contract to file.")
	}

	func testFailedWithMethodPanicked() {
		var sut = MockServerError(code: 1)
		XCTAssertEqual(sut.description, "Mock Server Error: PactMockServer's method panicked.")

		sut = MockServerError(code: -4)
		XCTAssertEqual(sut.description, "Mock Server Error: PactMockServer's method panicked.")
	}

	func testFailedWithNullPointer() {
		let sut = MockServerError(code: -1)
		XCTAssertEqual(sut.description, "Mock Server Error: Either Pact JSON or Socket Address passed as null pointer.")
	}

	func testFailedWithPortNotFound() {
		let sut = MockServerError(code: 3)
		XCTAssertEqual(sut.description, "Mock Server Error: Mock Server with specified port not running.")
	}

	func testFailedWithValidationFailure() {
		let sut = MockServerError(code: 999)
		XCTAssertEqual(sut.description, "Mock Server Error: Interactions failed to verify successfully. Check your tests.")
	}

	func testFailedWithUnknown() {
		let sut = MockServerError(code: 0)
		XCTAssertEqual(sut.description, "Mock Server Error: Reason unknown!")
	}

}
