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
		let testFormat = "dd.MM.yyyy HH:mm:ss"
		let testExpression = "tomorrow 5pm"
		let sut = ExampleGenerator.DateTimeExpression(expression: testExpression, format: testFormat)

		XCTAssertEqual(sut.generator, .dateTime)

		let attributes = try XCTUnwrap(sut.rules)
		XCTAssertTrue(
			["format", "expression"].allSatisfy { keyValue in
				attributes.contains { key, _ in
					key == keyValue
				}
			}
		)
	}

}
