//
//  Created by Marko Justinek on 20/4/20.
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

struct VerificationErrorHandler {

	private let errors: [PactError]

	init(mismatches: String) {
		let mismatchData = mismatches.data(using: .utf8)

		do {
			self.errors = try JSONDecoder().decode(
				[PactError].self,
				from: mismatchData ?? "[{\"type\":\"Unsupported Pact Error Message\"}]".data(using: .utf8)!
			)
		} catch {
			self.errors = [PactError(type: "mock-server-parsing-fail", method: "", path: "", request: nil, mismatches: nil)]
		}
	}

	var description: String {
		var expectedRequest: String = ""
		var actualRequest: String = ""
		var errorReason: String = ""

		errors.forEach { error in //swiftlint:disable:this closure_body_length
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
						return "\($0.parameter ?? "unknown_parameter")=" + "\($0.expected.expectedString)"
					}
					return nil
				}
				.joined(separator: "&")

				let mismatches = error.mismatches?.compactMap {
						"\($0.parameter != nil ? "query param '" + $0.parameter! + "': " : "")"
					+ "\($0.mismatch != nil ? $0.mismatch! : "")"
					+ "\( MismatchErrorType(rawValue: $0.type)  == .body ? " - Body does not match the expected body definition" : "")"
				}
				.joined(separator: "\n\t")

				expectedRequest += "\(error.method) \(error.path)\(!(expectedQuery ?? "").isEmpty ? "?" + expectedQuery! : "")"
				actualRequest += "\(error.method) \(error.path)\(mismatches != nil ? "\n\t" + mismatches! : "")"
			default:
				expectedRequest += ""
				actualRequest += ""
			}
		}

		return """
		Actual request does not match expected interactions...

		Reason:\n\t\(errorReason)
		\(!expectedRequest.isEmpty ? "\nExpected:\n\t" + expectedRequest : "")
		\(!actualRequest.isEmpty ? "\nActual:\n\t" + actualRequest : "")
		"""
	}

}
