//
//  Created by Marko Justinek on 15/4/20.
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

import Foundation
@_implementationOnly import PactSwiftToolbox
import XCTest

#if os(Linux)
import PactSwiftMockServerLinux
#else
@_implementationOnly import PactSwiftMockServer
#endif

/// Initializes a `MockService` object that handles Pact interaction testing.
///
/// When initializing with `.secure` scheme, the SSL certificate on Mock Server
/// is a self-signed certificate.
///
open class MockService {

	// MARK: - Private properties

	private var pact: Pact
	private var interactions: [Interaction] = []
	private var currentInteraction: Interaction!
	private let errorReporter: ErrorReportable
	private let pactsDirectory: URL?

	#if os(Linux)
	private var transferProtocolScheme: PactSwiftMockServerLinux.TransferProtocol
	#else
	private var transferProtocolScheme: PactSwiftMockServer.TransferProtocol
	#endif

	// MARK: - Initializers

	/// Initializes a `MockService` object that handles Pact interaction testing
	///
	/// When initializing with `.secure` scheme, the SSL certificate on Mock Server
	/// is a self-signed certificate
	///
	/// - Parameters:
	///   - consumer: Name of the API consumer (eg: "mobile-app")
	///   - provider: Name of the API provider (eg: "auth-service")
	///   - scheme: HTTP scheme
	///   - directory: The directory where to write the contract
	///
	public convenience init(consumer: String, provider: String, scheme: TransferProtocol = .standard, writePactTo directory: URL? = nil) {
		self.init(consumer: consumer, provider: provider, scheme: scheme, directory: directory, errorReporter: ErrorReporter())
	}

	/// Initializes a `MockService` object that handles Pact interaction testing
	///
	/// When initializing with `.secure` scheme, the SSL certificate on Mock Server
	/// is a self-signed certificate.
	///
	/// - Parameters:
	///   - consumer: Name of the API consumer (eg: "mobile-app")
	///   - provider: Name of the API provider (eg: "auth-service")
	///   - scheme: HTTP scheme
	///   - errorReporter: Injectable object to intercept errors
	///   - directory: The directory where to write the contract
	///
	internal init(consumer: String, provider: String, scheme: TransferProtocol = .standard, directory: URL? = nil, errorReporter: ErrorReportable? = nil) {
		pact = Pact(consumer: Pacticipant.consumer(consumer), provider: Pacticipant.provider(provider))
		self.errorReporter = errorReporter ?? ErrorReporter()
		self.transferProtocolScheme = scheme.bridge
		self.pactsDirectory = directory
	}

	// MARK: - Interface

	/// Describes the `Interaction` between the consumer and provider
	///
	/// It is important that the `description` and provider state
	/// combination is unique per consumer-provider contract.
	///
	/// - parameter description: A description of the API interaction
	///
	@discardableResult
	public func uponReceiving(_ description: String) -> Interaction {
		currentInteraction = Interaction().uponReceiving(description)
		interactions.append(currentInteraction)
		return currentInteraction
	}

	/// Runs the Pact test against the code making the API request
	///
	/// - Parameters:
	///   - file: The file to report the failing test in
	///   - line: The line on which to report the failing test
	///   - verify: An array of specific `Interaction`s to verify. If none provided, the latest defined interaction is used
	///   - timeout: Time before the test times out. Default is 10 seconds
	///   - testFunction: Your code making the API request
	///
	/// The `testFunction` completion block passes two values to your unit test. A `String` representing
	/// the url of the active Mock Server and a `Void` function that you call when you are done with your unit test.
	/// You must call this function within your `testFunction:` completion block when your test completes. It signals PactSwift
	/// that your test finished. If you do not call it then your test will time out.
	///
	/// ```
	/// mockService.run { baseURL, done in
	///   // code making the request with provided `baseURL`
	///   // assert response can be processed
	///   done()
	/// }
	/// ```
	///
	public func run(_ file: FileString? = #file, line: UInt? = #line, verify interactions: [Interaction]? = nil, timeout: TimeInterval? = nil, testFunction: @escaping (_ baseURL: String, _ done: (@escaping () -> Void)) throws -> Void) {
		// Use the provided set or if not provided only the current interaction
		pact.interactions = interactions ?? [currentInteraction]

		// Check there are no invalid interactions
		var hasErrors = false
		pact.interactions.forEach { interaction in
			interaction.encodingErrors.forEach {
				hasErrors = true
				failWith($0.localizedDescription, file: file, line: line)
			}
		}

		if hasErrors {
			// Remove interactions with errors
			pact.interactions.removeAll { $0.encodingErrors.isEmpty == false }
			self.interactions.removeAll()
		} else {
			// Prepare a brand spanking new MockServer (Mock Provider) on its own port
			let mockServer = MockServer()

			// Set the expectations so we don't wait for this async magic indefinitely
			setupPactInteraction(timeout: timeout ?? Constants.kTimeout, file: file, line: line, mockServer: mockServer, testFunction: testFunction)

			// At the same time start listening to verification that Mock Server received the expected request
			verifyPactInteraction(timeout: timeout ?? Constants.kTimeout, file: file, line: line, mockServer: mockServer)
		}
	}

}

// MARK: - Internal

extension MockService {

	/// Writes a Pact contract file in JSON format
	///
	/// - parameter completion: Result of the writing the Pact contract to JSON
	///
	/// By default Pact contracts are written to `/tmp/pacts` folder.
	/// Set `PACT_OUTPUT_DIR` to `$(PATH)/to/desired/dir/` in `Build` phase of your `Scheme` to change the location.
	///
	func finalize(file: FileString? = nil, line: UInt? = nil, completion: ((Result<String, MockServerError>) -> Void)? = nil) {

		// Spin up a fresh Mock Server with a directory to write to
		let mockServer = MockServer(directory: pactsDirectory)

		// Gather all the interactions this MockService has received to set up and prepare Pact data with them all
		pact.interactions = interactions.filter { $0.encodingErrors.isEmpty }

		// Validate the Pact `Data` is hunky dory
		guard let pactData = pact.data else {
			completion?(.failure(.nullPointer))
			return
		}

		// Ask Mock Server to do the actual Pact file writing to disk
		mockServer.finalize(pact: pactData) { [unowned self] in
			switch $0 {
			case .success(let message):
				completion?(.success(message))
			case .failure(let error):
				failWith(error.description)
				completion?(.failure(error))
			}
		}
	}

	/// Waits for test to be completed and fails if timed out
	func waitForPactTestWith(timeout: TimeInterval, file: FileString?, line: UInt?, action: (@escaping () -> Void) -> Void) {
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
		if let file = file, let line = line {
			errorReporter.reportFailure(message, file: file, line: line)
		} else {
			errorReporter.reportFailure(message)
		}
	}

}

// MARK: - Private

private extension MockService {

	func setupPactInteraction(timeout: TimeInterval, file: FileString?, line: UInt?, mockServer: MockServer, testFunction: (String, @escaping (() -> Void)) throws -> Void) {
		waitForPactTestWith(timeout: timeout, file: file, line: line) { [unowned self] completion in
			Logger.log(message: "Setting up pact test", data: pact.data)

			// Set up a Mock Server with Pact data and on desired http protocol
			mockServer.setup(pact: pact.data!, protocol: transferProtocolScheme) {
				switch $0 {
				case .success:
					do {
						// If Mock Server spun up, run the test function
						try testFunction(mockServer.baseUrl) {
							completion()
						}
					} catch {
						failWith("🚨 Error thrown in test function: \(error.localizedDescription)", file: file, line: line)
						completion()
					}
				case .failure(let error):
					// Failed to spin up a Mock Server. This could be due to bad Pact data. Most likely to Pact data.
					failWith(error.description)
					completion()
				}
			}
		}
	}

	func verifyPactInteraction(timeout: TimeInterval, file: FileString?, line: UInt?, mockServer: MockServer) {
		waitForPactTestWith(timeout: timeout, file: file, line: line) { [unowned self] completion in
			// Ask Mock Server to verify the promised request (testFunction:) has been made
			mockServer.verify {
				switch $0 {
				case .success:
					// If the comsumer (in testFunction:) made the promised request to Mock Server, go and finalize the test
					finalize(file: file, line: line) {
						switch $0 {
						case .success(let message):
							Logger.log(message: message, data: pact.data)
							completion()
						case .failure(let error):
							failWith(error.description, file: file, line: line)
							completion()
						}
					}
				case .failure(let error):
					failWith(error.description, file: file, line: line)
					completion()
				}
			}
		}
	}

}
