//
//  Created by Marko Justinek on 20/8/21.
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

import Foundation
import XCTest

#if compiler(>=5.5)
@_implementationOnly import PactSwiftMockServer
#else
import PactSwiftMockServer
#endif

/// Entry point for provider verification
public final class ProviderVerifier {

	let verifier: ProviderVerifying
	private let errorReporter: ErrorReportable

	/// Initializes a `Verifier` object for provider verification
	public convenience init() {
		self.init(verifier: Verifier(), errorReporter: ErrorReporter())
	}

	/// Initializes a `Verifier` object
	///
	/// - Parameters:
	///   - verifier: The verifier object handling provider verification
	///   - errorReporter: Error reporting or intercepting object
	///
	/// This initializer is marked `internal` for testing purposes!
	///
	internal init(verifier: ProviderVerifying, errorReporter: ErrorReportable? = nil) {
		self.verifier = verifier
		self.errorReporter = errorReporter ?? ErrorReporter()
	}

	/// Executes provider verification test
	///
	/// - Parameters:
	///   - options: Flags and args to use when verifying a provider
	///   - file: The file in which to report the error in
	///   - line: The line on which to report the error on
	///   - completionBlock: Completion block executed at the end of verification
	///
	/// - Returns: A `Result<Bool, VerificationError>` where error describes the failure
	///
	@discardableResult
	public func verify(options: Options, file: FileString? = #file, line: UInt? = #line, completionBlock: (() -> Void)? = nil) -> Result<Bool, ProviderVerifier.VerificationError> {
		switch verifier.verifyProvider(options: options.args) {
		case .success(let value):
			completionBlock?()
			return .success(value)
		case .failure(let error):
			failWith(error.description, file: file, line: line)
			completionBlock?()
			return .failure(VerificationError.error(error.description))
		}
	}

}

// MARK: - Private

private extension ProviderVerifier {

	/// Fail the test and raise the failure in `file` at `line`
	func failWith(_ message: String, file: FileString? = nil, line: UInt? = nil) {
		if let file = file, let line = line {
			errorReporter.reportFailure(message, file: file, line: line)
		} else {
			errorReporter.reportFailure(message)
		}
	}

}
