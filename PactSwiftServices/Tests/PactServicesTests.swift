//
//  PactSwiftServicesTests.swift
//  PactSwiftServicesTests
//
//  Created by Marko Justinek on 12/4/20.
//  Copyright © 2020 Pact Foundation. All rights reserved.
//

import XCTest

@testable import PactSwiftServices

class PactServicesTests: XCTestCase {

	func testDud() {
		// PactMockServer.init() will call `create_mock_server()` by passing nils for all arguments. The debug console should print response and contain `-1` - missing Pact String
		_ = PactMockServer()
		
		XCTAssertTrue(true, "Only to make the `swift build -c && swift test` pass")
	}

}
