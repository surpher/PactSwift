//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherBooleanTests: MatcherTestCase {

    func testMatcher_MatchBoolean() throws {
        let json = try jsonString(for: .bool(true))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "boolean",
              "value" : true
            }
            """#
        )
    }
}
