//
//  MockServiceTests.swift
//  PactSwiftTests
//
//  Created by Marko Justinek on 15/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import XCTest

@testable import PactSwift

class MockServiceTests: XCTestCase {

	func testDud() {
		let mockService = MockService(consumer: "consumer-app", provider: "api-provider")

		_ = mockService
			.uponReceiving("Request for alligators")
			.given("alligators exist")

	}

}
