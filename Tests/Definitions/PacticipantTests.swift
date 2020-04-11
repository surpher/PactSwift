//
//  PacticipantTests.swift
//  PactSwiftTests
//
//  Created by Marko Justinek on 1/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import XCTest

@testable import PactSwift

class PacticipantTests: XCTestCase {

	func testPacticipant_ReturnsConsumerName() {
		XCTAssertEqual(Pacticipant.consumer("test_consumer").name, "test_consumer")
	}

	func testPacticipant_ReturnsProviderName() {
		XCTAssertEqual(Pacticipant.provider("test_provider").name, "test_provider")
	}

}
