//
//  Created by Marko Justinek on 18/9/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherRandomUUIDTests: MatcherTestCase {

    func testRandomUUID_SerializesToJSON() throws {
        let uuid = UUID()
        let json = try jsonString(for: .randomUUID(like: uuid))

        XCTAssertEqual(
            json,
            """
            {
              "format" : "upper-case-hyphenated",
              "pact:generator:type" : "Uuid",
              "pact:matcher:type" : "type",
              "value" : "\(uuid.uuidString)"
            }
            """
        )
    }

    func testRandomUUIDWithFormat_SerializesToJSON() throws {
        let json = try jsonString(for: .randomUUID(like: "936DA01f9abd4d9d80c702af85c822a8", format: .simple))

        XCTAssertEqual(
            json,
            """
            {
              "format" : "simple",
              "pact:generator:type" : "Uuid",
              "pact:matcher:type" : "type",
              "value" : "936DA01f9abd4d9d80c702af85c822a8"
            }
            """
        )
    }
}
