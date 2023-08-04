//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
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
@_exported import PactSwiftMockServer

public extension BodyBuilder {

	/// Add a null body with the specified `contentType` (defaults to `text/plain`).
	@discardableResult
	func body(contentType: String? = "text/plain") throws -> Self {
		try body(nil, contentType: contentType)
	}

	/// Adds a json body to the ``Interaction``.
	@discardableResult
	func jsonBody(_ bodyString: String? = nil, contentType: String = "application/json") throws -> Self {
		try body(bodyString, contentType: contentType)
	}

	/// Adds a json body to the ``Interaction``.
	@discardableResult
	func jsonBody(_ example: AnyMatcher, contentType: String = "application/json") throws -> Self {
		let bodyString = String(data: try JSONEncoder().encode(example), encoding: .utf8)
		return try body(bodyString, contentType: contentType)
	}

	/// Adds a HTML body to the ``Interaction``.
	@discardableResult
	func htmlBody(_ bodyString: String? = nil, contentType: String = "text/html") throws -> Self {
		try body(bodyString, contentType: contentType)
	}
}
