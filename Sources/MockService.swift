//
//  Created by Marko Justinek on 15/4/20.
//  Copyright © 2020 Itty Bitty Apps Pty Ltd / PACT Foundation. All rights reserved.
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

import Foundation
import os.log
import XCTest

let kTimeout: TimeInterval = 10

/// Initializes a `MockService` object that handles Pact interaction testing.
///
/// When initializing with `.secure` scheme, the SSL certificate on Mock Server
/// is a self-signed certificate.
open class MockService {

	public enum TransferProtocol: String {
		case standard = "http"
		case secure = "https"
	}

	// MARK: - Properties

	/// The url of `MockService`
	public var baseUrl: String {
		mockServer.baseUrl
	}

	// MARK: - Private properties

	private var pact: Pact
	private var interactions: [Interaction] = []
	private var currentInteraction: Interaction!
	private var allValidated: Bool = true
	private var transferProtocolScheme: TransferProtocol

	private let mockServer: MockServer
	private let errorReporter: ErrorReportable

	// MARK: - Initializers

	/// Initializes a `MockService` object that handles Pact interaction testing.
	///
	/// When initializing with `.secure` scheme, the SSL certificate on Mock Server
	/// is a self-signed certificate
	///
	/// - Parameters:
	///   - consumer: Name of the API consumer (eg: "mobile-app")
	///   - provider: Name of the API provider (eg: "auth-service")
	///   - scheme: HTTP scheme
	public convenience init(consumer: String, provider: String, scheme: TransferProtocol = .standard) {
		self.init(consumer: consumer, provider: provider, scheme: scheme, errorReporter: ErrorReporter())
	}

	/// Initializes a `MockService` object that handles Pact interaction testing.
	///
	/// When initializing with `.secure` scheme, the SSL certificate on Mock Server
	/// is a self-signed certificate.
	///
	/// - Parameters:
	///   - consumer: Name of the API consumer (eg: "mobile-app")
	///   - provider: Name of the API provider (eg: "auth-service")
	///   - scheme: HTTP scheme
	///   - errorReporter: Injectable object to intercept errors
	internal init(consumer: String, provider: String, scheme: TransferProtocol = .standard, errorReporter: ErrorReportable? = nil) {
		pact = Pact(consumer: Pacticipant.consumer(consumer), provider: Pacticipant.provider(provider))
		mockServer = MockServer()
		self.errorReporter = errorReporter ?? ErrorReporter()
		self.transferProtocolScheme = scheme
	}

	// MARK: - Interface

	/// Describes the `Interaction` between the consumer and provider.
	///
	/// It is important that the `description` and provider state
	/// combination is unique per consumer-provider contract.
	///
	/// - parameter description: A description of the API interaction
	@discardableResult
	public func uponReceiving(_ description: String) -> Interaction {
		currentInteraction = Interaction().uponReceiving(description)
		interactions.append(currentInteraction)
		return currentInteraction
	}

	/// Runs the Pact test against the code that makes the API request with 10 second timeout.
	///
	/// Make sure you call the completion block (eg: `testCompleted()`) at the end of your test.
	///
	/// - Parameters:
	///   - file: The file to report the failing test in
	///   - line: The line on which to report the failing test
	///   - waitFor: Give the test function `waitFor` seconds to test your interaction. Default is 10 seconds
	///   - testFunction: Your code that makes the API request
	///   - testCompleted: Completion block notifying `MockService` the test is done
	public func run(_ file: FileString? = #file, line: UInt? = #line, waitFor timeout: TimeInterval? = nil, testFunction: @escaping (_ testCompleted: @escaping () -> Void) throws -> Void) {
		pact.interactions = [currentInteraction]

		waitForPactTestWith(timeout: timeout ?? kTimeout, file: file, line: line) { [unowned self, pactData = pact.data] completion in
			self.mockServer.setup(pact: pactData!, protocol: self.transferProtocolScheme) {
				switch $0 {
				case .success:
					do {
						try testFunction {
							completion()
						}
					} catch {
						self.failWith("🚨 Error thrown in test function: \(error.localizedDescription)", file: file, line: line)
					}
				case .failure(let error):
					self.failWith(error.description)
					completion()
				}
			}
		}

		waitForPactTestWith(timeout: timeout ?? kTimeout, file: file, line: line) { completion in
			self.mockServer.verify {
				switch $0 {
				case .success:
					self.finalize {
						switch $0 {
						case .success(let message):
							if #available(iOS 10, OSX 10.14, *) {
								os_log(.debug, "%@", message)
							} else {
								debugPrint(message)
							}
							completion()
						case .failure(let error):
							self.failWith(error.description, file: file, line: line)
						}
					}
				case .failure(let error):
					self.failWith(error.description, file: file, line: line)
					completion()
				}
			}
		}
	}

}

// MARK: - Internal

extension MockService {

	/// Writes a Pact contract file in JSON format.
	///
	/// - parameter completion: Result of the writing the Pact contract to JSON
	///
	/// By default Pact contracts are written to `/tmp/pacts` folder.
	/// Set `PACT_OUTPUT_DIR` to `$(PATH)/to/desired/dir/` in `Build` phase of your `Scheme` to change the location.
	func finalize(completion: ((Result<String, MockServerError>) -> Void)? = nil) {
		pact.interactions = interactions
		guard let pactData = pact.data, allValidated else {
			completion?(.failure( .validationFaliure))
			return
		}

		self.mockServer.finalize(pact: pactData) {
			switch $0 {
			case .success(let message):
				completion?(.success(message))
			case .failure(let error):
				self.failWith(error.description)
				completion?(.failure(error))
			}
		}
	}

}

// MARK: - Private -

private extension MockService {

	/// Waits for test to be completed and fails if timed out
	func waitForPactTestWith(timeout: TimeInterval, file: FileString?, line: UInt?, action: @escaping (@escaping () -> Void) -> Void) {
		let expectation = XCTestExpectation(description: "waitForPactTest")
		action {
			expectation.fulfill()
		}

		let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
		if result != .completed {
			let message = "Test did not complete within \(timeout) second timeout! Did you run testCompleted() block?"
			if let file = file, let line = line {
				errorReporter.reportFailure(message, file: file, line: line)
			} else {
				errorReporter.reportFailure(message)
			}
		}
	}

	/// Fail the test and raise the failure in `file` at `line`
	func failWith(_ message: String, file: FileString? = nil, line: UInt? = nil) {
		allValidated = false

		if let file = file, let line = line {
			errorReporter.reportFailure(message, file: file, line: line)
		} else {
			errorReporter.reportFailure(message)
		}
	}

}
