//
//  Created by Oliver Jones on 30/11/2022.
//  Copyright © 2022 Oliver Jones. All rights reserved.
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

#if canImport(_Concurrency) && compiler(>=5.7) && !os(Linux)

import Foundation
@_implementationOnly import PactSwiftMockServer

extension MockServer {
	
	/// Spins up a mock server with expected interactions defined in the provided Pact
	///
	/// - Parameters:
	///   - pact: The pact contract
	///   - protocol: HTTP protocol
	///
	@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
	@discardableResult
	func setup(pact: Data, protocol: PactSwiftMockServer.TransferProtocol = .standard) async throws -> Int {
		try await withCheckedThrowingContinuation { continuation in
			self.setup(pact: pact, protocol: `protocol`) { result in
				continuation.resume(with: result)
			}
		}
	}
	
	/// Verifies all interactions passed to mock server
	///
	/// By default pact files are written to `/tmp/pacts`.
	/// Use `PACT_OUTPUT_DIR` environment variable with absolute path to your custom path in schema `run` configuration.
	///
	@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
	func verify() async throws -> Bool {
		try await withCheckedThrowingContinuation { continuation in
			self.verify { result in
				continuation.resume(with: result)
			}
		}
	}
	
	/// Finalises Pact tests by writing the pact contract file to disk
	///
	/// - Parameters:
	///   - pact: The Pact contract to write
	///   - completion: A completion block called when setup completes
	///
	@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
	func finalize(pact: Data) async throws -> String {
		try await withCheckedThrowingContinuation { continuation in
			self.finalize(pact: pact) { result in
				continuation.resume(with: result)
			}
		}
	}

}

#endif
