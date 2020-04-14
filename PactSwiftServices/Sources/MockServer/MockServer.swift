//
//  MockServer.swift
//  PactSwiftServices
//
//  Created by Marko Justinek on 12/4/20.
//  Copyright © 2020 Pact Foundation. All rights reserved.
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

	var baseUrl: String {
		"http://localhost:\(port)"
	}

	deinit {
		shutdownMockServer()
	}

	// MARK: - Interface

	/// Prepare the Pact Mock Server with expected interactions

	// TODO: - This should probably be part of an init()
	// asking for baseUrl before calling setup() might cause some unexpected behaviour
	func setup(pact: Data) -> Result<Int, MockServerError> {
		port = create_mock_server(
			strdup(String(data: pact, encoding: .utf8)),
			"0.0.0.0:\(port)"
		)

		return (port > 1200)
			? Result.success(Int(port))
			: Result.failure(MockServerError(code: Int(port)))
	}

	/// Verify interactions
	func verify() -> Result<String, VerificationError> {
		guard requestsMatched else {
			return Result.failure(.missmatch(mismatchDescription))
		}

		switch writePactContractFile() {
		case .success:
			return Result.success("Pact verified: OK")
		case .failure(let error):
			return Result.failure(error)
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
	func writePactContractFile() -> Result<Void, VerificationError> {
		let result = write_pact_file(port, pactDir)
		guard result == 0 else {
			return Result.failure(.writeError(Int(result)))
		}
		return Result.success(())
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
