//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherValuesTests: MatcherTestCase {

    /* TODO: Disabled for the moment. Until I understand its use case.
    func testMatcher_Values_SerializesToJSON() throws {
        let json = try jsonString(for: .values(["a": "b", "c": "d"]))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "values",
              "value" : {
                "a" : "b",
                "c" : "d"
              }
            }
            """#
        )
    }
    */
}
