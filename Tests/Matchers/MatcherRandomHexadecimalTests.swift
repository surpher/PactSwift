//
//  Created by Marko Justinek on 18/9/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherRandomHexadecimalTests: MatcherTestCase {

    func testRandomHexadecimal_SerializesToJSON() throws {
        let json = try jsonString(for: .randomHexadecimal(like: "DEADBEEF", digits: 8))

        XCTAssertEqual(
            json,
            #"""
            {
              "digits" : 8,
              "pact:generator:type" : "RandomHexadecimal",
              "pact:matcher:type" : "type",
              "value" : "DEADBEEF"
            }
            """#
        )
    }
}
