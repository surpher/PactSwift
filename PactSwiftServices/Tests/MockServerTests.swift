//
//  MockServerTests.swift
//  PactSwiftServicesTests
//
//  Created by Marko Justinek on 12/4/20.
//  Copyright © 2020 Pact Foundation. All rights reserved.
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
		mockServer.setup(pact: "{\"foo\":\"bar\"}".data(using: .utf8)!) {
			switch $0 {
			case .success(let port):
				XCTAssertTrue(port > 1200)
			default:
				XCTFail("Expected Pact Mock Server to start on a port greater than 1200")
			}
		}
	}

	func testMockServer_SetsBaseURL_WithPort() {
		mockServer.setup(pact: "{\"foo\":\"bar\"}".data(using: .utf8)!) {
			switch $0 {
			case .success(let port):
				XCTAssertEqual(mockServer.baseUrl, "http://localhost:\(port)")
			default:
				XCTFail("Expected Pact Mock Server to start on a port greater than 1200")
			}
		}
	}

	func testMockServer_Fails_WithInvalidPactJSON() {
		mockServer.setup(pact: "{\"foo\":bar\"}".data(using: .utf8)!) {
			switch $0 {
			case .failure(let error):
				XCTAssertEqual(error, MockServerError.invalidPactJSON)
			default:
				XCTFail("Expected Pact Mock Server to fail")
			}
		}
	}

}
