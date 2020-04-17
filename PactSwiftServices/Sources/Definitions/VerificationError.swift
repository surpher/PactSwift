//
//  VerificationError.swift
//  PactSwiftServices
//
//  Created by Marko Justinek on 14/4/20.
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

	public var description: String {
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
