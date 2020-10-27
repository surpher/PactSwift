//
//  ToolboxTests.swift
//  PactSwift
//
//  Created by Marko Justinek on 27/10/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
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
