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
import PactSwiftMockServer

public extension QueryBuilder {
	
	@discardableResult
	func queryParam(_ name: String, matching: AnyMatcher) throws -> Self {
		let valueString = try String(data: JSONEncoder().encode(matching), encoding: .utf8)!
		return try queryParam(name: name, values: [valueString])
	}
	
	/// Configures a query parameter for the ``Interaction``.
	///
	/// - Throws: ``Interaction/Error`` when the interaction or Pact can't be modified (i.e. the mock server for it has already started).
	/// - Parameters:
	///  - name: The query parameter name.
	///  - value: The query parameter value.
	@discardableResult
	func queryParam(_ name: String, value: String) throws -> Self {
		try queryParam(name: name, values: [value])
	}
	
	/// Configures a query parameters for the ``Interaction``.
	///
	/// - Throws: ``Interaction/Error`` when the interaction or Pact can't be modified (i.e. the mock server for it has already started).
	/// - Parameters:
	///  - name: The query parameter name.
	///  - value: The query parameter value.
	@discardableResult
	func queryParams(_ items: [URLQueryItem]) throws -> Self {
		for item in items {
			guard let value = item.value else {
				continue
			}
			
			try queryParam(item.name, value: value)
		}
		
		return self
	}
}
