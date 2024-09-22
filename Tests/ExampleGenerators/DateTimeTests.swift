//
//  DateTimeTests.swift
//  PactSwift
//
//  Created by Marko Justinek on 13/2/22.
//  Copyright © 2022 Marko Justinek. All rights reserved.
//

import XCTest

@testable import PactSwift

class DateTimeTests: XCTestCase {

	func testDateTimeExampleGenerator() throws {
		let testDate = Date()
		let testFormat = "YYYY-MM-DD HH:mm"
		let sut = ExampleGenerator.DateTime(format: testFormat, use: testDate)

		XCTAssertEqual(sut.generator, .dateTime)

		let resultValue = try XCTUnwrap(sut.value as? String)
		let resultDate = try XCTUnwrap(DateHelper.dateFrom(string: resultValue, format: testFormat))
		// Assert using the same format due to loss of accuracy using a limited datetime format
		XCTAssertEqual(testDate.formatted(testFormat), resultDate.formatted(testFormat))

		let attributes = try XCTUnwrap(sut.rules)
		XCTAssertTrue(attributes.contains { key, _ in
			key == "format"
		})

		let resultFormat = try ExampleGeneratorTestHelpers.encodeDecode(sut.rules!)
		XCTAssertEqual(resultFormat.format, testFormat)
	}

}
