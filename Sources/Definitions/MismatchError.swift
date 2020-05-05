//
//  MismatchError.swift
//  PactSwiftServices
//
//  Created by Marko Justinek on 27/4/20.
//  Copyright © 2020 Itty Bitty Apps Pty Ltd / Pact Foundation. All rights reserved.
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

struct MismatchError: Decodable {

	let type: String
	let expected: Expected
	let actual: Actual
	let parameter: String?
	let mismatch: String?

}

// MARK: -

// This is only used to handle Mock Server's bug where it returns a String or an Array<Int> depending on the request. :|
struct Expected: Codable {

	let expectedString: String
	let expectedIntArray: [Int]

	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()

		do {
			expectedString = try container.decode(String.self)
			expectedIntArray = []
		} catch {
			expectedIntArray = try container.decode([Int].self)
			expectedString = expectedIntArray.map { "\($0)" }.joined(separator: ",")
		}
	}

}

struct Actual: Codable {

	let actualString: String
	let actualIntArray: [Int]

	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		do {
			actualString = try container.decode(String.self)
			actualIntArray = []
		} catch {
			actualIntArray = try container.decode([Int].self)
			actualString = actualIntArray.map { "\($0)" }.joined(separator: ",")
		}
	}

}
