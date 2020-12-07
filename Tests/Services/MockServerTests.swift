//
//  Created by Marko Justinek on 12/4/20.
//  Copyright © 2020 Itty Bitty Apps Pty Ltd / Pact Foundation. All rights reserved.
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

class MockServerTests: XCTestCase {

	var mockServer: MockServer!
	var secureProtocol: Bool = false

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

	func testMockServer_InitializesWithPort() {
		let mockServer = MockServer(port: 1235)
		XCTAssertEqual(mockServer.baseUrl, "http://0.0.0.0:1235")
	}

	func testMockServer_SetsBaseURL_WithPort() {
		mockServer.setup(pact: "{\"foo\":\"bar\"}".data(using: .utf8)!) {
			switch $0 {
			case .success(let port):
				XCTAssertEqual(mockServer.baseUrl, "http://0.0.0.0:\(port)")
			default:
				XCTFail("Expected Pact Mock Server to start on a port greater than 1200")
			}
		}
	}

	func testMockServer_SetsBaseSSLURL_WithPort() {
		secureProtocol = true
		mockServer.setup(pact: "{\"foo\":\"bar\"}".data(using: .utf8)!, protocol: .secure) {
			switch $0 {
			case .success(let port):
				XCTAssertEqual(mockServer.baseUrl, "https://0.0.0.0:\(port)")
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

	func test_MOCK_SERVER_SANITY_TEST_TLS() {
		let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main)
		let dataTaskExpectation = expectation(description: "dataTask")
		secureProtocol = true

		mockServer.setup(pact: pactSpecV3.data(using: .utf8)!, protocol: .secure) {
			switch $0 {
			case .success:
				let task = session.dataTask(with: URL(string: "\(mockServer.baseUrl)/users")!) { data, response, error in
					if let data = data {
						do {
							let testUsers = try JSONDecoder().decode([MockServerTestUser].self, from: data)
							XCTAssertEqual(testUsers.count, 3)
							XCTAssertTrue(testUsers.contains(where: { $0.name == "ZSAICmTmiwgFFInuEuiK" }))
						} catch {
							XCTFail("DECODING ERROR: \(error.localizedDescription)")
						}
					}
					if let error = error {
						XCTFail(error.localizedDescription)
					}
					dataTaskExpectation.fulfill()
				}
				task.resume()
			case .failure(let error):
				XCTFail("MOCK SERVER ERROR STARTING: \(error.description)")
			}
		}

		// This waitForExpectations here is due to direct interaction with mockServer (mockService should wrap this in a package)
		waitForExpectations(timeout: 1) { _ in
			self.mockServer.finalize(pact: self.pactSpecV3.data(using: .utf8)!) {
				switch $0 {
				case .success(let message): debugPrint(message)
				case .failure(let error): XCTFail(error.description)
				}
			}
		}
	}

	func test_MOCK_SERVER_SANITY_TEST_STANDARD_HTTP() {
		let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main)
		let dataTaskExpectation = expectation(description: "dataTask")
		secureProtocol = true

		mockServer.setup(pact: pactSpecV3.data(using: .utf8)!, protocol: .standard) {
			switch $0 {
			case .success:
				let task = session.dataTask(with: URL(string: "\(mockServer.baseUrl)/users")!) { data, response, error in
					if let data = data {
						do {
							let testUsers = try JSONDecoder().decode([MockServerTestUser].self, from: data)
							XCTAssertEqual(testUsers.count, 3)
							XCTAssertTrue(testUsers.contains(where: { $0.name == "ZSAICmTmiwgFFInuEuiK" }))
						} catch {
							XCTFail("DECODING ERROR: \(error.localizedDescription)")
						}
					}
					if let error = error {
						XCTFail(error.localizedDescription)
					}
					dataTaskExpectation.fulfill()
				}
				task.resume()
			case .failure(let error):
				XCTFail("MOCK SERVER ERROR STARTING: \(error.description)")
			}
		}

		// This waitForExpectations here is due to direct interaction with mockServer (mockService should wrap this in a package)
		waitForExpectations(timeout: 1) { _ in
			self.mockServer.finalize(pact: self.pactSpecV3.data(using: .utf8)!) {
				switch $0 {
				case .success(let message): debugPrint(message)
				case .failure(let error): XCTFail(error.description)
				}
			}
		}
	}

}

extension MockServerTests {

	struct MockServerTestUser: Decodable {
		let dob: String
		let id: Int
		let name: String
	}

	// Pact taken from: https://github.com/pact-foundation/pact-specification/tree/version-3
	// JSON formatted using: https://jsonformatter.curiousconcept.com (settings: compact, RFC 8259)
	var pactSpecV3: String {
		"""
		{"provider":{"name":"sanity_test_provider"},"consumer":{"name":"sanity_test_consumer"},"metadata":{"pactSpecification":{"version":"3.0.0"},"pact-swift":{"version":"0.0.1"}},"interactions":[{"description":"swift test interaction with a DSL array body","request":{"method":"GET","path":"/users"},"response":{"status":200,"headers":{"Content-Type":"application/json; charset=UTF-8"},"body":[{"dob":"2016-07-19","id":1943791933,"name":"ZSAICmTmiwgFFInuEuiK"},{"dob":"2016-07-19","id":1943791933,"name":"ZSAICmTmiwgFFInuEuiK"},{"dob":"2016-07-19","id":1943791933,"name":"ZSAICmTmiwgFFInuEuiK"}],"matchingRules":{"body": {"$[2].name":{"matchers":[{"match":"type"}]},"$[0].id":{"matchers":[{"match":"type"}]},"$[1].id":{"matchers":[{"match":"type"}]},"$[2].id":{"matchers":[{"match":"type"}]},"$[1].name":{"matchers":[{"match":"type"}]},"$[0].name":{"matchers":[{"match":"type"}]},"$[0].dob":{"matchers":[{"date":"yyyy-MM-dd"}]}}}}}]}
		"""
	}

}

extension MockServerTests: URLSessionDelegate {

	func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		guard
			secureProtocol,
			challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
			(challenge.protectionSpace.host.contains("0.0.0.0") || challenge.protectionSpace.host.contains("localhost")),
			let serverTrust = challenge.protectionSpace.serverTrust
		else {
			completionHandler(.performDefaultHandling, nil)
			return
		}

		let credential = URLCredential(trust: serverTrust)
		completionHandler(.useCredential, credential)
	}

}
