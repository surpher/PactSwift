//
//  Created by Marko Justinek on 17/9/20.
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

class RandomDateTests: XCTestCase {

	func testRandomDate() {
		let sut = ExampleGenerator.RandomDate()

		XCTAssertEqual(sut.generator, .date)
		XCTAssertNil(sut.rules)
		XCTAssertNotNil(DateHelper.dateFrom(isoString: try XCTUnwrap(sut.value as? String), isoFormat: [.withFullDate, .withDashSeparatorInDate]))
	}

	func testRandomDate_WithFormat() throws {
		let testFormat = "dd-MM-yyyy"
		let sut = ExampleGenerator.RandomDate(format: testFormat)

		let attributes = try XCTUnwrap(sut.rules)
		XCTAssertTrue(attributes.contains { key, _ in
			key == "format"
		})
		XCTAssertEqual(sut.generator, .date)
		XCTAssertNotNil(DateHelper.dateFrom(string: try XCTUnwrap(sut.value as? String), format: testFormat))
	}

}
