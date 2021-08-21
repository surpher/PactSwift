//
//  Created by Marko Justinek on 20/8/21.
//  Copyright © 2021 PACT Foundation. All rights reserved.
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
import PactSwiftMockServer
#endif

/// Entry point for provider verification
public final class ProviderVerifier {

	let verifier: Verifier
	private let errorReporter: ErrorReportable

	/// Initializes a ``Verifier`` object
	public convenience init() {
		self.init(errorReporter: ErrorReporter())
	}

	/// Initializes a ``Verifier`` object
	///
	/// - Parameters:
	///   - errorReporter: Injectable object to intercept errors
	///
	internal init(errorReporter: ErrorReportable? = nil) {
		self.verifier = Verifier()
		self.errorReporter = errorReporter ?? ErrorReporter()
	}

	/// Executes provider verification test
	///
	/// - Parameters:
	///   - options: Flags and options to use when verifying the provider
	///   - file: The file in which to report the error in
	///   - line: The line on which to report the error on
	///   - completionBlock: Completion block executed at the end of verification
	///
	public func verify(options: VerificationOptions, file: FileString? = #file, line: UInt? = #line, completionBlock: @escaping () -> Void) {
		if case .failure(let error) = verifier.verifyProvider(options: options) {
			 failWith(error.description, file: file, line: line)
		}
		completionBlock()
	}

}

// MARK: - Private

private extension ProviderVerifier {

	/// Fail the test and raise the failure in ``file`` at ``line``
	func failWith(_ message: String, file: FileString? = nil, line: UInt? = nil) {
		if let file = file, let line = line {
			errorReporter.reportFailure(message, file: file, line: line)
		} else {
			errorReporter.reportFailure(message)
		}
	}

}
