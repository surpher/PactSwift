//
//  Created by Marko Justinek on 11/4/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherDecimalTests: MatcherTestCase {

    func testMatcher_DecimalNoFraction_SerializesToJSON() throws {
        let json = try jsonString(for: .decimal(1234))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "decimal",
              "value" : 1234
            }
            """#
        )
    }

    func testMatcher_Decimal_SerializesToJSON() throws {
        let json = try jsonString(for: .decimal(1234.78))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "decimal",
              "value" : 1234.78
            }
            """#
        )
    }
}
