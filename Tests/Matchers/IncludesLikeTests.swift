//
//  Created by Marko Justinek on 26/5/20.
//  Copyright © 2020 Itty Bitty Apps Pty Ltd / PACT Foundation. All rights reserved.
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

class IncludesLikeTests: XCTestCase {

	func testInitsWith_ArrayArgument() throws {
		let testResult = Matcher.IncludesLike(["Foo", "Bar"], combine: .AND)

		XCTAssertEqual(testResult.rules.count, 2)
		XCTAssertEqual(try XCTUnwrap((testResult.value as Any) as? String), "Foo Bar")
	}

	func testInitsWith_VariadicArgument() throws {
		let testResult = Matcher.IncludesLike("Foo", "Bar", "Baz", combine: .OR)

		XCTAssertEqual(testResult.rules.count, 3)
		XCTAssertEqual(testResult.combine, .OR)
		XCTAssertEqual(try XCTUnwrap((testResult.value as Any) as? String), "Foo Bar Baz")
	}

	func testInitsWith_ArrayArgument_AndGeneratedValue() throws {
		let testResult = Matcher.IncludesLike(["I'm", "Teapot"], combine: .AND, generate: "I'm a little Teapot")

		XCTAssertEqual(testResult.rules.count, 2)
		XCTAssertEqual(testResult.combine, .AND)
		XCTAssertEqual(try XCTUnwrap((testResult.value as Any) as? String), "I'm a little Teapot")
	}

	func testInitsWith_VariadicArgument_AndGeneratedValue() throws {
		let testResult = Matcher.IncludesLike("Teapot", "I'm", combine: .AND, generate: "I'm a big Teapot")

		XCTAssertEqual(testResult.rules.count, 2)
		XCTAssertEqual(testResult.combine, .AND)
		XCTAssertEqual(try XCTUnwrap((testResult.value as Any) as? String), "I'm a big Teapot")
	}

}
