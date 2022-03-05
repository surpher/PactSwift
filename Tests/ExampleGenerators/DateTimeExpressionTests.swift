//
//  DateTimeExpressionTests.swift
//  PactSwift
//
//  Created by Marko Justinek on 5/3/22.
//  Copyright © 2022 Marko Justinek. All rights reserved.
//

import XCTest

@testable import PactSwift

class DateTimeExpressionTests: XCTestCase {

	func testDateTimeExpressionExampleGenerator() throws {
		let testDate = Date()
		let testFormat = "dd.MM.yyyy HH:mm:ss"
		let testExpression = "tomorrow 5pm"
		let sut = ExampleGenerator.DateTimeExpression(expression: testExpression, format: testFormat)

		XCTAssertEqual(sut.generator, .dateTime)

		let resultValue = try XCTUnwrap(sut.value as? String)
		let resultDate = try XCTUnwrap(DateHelper.dateFrom(string: resultValue, format: testFormat))

		XCTAssertEqual(testDate.formatted(testFormat), resultDate.formatted(testFormat))

		let attributes = try XCTUnwrap(sut.rules)
		XCTAssertTrue(attributes.contains { key, _ in
			key == "format"
		})

		XCTAssertTrue(attributes.contains(where: { key, _ in
			key == "expression"
		}))
	}

}
