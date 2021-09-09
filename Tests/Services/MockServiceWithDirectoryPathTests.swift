//
//  Created by Marko Justinek on 9/9/21.
//  Copyright © 2020 Marko Justinek. All rights reserved.
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

#if os(Linux)
import FoundationNetworking
#endif

final class MockServiceWithDirectoryPathTests: XCTestCase {

	static private let expectedTargetDirectory = URL(fileURLWithPath: "/tmp/pacts/custom/path", isDirectory: true)
	static private var mockService: MockService!

	#if os(Linux)
	let session = URLSession.shared
	#else
	let session = URLSession(configuration: .ephemeral)
	#endif

	override class func setUp() {
		mockService = MockService(consumer: "custom-dir-consumer", provider: "provider", directory: MockServiceWithDirectoryPathTests.expectedTargetDirectory)
	}

	override class func tearDown() {
		XCTAssertTrue(FileManager.default.fileExists(atPath: "/tmp/pacts/custom/path/custom-dir-consumer-provider.json"), "Failed to write Pact contract to a custom directory path!")

		super.tearDown()
	}

	// MARK: - Tests

	func testRunAPactTest() {
		MockServiceWithDirectoryPathTests.mockService
			.uponReceiving("a request for animals with children")
			.given("animals have children")
			.withRequest(method: .GET, path: "/animals")
			.willRespondWith(
				status: 200,
				body: [
					"animals": Matcher.EachLike(
						[
							"children": Matcher.EachLike(
								Matcher.SomethingLike("Mary"),
								min: 0
							),
						]
					)
				]
			)

		MockServiceWithDirectoryPathTests.mockService.run { [unowned self] baseURL, completed in
			let url = URL(string: "\(baseURL)/animals")!
			session
				.dataTask(with: url) { data, response, error in
					guard
						error == nil,
						(response as? HTTPURLResponse)?.statusCode == 200
					else {
						fail(function: #function, request: url.absoluteString, response: response.debugDescription, error: error)
						return
					}
					// We don't care about the network response here, so we tell PactSwift we're done with the Pact test
					// This is tested in `MockServiceTests.swift`
					completed()
				}
				.resume()
		}
	}

}

// MARK: - Utilities

private extension MockServiceWithDirectoryPathTests {

	func fail(function: String, request: String? = nil, response: String? = nil, error: Error? = nil) {
		XCTFail(
		"""
		Expected network request to succeed in \(function)!
		Request URL: \t\(String(describing: request))
		Response:\t\(String(describing: response))
		Reason: \t\(String(describing: error?.localizedDescription))
		"""
		)
	}

}
