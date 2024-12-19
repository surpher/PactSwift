//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherNumberTests: MatcherTestCase {

    func testMatcher_NumberWithDecimals_SerializesToJSON() throws {
        let json = try jsonString(for: .number(1234.78))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "number",
              "value" : 1234.78
            }
            """#
        )
    }

    func testMatcher_Number_SerializesToJSON() throws {
        let json = try jsonString(for: .number(1234))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "number",
              "value" : 1234
            }
            """#
        )
    }
}
