//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherSemverTests: MatcherTestCase {

    func testMatcher_MatchSemver() throws {
        let json = try jsonString(for: .semver("1.2.3"))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "semver",
              "value" : "1.2.3"
            }
            """#
        )
    }
}
