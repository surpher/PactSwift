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

enum VerificationErrorType: String {

	case missing = "Missing request"
	case notFound = "Unexpected request"
	case mismatch = "Request does not match"
	case mockServerParsingFailed = "Failed to parse Mock Server error response! Please report this as an issue at https://github.com/surpher/pact-swift/issues/new. Provide this test as an example to help us debug and improve this framework." //swiftlint:disable:this line_length
	case unknown = "Not entirely sure what happened! Please report this as an issue at https://github.com/surpher/pact-swift/issues/new. Provide this test as an example to help us debug and improve this framework." //swiftlint:disable:this line_length

	init(_ type: String) {
		switch type {
		case "missing-request":
			self = .missing
		case "request-not-found":
			self = .notFound
		case "request-mismatch":
			self = .mismatch
		case "mock-server-parsing-fail":
			self = .mockServerParsingFailed
		default:
			self = .unknown
		}
	}

}
