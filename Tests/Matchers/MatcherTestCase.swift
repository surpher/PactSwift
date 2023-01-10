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

import XCTest

@testable import PactSwift

class MatcherTestCase: XCTestCase {

	var encoder: JSONEncoder!
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		
		encoder = JSONEncoder()
		encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
	}
	
	override func tearDownWithError() throws {
		encoder = nil
		try super.tearDownWithError()
	}
	
	func jsonString(for matcher: AnyMatcher) throws -> String {
		let data = try encoder.encode(matcher)
		return try XCTUnwrap(String(data: data, encoding: .utf8))
	}
	
}
