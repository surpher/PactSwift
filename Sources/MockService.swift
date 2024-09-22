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

	var pact: Pact
	var interactions: [Interaction] = []
	var currentInteraction: Interaction!
	let errorReporter: ErrorReportable
	let pactsDirectory: URL?
	let merge: Bool

	var transferProtocolScheme: PactSwiftMockServer.TransferProtocol

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
