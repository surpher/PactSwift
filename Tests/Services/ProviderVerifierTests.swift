//
//  Created by Marko Justinek on 19/8/21.
//  Copyright © 2021 Marko Justinek. All rights reserved.
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
import PactSwiftMockServerLinux
#elseif compiler(>=5.5)
@_implementationOnly import PactSwiftMockServer
#else
import PactSwiftMockServer
#endif

final class ProviderVerifierTests: XCTestCase {

	var errorReporter: ErrorCapture!
	var mockVerifier: ProviderVerifying!
	var testSubject: ProviderVerifier!

	override func setUpWithError() throws {
		try super.setUpWithError()

		errorReporter = ErrorCapture()
		mockVerifier = MockVerifier()
		testSubject = ProviderVerifier(verifier: mockVerifier, errorReporter: errorReporter)
	}

	override func tearDownWithError() throws {
		errorReporter = nil
		mockVerifier = nil
		testSubject = nil

		try super.tearDownWithError()
	}

	// MARK: - Tests

	func testVerifyProviderReturnsSuccess() {
		let testOptions = ProviderVerifier.Options(
			provider: .init(port: 1234),
			pactsSource: .directories(["/tmp/pacts"])
		)

		guard case .success = testSubject.verify(options: testOptions) else {
			XCTFail("Expected verification to succeed!")
			return
		}
	}

	func testVerifyProviderReturnsError() throws {
		let testOptions = ProviderVerifier.Options(
			provider: .init(port: 1234),
			pactsSource: .directories(["/tmp/pacts"])
		)

		let mockVerifier = MockVerifier { .failure(ProviderVerificationError.invalidArguments) }
		let testSubject = ProviderVerifier(verifier: mockVerifier, errorReporter: errorReporter)

		guard case .failure = testSubject.verify(options: testOptions) else {
			XCTFail("Expected verification to fail!")
			return
		}

		let expectedError = try XCTUnwrap(errorReporter.error?.message)
		XCTAssertEqual(expectedError, "Provider Verification Error: Invalid arguments were provided to the verification process.")
	}

	func testVerifyingProviderTriggersCompletionBlock() {
		let testOptions = ProviderVerifier.Options(
			provider: .init(port: 1234),
			pactsSource: .directories(["/tmp/pacts"])
		)

		let testExp = expectation(description: "Completion block on succcessful verification")
		testSubject.verify(options: testOptions) {
			testExp.fulfill()
		}

		waitForExpectations(timeout: 0.1)
	}

	func testVerifyingProviderFailureTriggersCompletionBlock() throws {
		let testOptions = ProviderVerifier.Options(
			provider: .init(port: 1234),
			pactsSource: .directories(["/tmp/pacts"])
		)

		let testExp = expectation(description: "Completion block on failed verification")
		let mockVerifier = MockVerifier { .failure(ProviderVerificationError.verificationFailed) }
		let testSubject = ProviderVerifier(verifier: mockVerifier, errorReporter: errorReporter)
		testSubject.verify(options: testOptions, completionBlock: {
			testExp.fulfill()
		})

		let expectedError = try XCTUnwrap(errorReporter.error?.message)
		XCTAssertEqual(expectedError, "Provider Verification Error: The verification process failed, see output for errors.")
		waitForExpectations(timeout: 0.1)
	}

}

// MARK: - Mocks

private class MockVerifier: ProviderVerifying {

	typealias VerifyProviderHandler = () -> Result<Bool, ProviderVerificationError>

	let verifyProviderHandler: VerifyProviderHandler?

	init(verifyProviderHandler: VerifyProviderHandler? = nil) {
		self.verifyProviderHandler = verifyProviderHandler
	}

	func verifyProvider(options args: String) -> Result<Bool, ProviderVerificationError> {
		verifyProviderHandler?() ?? .success(true)
	}

}
