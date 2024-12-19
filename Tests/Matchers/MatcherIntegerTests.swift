//
//  Created by Marko Justinek on 11/4/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherIntegerTests: MatcherTestCase {

    func testMatcher_Integer_SerializesToJSON() throws {
        let json = try jsonString(for: .integer(1234))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "integer",
              "value" : 1234
            }
            """#
        )
    }

}
