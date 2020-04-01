//
//  MetadataTests.swift
//  PactSwiftTests
//
//  Created by Marko Justinek on 1/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import XCTest

@testable import PactSwift

class MetadataTests: XCTestCase {

	func testMetadata_SetsPactSwiftVersion() throws {
		let expectedResult = try XCTUnwrap(bundleVersion())
		let testResult = try XCTUnwrap(Metadata.values["metadata"]?["pact-swift"]?["version"])

		XCTAssertEqual(testResult, expectedResult)
	}

	func testMetadata_SetsPactSpecificationVersion() {
		XCTAssertEqual(Metadata.values["metadata"]?["pactSpecification"]?["version"] , "3.0.0")
	}

}

private extension MetadataTests {

	func bundleVersion() -> String? {
		Bundle(identifier: "au.com.pact-foundation.PactSwift")!.infoDictionary?["CFBundleShortVersionString"] as? String
	}

}
