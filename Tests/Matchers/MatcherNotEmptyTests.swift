//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherNotEmptyTests: MatcherTestCase {

    func testMatcher_MatchNotEmpty() throws {
        let json = try jsonString(for: .notEmpty())

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "notEmpty",
              "value" : "non-empty"
            }
            """#
        )
    }
}
