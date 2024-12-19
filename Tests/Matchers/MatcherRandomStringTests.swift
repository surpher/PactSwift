//
//  Created by Marko Justinek on 18/9/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherRandomStringTests: MatcherTestCase {

    func testRandomString_SerializesToJSON() throws {
        let json = try jsonString(for: .randomString(like: "example", size: 20))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:generator:type" : "RandomString",
              "pact:matcher:type" : "type",
              "size" : 20,
              "value" : "example"
            }
            """#
        )
    }
}
