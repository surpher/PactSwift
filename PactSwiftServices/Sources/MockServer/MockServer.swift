//
//  MockServer.swift
//  PactSwiftServices
//
//  Created by Marko Justinek on 12/4/20.
//  Copyright © 2020 Pact Foundation. All rights reserved.
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

#if SWIFT_PACKAGE
import PactMockServer
#endif

public class MockServer {

	// MARK: - Properties

	public var baseUrl: String {
		"http://\(socketAddress):\(port)"
	}

	lazy private var port: Int32 = {
		unusedPort()
	}()

	private let socketAddress = "0.0.0.0"

	// MARK: - Lifecycle

	public init() { }

	deinit {
		shutdownMockServer()
	}

	// MARK: - Interface

	/// Prepare the Pact Mock Server with expected interactions

	// TODO: - This should probably be part of an init()
	// as asking for baseUrl before calling setup() might cause some unexpected behaviour
	public func setup(pact: Data, completion: (Result<Int, MockServerError>) -> Void) {
		port = create_mock_server(
			String(data: pact, encoding: .utf8)?.replacingOccurrences(of: "\\", with: ""), // interactions is nil
			"\(socketAddress):\(port)"
		)

		return (port > 1200)
			? completion(Result.success(Int(port)))
			: completion(Result.failure(MockServerError(code: Int(port))))
	}

	/// Verify interactions
	public func verify(completion: (Result<Bool, VerificationError>) -> Void) {
		guard requestsMatched else {
			completion(.failure(.reason(mismatchDescription)))
			return
		}
		completion(.success(true))
	}

	/// Finalise by writing the contract file onto disk
	public func finalize(pact: Data, completion: ((Result<String, MockServerError>) -> Void)?) {
		shutdownMockServer()
		create_mock_server(
			String(data: pact, encoding: .utf8)?.replacingOccurrences(of: "\\", with: ""),
			"\(socketAddress):\(port)"
		)
		writePactContractFile {
			switch $0 {
			case .success(let message):
				completion?(.success(message))
			case .failure(let error):
				completion?(.failure(error))
			}
		}
	}

}

private extension MockServer {

	/// true when all expected requests have successfully matched
	var requestsMatched: Bool {
		mock_server_matched(port)
	}

	/// Descripton of mismatching requests
	var mismatchDescription: String {
		guard let mismatches = mock_server_mismatches(port) else {
			return "No response! There might be something fishy going on with your Mock Server..."
		}

		let errorDescription = ValidationErrorHandler(mismatches: String(cString: mismatches)).description
		return errorDescription
	}

	/// Writes the PACT contract file to disk
	func writePactContractFile(completion: (Result<String, MockServerError>) -> Void) {
		guard checkForPath() else {
			completion(.failure(.failedToWriteFile))
			return
		}

		let writeResult = write_pact_file(port, pactDir)
		guard writeResult == 0 else {
			completion(Result.failure(MockServerError(code: Int(writeResult))))
			return
		}
		completion(Result.success("Pact interaction written to \(pactDir)"))
	}

	/// Shuts down the Mock Server and releases the socket address
	func shutdownMockServer() {
		if port > 0 {
			cleanup_mock_server(port)
		}
	}

}

// TODO: - This is horrible. Need to put it away somewhere as a reusable component
private extension MockServer {

	var pactDir: String {
		ProcessInfo.processInfo.environment["PACT_DIR"] ?? "/tmp/pacts"
	}

	func checkForPath() -> Bool {
		guard !FileManager.default.fileExists(atPath: pactDir) else {
			return true
		}
		debugPrint("Path not found: \(pactDir)")
		return canCreatePath()
	}

	func canCreatePath() -> Bool {
		var canCreate = false
		do {
			try FileManager.default.createDirectory(
				atPath: self.pactDir,
				withIntermediateDirectories: true,
				attributes: nil
			)
			canCreate.toggle()
		} catch let error as NSError {
			debugPrint("Files not written. Path could not be created: \(self.pactDir)")
			debugPrint(error.localizedDescription)
		}
		return canCreate
	}

}
