//
//  VerificationError.swift
//  PactSwiftServices
//
//  Created by Marko Justinek on 14/4/20.
//  Copyright © 2020 Pact Foundation. All rights reserved.
//

import Foundation

public enum VerificationError: Error {

	case unknown(String?)
	case missmatch(String)
	case writeError(Int)
	case serverNotFound

	init(code: Int, message: String?) {
		switch code {
		case 2: self = .writeError(code)
		case 3: self = .serverNotFound
		default: self = .unknown(message)
		}
	}

	// MARK: -

	var description: String {
		switch self {
		case .unknown(let message): return describing("\(message ?? "unknown")")
		case .missmatch(let message): return describing("\(message)")
		case .writeError(let code) where code == 3: return describing("Pact file failed to write to disk - \(mockServerNotFoundMessage)")
		case .writeError: return describing("Pact file failed to write on disk.")
		case .serverNotFound: return describing(mockServerNotFoundMessage)
		}
	}

	// MARK: - Private

	private var mockServerNotFoundMessage: String {
		"Mock Server not found on expected socked address/port"
	}

	private func describing(_ message: String) -> String {
		["Failed to verify Pact:", message].joined(separator: " ")
	}

}
