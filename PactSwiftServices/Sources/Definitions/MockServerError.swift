//
//  MockServerError.swift
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
