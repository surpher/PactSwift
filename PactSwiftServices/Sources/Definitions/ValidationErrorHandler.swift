//
//  ValidationErrorHandler.swift
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

struct ValidationErrorHandler {

	private let errors: [PactError]

	init(mismatches: String) {
		let mismatchData = mismatches.data(using: .utf8)

		do {
			self.errors = try JSONDecoder().decode([PactError].self, from: mismatchData ?? "[{\"type\":\"Unsupported Pact Error Message\"}]".data(using: .utf8)!)
		} catch {
			self.errors = [PactError(type: error.localizedDescription, method: "-", path: "-", request: [:], mismatches: nil)]
		}
	}

	var description: String {
		var expectedRequest: String = ""
		var actualRequest: String = ""
		var errorReason: String = ""

		errors.forEach { error in
			errorReason = VerificationErrorType(error.type).rawValue

			switch VerificationErrorType(error.type) {
			case .missing:
				expectedRequest += "\(error.method) \(error.path)"
				actualRequest += ""
			case .notFound:
				expectedRequest += ""
				actualRequest += "\(error.method) \(error.path)"
			case .mismatch:
				let expectedQuery = error.mismatches?.compactMap {
					if MismatchErrorType(rawValue: $0.type) == .query {
						return "\($0.parameter ?? "unknown_parameter")=" + "\($0.expected)"
					}
					return nil
				}
				.joined(separator: "&")
				let mismatches = error.mismatches?.compactMap {
					"\($0.parameter != nil ? "query param '" + $0.parameter! + "': " : "")" + "\($0.mismatch != nil ? $0.mismatch! : "")"
					+ "\( MismatchErrorType(rawValue: $0.type)  == .body ? "Body in request does not match the expected body definition" : "")"
				}
				.joined(separator: "\n\t") //swiftlint:disable:this line_length

				expectedRequest += "\(error.method) \(error.path)\(expectedQuery != nil ? "?" + expectedQuery! : "")"
				actualRequest += "\(error.method) \(error.path)\(mismatches != nil ? "\n\t" + mismatches! : "")"
			default:
				expectedRequest += ""
				actualRequest += ""
			}
		}

		return """
		Actual request does not match expected interactions...

		Reason:
			\(errorReason)

		Expected:
			\(expectedRequest)
		
		Actual:
			\(actualRequest)
		"""
	}

}

struct PactError {

	let type: String
	let method: String
	let path: String
	let request: [String: String]
	let mismatches: [MismatchError]?

}

extension PactError: Decodable {

	enum CodingKeys: String, CodingKey {
		case type
		case method
		case path
		case request
		case mismatches
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		type = try container.decode(String.self, forKey: .type)
		method = try container.decode(String.self, forKey: .method)
		path = try container.decode(String.self, forKey: .path)
		request = [:]
		mismatches = try container.decodeIfPresent([MismatchError].self, forKey: .mismatches)
	}

}

struct MismatchError: Decodable {
	let type: String
	let expected: String
	let actual: String
	let parameter: String?
	let mismatch: String?
}

enum MismatchErrorType: String {
	case query
	case body
	case headers
	case unknown

	init(rawValue: String) {
		switch rawValue  {
		case "QueryMismatch": self = .query
		case "BodyTypeMismatch": self = .body
		default: self = .unknown
		}
	}
}

enum VerificationErrorType: String {
	case missing = "Missing request"
	case notFound = "Unexpected request"
	case mismatch = "Request does not match"
	case unknown = "Unknown"

	init(_ type: String) {
		switch type {
		case "missing-request":
			self = .missing
		case "request-not-found":
			self = .notFound
		case "request-mismatch":
			self = .mismatch
		default:
			self = .unknown
		}
	}
}
