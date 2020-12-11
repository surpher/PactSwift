//
//  ToolboxTests.swift
//  PactSwift
//
//  Created by Marko Justinek on 27/10/20.
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

import XCTest

@testable import PactSwift

class ToolboxTests: XCTestCase {

	func testMerge_ReturnsNil() {
		let testSubject = Toolbox.merge(body: nil, query: nil, header: nil, path: nil)

		XCTAssertNil(testSubject)
	}

	func testMerge_HandlesArguments() throws {
		let testBody = AnyEncodable("foo:body")
		let testQuery = AnyEncodable("foo:query")
		let testHeader = AnyEncodable("foo:header")

		let testSubject = Toolbox.merge(body: testBody, query: testQuery, header: testHeader, path: nil)
		let mergedObjectKeys = try XCTUnwrap(processAnyEncodable(object: testSubject as Any))

		let expectedObjectKeys = ["body", "query", "header"]
		XCTAssertTrue(
			expectedObjectKeys.allSatisfy { value in
				mergedObjectKeys.contains(value)
			}
		)
	}

	func testProcess_Throws_NonEncodable() {
		struct NonSupportedType {
			let some = "Uh oh!"
		}
		let nonSupportedType = NonSupportedType()

		do {
			_ = try Toolbox.process(element: nonSupportedType, for: .body)
			XCTFail("Should fail with EncodingError")
		} catch {
			XCTAssertTrue((error as Any) is EncodingError)
		}
	}

}

private extension ToolboxTests {

	func processAnyEncodable(object: Any) -> [String]? {
		switch object {
		case let dict as [String: Any]:
			var mergedKeys: [String] = []
			for key in dict.keys {
				mergedKeys.append(key)
			}
			return mergedKeys
		default:
			XCTFail("Should only expect a Dictionary<String: AnyEncodable> here as Toolbox.merge() should return it")
			return nil
		}
	}

}
