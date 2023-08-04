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
import XCTest

#if compiler(>=5.5)
@_implementationOnly import PactSwiftMockServer
#else
import PactSwiftMockServer
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
	private let merge: Bool

	private var transferProtocolScheme: PactSwiftMockServer.TransferProtocol

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
	///   - writePactTo: The directory where to write the contract
	///   - merge: Whether to merge interactions with an existing Pact contract
	///
	public convenience init(
		consumer: String,
		provider: String,
		scheme: TransferProtocol = .standard,
		writePactTo directory: URL? = nil,
		merge: Bool = true
	) {
		self.init(consumer: consumer, provider: provider, scheme: scheme, directory: directory, merge: merge, errorReporter: ErrorReporter())
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
	///   - directory: The directory where to write the contract
	///   - merge: Whether to merge interactions with an existing Pact contract
	///   - errorReporter: Injectable object to intercept errors
	///
	internal init(
		consumer: String,
		provider: String,
		scheme: TransferProtocol = .standard,
		directory: URL? = nil,
		merge: Bool = true,
		errorReporter: ErrorReportable? = nil
	) {
		pact = Pact(consumer: Pacticipant.consumer(consumer), provider: Pacticipant.provider(provider))
		self.errorReporter = errorReporter ?? ErrorReporter()
		self.transferProtocolScheme = scheme.bridge
		self.pactsDirectory = directory
		self.merge = merge
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
	/// The `testFunction` block passes two values to your unit test. A `String` representing
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
	public func run(_ file: FileString? = #file, line: UInt? = #line, verify interactions: [Interaction]? = nil, timeout: TimeInterval? = nil, testFunction: @escaping (_ baseURL: String, _ done: (@escaping @Sendable () -> Void)) throws -> Void) {
		// Use the provided set or if not provided only the current interaction
		pact.interactions = interactions ?? [currentInteraction]

		if checkForInvalidInteractions(pact.interactions, file: file, line: line) {
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

	#if canImport(_Concurrency) && compiler(>=5.7)
	/// Runs the Pact test against the code making the API request
	///
	/// - Parameters:
	///   - file: The file to report the failing test in
	///   - line: The line on which to report the failing test
	///   - verify: An array of specific `Interaction`s to verify. If none provided, the latest defined interaction is used
	///   - timeout: Time before the test times out. Default is 10 seconds
	///   - testFunction: Your async code making the API request
	///
	/// The `testFunction` closure is passed a `String` representing  the url of the active Mock Server.
	///
	/// ```
	/// try await mockService.run { baseURL in
	///   // async code making the request with provided `baseURL`
	///   // assert response can be processed
	/// }
	/// ```
	///
	@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
	public func run(_ file: FileString? = #file, line: UInt? = #line, verify interactions: [Interaction]? = nil, timeout: TimeInterval? = nil, testFunction: @escaping @Sendable (_ baseURL: String) async throws -> Void) async throws {
		// Use the provided set or if not provided only the current interaction
		pact.interactions = interactions ?? [currentInteraction]

		if checkForInvalidInteractions(pact.interactions, file: file, line: line) {
			// Remove interactions with errors
			pact.interactions.removeAll { $0.encodingErrors.isEmpty == false }
			self.interactions.removeAll()
		} else {
			// Prepare a brand spanking new MockServer (Mock Provider) on its own port
			let mockServer = MockServer()

			// Set the expectations so we don't wait for this async magic indefinitely
			try await setupPactInteraction(timeout: timeout ?? Constants.kTimeout, file: file, line: line, mockServer: mockServer, testFunction: testFunction)

			// At the same time start listening to verification that Mock Server received the expected request
			try await verifyPactInteraction(timeout: timeout ?? Constants.kTimeout, file: file, line: line, mockServer: mockServer)
		}
	}
	#endif

	/// Check there are no invalid interactions
	private func checkForInvalidInteractions(_ interactions: [Interaction], file: FileString? = nil, line: UInt? = nil) -> Bool {
		let errors = interactions.flatMap(\.encodingErrors)
		for error in errors {
			failWith(error.localizedDescription, file: file, line: line)
		}
		return errors.isEmpty == false
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
		let mockServer = MockServer(directory: pactsDirectory, merge: self.merge)

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

	#if canImport(_Concurrency) && compiler(>=5.7)
	/// Writes a Pact contract file in JSON format
	///
	/// By default Pact contracts are written to `/tmp/pacts` folder.
	/// Set `PACT_OUTPUT_DIR` to `$(PATH)/to/desired/dir/` in `Build` phase of your `Scheme` to change the location.
	///
	@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
	func finalize(file: FileString? = nil, line: UInt? = nil) async throws -> String {
		// Spin up a fresh Mock Server with a directory to write to
		let mockServer = MockServer(directory: pactsDirectory, merge: self.merge)

		// Gather all the interactions this MockService has received to set up and prepare Pact data with them all
		pact.interactions = interactions.filter { $0.encodingErrors.isEmpty }

		// Validate the Pact `Data` is hunky dory
		guard let pactData = pact.data else {
			throw MockServerError.nullPointer
		}

		// Ask Mock Server to do the actual Pact file writing to disk
		do {
			return try await mockServer.finalize(pact: pactData)
		} catch {
			failWith((error as? MockServerError)?.description ?? error.localizedDescription, file: file, line: line)
			throw error
		}
	}
	#endif

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

	func setupPactInteraction(timeout: TimeInterval, file: FileString?, line: UInt?, mockServer: MockServer, testFunction: (String, @escaping (@Sendable () -> Void)) throws -> Void) {
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

	#if canImport(_Concurrency) && compiler(>=5.7)
	@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
	func setupPactInteraction(timeout: TimeInterval, file: FileString?, line: UInt?, mockServer: MockServer, testFunction: @escaping @Sendable (String) async throws -> Void) async throws {
		Logger.log(message: "Setting up pact test", data: pact.data)
		do {
			// Set up a Mock Server with Pact data and on desired http protocol
			try await mockServer.setup(pact: pact.data!, protocol: transferProtocolScheme)

			// If Mock Server spun up, run the test function
			let task = Task(timeout: timeout) {
				try await testFunction(mockServer.baseUrl)
			}
			// await task completion (value is Void)
			try await task.value
		} catch {
			// Failed to spin up a Mock Server. This could be due to bad Pact data. Most likely to Pact data.
			failWith((error as? MockServerError)?.description ?? error.localizedDescription, file: file, line: line)
			throw error
		}
	}

	@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
	func verifyPactInteraction(timeout: TimeInterval, file: FileString?, line: UInt?, mockServer: MockServer) async throws {
		do {
			let task = Task(timeout: timeout) {
				try await mockServer.verify()
			}
			// await task completion (value is discarded)
			_ = try await task.value

			// If the comsumer (in testFunction:) made the promised request to Mock Server, go and finalize the test.
			// Only finalize when running in simulator or macOS. Running on a physical iOS device makes little sense due to
			// writing a pact file to device's disk. `libpact_ffi` does the actual file writing it writes it onto the
			// disk of the device it is being run on.
			#if targetEnvironment(simulator) || os(macOS)
			let message = try await finalize(file: file, line: line)
			Logger.log(message: message, data: self.pact.data)
			#else
			print("[INFO]: Running on an iOS device. Writing Pact interaction into a contract skipped.")
			#endif
		} catch {
			failWith((error as? MockServerError)?.description ?? error.localizedDescription, file: file, line: line)
			throw error
		}
	}
	#endif

	func verifyPactInteraction(timeout: TimeInterval, file: FileString?, line: UInt?, mockServer: MockServer) {
		waitForPactTestWith(timeout: timeout, file: file, line: line) { [unowned self] completion in
			// Ask Mock Server to verify the promised request (testFunction:) has been made
			mockServer.verify {
				switch $0 {
				case .success:
					// If the comsumer (in testFunction:) made the promised request to Mock Server, go and finalize the test.
					// Only finalize when running in simulator or macOS. Running on a physical iOS device makes little sense due to
					// writing a pact file to device's disk. `libpact_ffi` does the actual file writing it writes it onto the
					// disk of the device it is being run on.
					#if targetEnvironment(simulator) || os(macOS)
					finalize(file: file, line: line) {
						switch $0 {
						case .success(let message):
							Logger.log(message: message, data: self.pact.data)
							completion()
						case .failure(let error):
							self.failWith(error.description, file: file, line: line)
							completion()
						}
					}
					#else
					print("[INFO]: Running on an iOS device. Writing Pact interaction into a contract skipped.")
					completion()
					#endif

				case .failure(let error):
					failWith(error.description, file: file, line: line)
					completion()
				}
			}
		}
	}

}
