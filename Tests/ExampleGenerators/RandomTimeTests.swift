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

class RandomTimeTests: XCTestCase {

	func testRandomTime() throws {
		let sut = ExampleGenerator.RandomTime()

		XCTAssertEqual(sut.generator, .time)
		XCTAssertNil(sut.rules)
		let isoTime = try XCTUnwrap(sut.value as? String)
		XCTAssertNotNil(DateHelper.dateFrom(isoString: isoTime, isoFormat: [.withFullTime]))
	}

	func testRandomTime_WithFormat() throws {
		let testFormat = "HH:mm"
		let sut = ExampleGenerator.RandomTime(format: testFormat)

		let attributes = try XCTUnwrap(sut.rules)
		XCTAssertTrue(attributes.contains { key, _ in
			key == "format"
		})
		XCTAssertEqual(sut.generator, .time)
		XCTAssertNotNil(DateHelper.dateFrom(string: try XCTUnwrap(sut.value as? String), format: testFormat))
	}

	func testRandomTime_SetsRules() throws {
		let testFormat = "HH:mm"
		let sut = ExampleGenerator.RandomTime(format: testFormat)
		let result = try ExampleGeneratorTestHelpers.encodeDecode(sut.rules!)

		XCTAssertEqual(result.format, testFormat)
	}

}
