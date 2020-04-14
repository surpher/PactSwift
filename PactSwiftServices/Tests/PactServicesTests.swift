//
//  PactSwiftServicesTests.swift
//  PactSwiftServicesTests
//
//  Created by Marko Justinek on 12/4/20.
//  Copyright © 2020 Pact Foundation. All rights reserved.
//

import XCTest

@testable import PactSwiftServices

class MockServerTests: XCTestCase {

	func testMockServer_ReturnsError_WhenNoPactProvided() {
		let mockServer = MockServer()
		let testResult = mockServer.setup(pact: "{\"foo\":\"bar\"}".data(using: .utf8)!)

		switch testResult {
		case .success(let port):
			XCTAssertTrue(port > 1200)
		default:
			XCTFail("Expected Pact Mock Server to start on a port greater than 1200")
		}
	}

}
