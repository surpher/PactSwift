//
//  Created by Marko Justinek on 9/10/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherNullTests: MatcherTestCase {

    func testMatcher_MatchNull() throws {
        let json = try jsonString(for: .null())

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "null",
              "value" : null
            }
            """#
        )
    }
}
