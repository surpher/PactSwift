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

	lazy private var port: Int32 = {
		unusedPort()
	}()

	public var baseUrl: String {
		"http://\(socketAddress):\(port)"
	}

	private let socketAddress = "0.0.0.0"

	public init() { }

	deinit {
		shutdownMockServer()
	}

	// MARK: - Interface

	/// Prepare the Pact Mock Server with expected interactions

	// TODO: - This should probably be part of an init()
	// asking for baseUrl before calling setup() might cause some unexpected behaviour
	public func setup(pact: Data, completion: (Result<Int, MockServerError>) -> Void) {
		port = create_mock_server(
			strdup(String(data: pact, encoding: .utf8)),
			"\(socketAddress):\(port)"
		)

		return (port > 1200)
			? completion(Result.success(Int(port)))
			: completion(Result.failure(MockServerError(code: Int(port))))
	}

	/// Verify interactions
	public func verify(completion: (Result<Bool, VerificationError>) -> Void) {
		guard requestsMatched else {
			completion(.failure(.missmatch(mismatchDescription)))
			return
		}

		completion(.success(true))
	}

	/// Finalise by writing the contract file onto disk
	public func finalize(completion: (Result<String, VerificationError>) -> Void) {
		writePactContractFile {
			switch $0 {
			case .success:
				completion(.success("Pact contract written to \(pactDir). 👍"))
			case .failure(let error):
				completion(.failure(error))
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
			return "Nothing received"
		}

		return String(cString: mismatches)
	}

	/// Writes the PACT contract file to disk
	func writePactContractFile(completion: (Result<Void, VerificationError>) -> Void) {
		let result = write_pact_file(port, pactDir)
		guard result == 0 else {
			completion(Result.failure(.writeError(Int(result))))
			return
		}
		completion(Result.success(()))
	}

	func shutdownMockServer() {
		if port > 0 { cleanup_mock_server(port) }
	}

}

// TODO: - This is horrible. Need to put it away somewhere as a reusable component
private extension MockServer {

	var pactDir: String {
		ProcessInfo.processInfo.environment["pact_dir"] ?? "/tmp/pacts"
	}

	func checkForPath() -> Bool {
		guard !FileManager.default.fileExists(atPath: pactDir) else {
			return true
		}
		debugPrint("notify: Path not found: \(pactDir)")
		return couldCreatePath()
	}

	func couldCreatePath() -> Bool {
		var couldBeCreated = false
		do {
			try FileManager.default.createDirectory(
				atPath: self.pactDir,
				withIntermediateDirectories: false,
				attributes: nil
			)
			couldBeCreated = true
		} catch let error as NSError {
			debugPrint("notify: Files not written. Path couldn't be created: \(self.pactDir)")
			debugPrint(error.localizedDescription)
		}
		return couldBeCreated
	}

}
