//
//  Created by Huw Rowlands on 30/11/2022.
//  Copyright © 2022 Huw Rowlands. All rights reserved.
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

import Foundation

// FoundationNetworking for Linux does not seem to support the async `URLSession.data(from:)` methods.
#if canImport(_Concurrency) && compiler(>=5.7) && !os(Linux)
final class MockServiceAsyncTests: XCTestCase {

	var mockService: MockService!
	var errorCapture: ErrorCapture!

	private var secureProtocol: Bool = false

	// MARK: - Lifecycle

	override func setUpWithError() throws {
		try super.setUpWithError()

		guard #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) else {
			throw XCTSkip("Unsupported OS")
		}

		errorCapture = ErrorCapture()
		mockService = MockService(consumer: "pactswift-unit-tests", provider: "unit-test-api-provider", errorReporter: errorCapture)
	}

	@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
	func testMockService_SimpleGetRequest_InsideTask() {
		mockService
			.uponReceiving("Request for a list")
			.given("elements exist")
			.withRequest(method: .GET, path: "/elements")
			.willRespondWith(status: 200)

		let testExpectation = expectation(description: #function)

		mockService.run(timeout: 1) { baseURL, completion in
			let session = URLSession.shared
			Task {
				let (_, response) = try await session.data(from: URL(string: "\(baseURL)/elements")!)

				if let response = response as? HTTPURLResponse {
					XCTAssertEqual(200, response.statusCode)
					completion()
					testExpectation.fulfill()
				} else {
					XCTFail("Expecting response code 200 in \(#function)")
				}
			}
		}
		waitForExpectations(timeout: 1)
	}

}
#endif
