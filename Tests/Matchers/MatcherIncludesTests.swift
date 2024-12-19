//
//  Created by Marko Justinek on 26/5/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherIncludesTests: MatcherTestCase {

    func testMatcher_Includes_SerializesToJSON() throws {
        let json = try jsonString(for: .includes("test"))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "include",
              "value" : "test"
            }
            """#
        )
    }

}
