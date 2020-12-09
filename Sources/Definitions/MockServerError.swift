//
//  Created by Marko Justinek on 14/4/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
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
	
	case invalidPactJSON
	case invalidSocketAddress
	case failedToStart
	case failedToWriteFile
	case methodPanicked
	case nullPointer
	case portNotFound
	case validationFaliure
	case unknown

	init(code: Int) {
		switch code {
		case 2: self = .failedToWriteFile
		case 3: self = .portNotFound
		case -1: self = .nullPointer
		case -2: self = .invalidPactJSON
		case -3: self = .failedToStart
		case 1, -4: self = .methodPanicked
		case -5: self = .invalidSocketAddress
		case 999: self = .validationFaliure
		default: self = .unknown
		}
	}

	// MARK: -

	public var description: String {
		switch self {
		case .invalidPactJSON:
			return describing("Pact JSON could not be parsed.")
		case .invalidSocketAddress:
			return describing("Socket Address is invalid.")
		case .failedToStart:
			return describing("Could not start.")
		case .failedToWriteFile:
			return describing("Failed to write Pact contract to file.")
		case .methodPanicked:
			return describing("PactMockServer's method panicked.")
		case .nullPointer:
			return describing("Either Pact JSON or Socket Address passed as null pointer.")
		case .portNotFound:
			return describing("Mock Server with specified port not running.")
		case .validationFaliure:
			return describing("Interactions failed to verify successfully. Check your tests.")
		case .unknown:
			return describing("Reason unknown!")
		}
	}

	// MARK: - Private

	private func describing(_ message: String) -> String {
		["Mock Server Error:", message].joined(separator: " ")
	}

}
