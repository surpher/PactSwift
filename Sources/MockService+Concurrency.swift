//
//  Created by Marko Justinek on 5/8/2023.
//  Copyright © 2023 Marko Justinek. All rights reserved.
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

#if canImport(_Concurrency) && compiler(>=5.7)
@_implementationOnly import PactSwiftMockServer

public extension MockService {

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
	func run(_ file: FileString? = #file, line: UInt? = #line, verify interactions: [Interaction]? = nil, timeout: TimeInterval? = nil, testFunction: @escaping @Sendable (_ baseURL: String) async throws -> Void) async throws {
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
}

// MARK: - Internal

extension MockService {

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
}
#endif
