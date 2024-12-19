//
//  Created by Marko Justinek on 9/7/21.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherOneOfTests: MatcherTestCase {

    // TODO: - This test is disabled due to being fragile - it randomly assigns the value of key `"$.value"`!
    func testMatcher_OneOf() throws {
        let json = try jsonString(for: .oneOf(["enabled", "disabled"]))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "regex",
              "regex" : "^(disabled|enabled)$",
              "value" : "disabled"
            }
            """#
        )
    }
}
