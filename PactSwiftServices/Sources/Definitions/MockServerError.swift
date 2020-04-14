//
//  MockServerError.swift
//  PactSwiftServices
//
//  Created by Marko Justinek on 14/4/20.
//  Copyright © 2020 Pact Foundation. All rights reserved.
//

import Foundation

public enum MockServerError: Error {
	
	case nullPointer
	case invalidPactJSON
	case failedToStart
	case methodPanicked
	case invalidSocketAddress
	case unknown

	init(code: Int) {
		switch code {
		case -1: self = .nullPointer
		case -2: self = .invalidPactJSON
		case -3: self = .failedToStart
		case -4: self = .methodPanicked
		case -5: self = .invalidSocketAddress
		default: self = .unknown
		}
	}

	// MARK: -

	var description: String {
		switch self {
		case .nullPointer:
			return describing("Either Pact JSON or Socket Address passed as null pointer.")
		case .invalidPactJSON:
			return describing("Pact JSON could not be parsed.")
		case .failedToStart:
			return describing("Could not start.")
		case .methodPanicked:
			return describing("PactMockServer's method panicked.")
		case .invalidSocketAddress:
			return describing("Socket Address is invalid.")
		case .unknown:
			return describing("reason unknown!")
		}
	}

	// MARK: - Private

	private func describing(_ message: String) -> String {
		["Failed to start PactMockServer:", message].joined(separator: " ")
	}

}
