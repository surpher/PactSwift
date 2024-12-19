//
//  Created by Marko Justinek on 18/9/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherRandomIntegerTests: MatcherTestCase {

    func testRandomInteger_SerializesToJSON() throws {
        let json = try jsonString(for: .randomInteger(like: 23, range: 20...30))

        XCTAssertEqual(
            json,
            #"""
            {
              "max" : 30,
              "min" : 20,
              "pact:generator:type" : "RandomInt",
              "pact:matcher:type" : "type",
              "value" : 23
            }
            """#
        )
    }
}
