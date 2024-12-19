//
//  Created by Marko Justinek on 18/9/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherRandomBooleanTests: MatcherTestCase {

    func testRandomBoolean_SerializesToJSON() throws {
        let json = try jsonString(for: .randomBoolean())

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:generator:type" : "RandomBoolean",
              "pact:matcher:type" : "type",
              "value" : true
            }
            """#
        )
    }
}
