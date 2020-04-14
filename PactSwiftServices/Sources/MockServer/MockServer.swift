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
	func verify() -> Result<String, Error> {
		return Result.success("TODO")
	}

}

private extension MockServer {

	/// Returns true if all requests have successfully matched
	func requestsMatched() -> Bool {
		mock_server_matched(port)
	}

	/// Returns a description of mismatching requests
	func requestMismatches() -> String {
		"Nothing received"
	}

	/// Writes the PACT contract file to disk
	func writePactContractFile() -> Int32 {
		-1
	}

}
