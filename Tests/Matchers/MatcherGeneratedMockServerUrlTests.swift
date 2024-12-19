//
//  Created by Marko Justinek on 18/9/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherGeneratedMockServerUrlTests: MatcherTestCase {

    func testGeneratedMockServerUrl_SerializesToJSON() throws {
        let json = try jsonString(for: .generatedMockServerUrl(example: "https://example.com/orders/1234", regex: #".*(/orders/\d+)$"#))

        XCTAssertEqual(
            json,
            #"""
            {
              "example" : "https://example.com/orders/1234",
              "pact:generator:type" : "MockServerURL",
              "pact:matcher:type" : "type",
              "regex" : ".*(/orders/\\d+)$",
              "value" : "https://example.com/orders/1234"
            }
            """#
        )
    }
}
