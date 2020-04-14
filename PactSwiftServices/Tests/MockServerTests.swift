//
//  MockServerTests.swift
//  PactSwiftServicesTests
//
//  Created by Marko Justinek on 12/4/20.
//  Copyright © 2020 Pact Foundation. All rights reserved.
//

import XCTest

@testable import PactSwiftServices

class MockServerTests: XCTestCase {

	var mockServer: MockServer!

	override func setUp() {
		super.setUp()
		mockServer = MockServer()
	}

	override func tearDown() {
		mockServer = nil
		super.tearDown()
	}

	// MARK: - Tests

	func testMockServer_Initializes() {
		let testResult = mockServer.setup(pact: "{\"foo\":\"bar\"}".data(using: .utf8)!)
		switch testResult {
		case .success(let port):
			XCTAssertTrue(port > 1200)
		default:
			XCTFail("Expected Pact Mock Server to start on a port greater than 1200")
		}
	}

	func testMockServer_SetsBaseURL_WithPort() {
		let testResult = mockServer.setup(pact: "{\"foo\":\"bar\"}".data(using: .utf8)!)
		switch testResult {
		case .success(let port):
			XCTAssertEqual(mockServer.baseUrl, "http://localhost:\(port)")
		default:
			XCTFail("Expected Pact Mock Server to start on a port greater than 1200")
		}
	}

	func testMockServer_Fails_WithInvalidPactJSON() {
		let testResult = mockServer.setup(pact: "{\"foo\":bar\"}".data(using: .utf8)!)
		switch testResult {
		case .failure(let error):
			XCTAssertEqual(error, MockServerError.invalidPactJSON)
		default:
			XCTFail("Expected Pact Mock Server to fail")
		}
	}

}
