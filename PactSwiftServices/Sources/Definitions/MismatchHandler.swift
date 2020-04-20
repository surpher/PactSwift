//
//  MismatchHandler.swift
//  PactSwiftServices
//
//  Created by Marko Justinek on 20/4/20.
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

import Foundation

struct MismatchHandler {

	private let mismatches: Mismatch
	private let expectedRequest: String?

	init(mismatches: String, expectedRequest: String? = nil) {
		let mismatchData = mismatches.data(using: .utf8)

		do {
			let mismatchError = try JSONDecoder().decode([Mismatch].self, from: mismatchData ?? "unknown error".data(using: .utf8)!)

			self.mismatches = mismatchError.first ?? Mismatch(type: "unknown", method: "N/A", path: "N/A", request: [:])
			self.expectedRequest = expectedRequest
		} catch {
			fatalError("boo boo fixy")
		}
	}

	var description: String {
		var actualRequest: String
		
		switch MismatchType(mismatches.type) {
		case .missing: actualRequest = "-"
		case .unexpected: actualRequest = "\(mismatches.method) \(mismatches.path)"
		default: actualRequest = "N/A"
		}

		return """
		Pact verification error! Actual request does not match expected interactions...

		Reason:
			\(MismatchType(mismatches.type).rawValue)

		Expected:
			\(expectedRequest ?? "N/A")
		
		Actual:
			\(actualRequest)
		"""
	}

}

struct Mismatch {

	let type: String
	let method: String
	let path: String
	let request: [String: String]

}

extension Mismatch: Decodable {

	enum CodingKeys: String, CodingKey {
		case type
		case method
		case path
		case request
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		type = try container.decode(String.self, forKey: .type)
		method = try container.decode(String.self, forKey: .method)
		path = try container.decode(String.self, forKey: .path)
		request = [:]
	}

}

enum MismatchType: String {
	case missing = "Missing request"
	case unexpected = "Unexpected request"
	case unknown = "Unknown"

	init(_ type: String) {
		switch type {
		case "missing-request": self = .missing
		case "request-not-found": self = .unexpected
		default: self = .unknown
		}
	}
}
