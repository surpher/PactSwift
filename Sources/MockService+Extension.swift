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
import XCTest

#if compiler(>=5.5)
@_implementationOnly import PactSwiftMockServer
#else
import PactSwiftMockServer
#endif

extension MockService {

	/// Check there are no invalid interactions
	func checkForInvalidInteractions(_ interactions: [Interaction], file: FileString? = nil, line: UInt? = nil) -> Bool {
		let errors = interactions.flatMap(\.encodingErrors)
		for error in errors {
			failWith(error.localizedDescription, file: file, line: line)
		}
		return errors.isEmpty == false
	}

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
