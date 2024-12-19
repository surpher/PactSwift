//
//  Created by Marko Justinek on 18/9/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherRandomDecimalTests: MatcherTestCase {

    func testRandomDecimal_SerializesToJSON() throws {
        let json = try jsonString(for: .randomDecimal(like: 12.23, digits: 10))

        XCTAssertEqual(
            json,
            #"""
            {
              "digits" : 10,
              "pact:generator:type" : "RandomDecimal",
              "pact:matcher:type" : "type",
              "value" : 12.23
            }
            """#
        )
    }
}
