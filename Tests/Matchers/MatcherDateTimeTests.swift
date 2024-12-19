//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherDateTimeTests: MatcherTestCase {

    func testMatcher_Timestamp_SerializesToJSON() throws {
        let json = try jsonString(for: .datetime("2023-01-09 14:31:11", format: "yyyy-MM-dd HH:mm:ss"))

        XCTAssertEqual(
            json,
            #"""
            {
              "format" : "yyyy-MM-dd HH:mm:ss",
              "pact:matcher:type" : "timestamp",
              "value" : "2023-01-09 14:31:11"
            }
            """#
        )
    }

    func testMatcher_Date_SerializesToJSON() throws {
        let json = try jsonString(for: .date("2023-01-09", format: "yyyy-MM-dd"))

        XCTAssertEqual(
            json,
            #"""
            {
              "format" : "yyyy-MM-dd",
              "pact:matcher:type" : "date",
              "value" : "2023-01-09"
            }
            """#
        )
    }

    func testMatcher_Time_SerializesToJSON() throws {
        let json = try jsonString(for: .time("14:31:11", format: "HH:mm:ss"))

        XCTAssertEqual(
            json,
            #"""
            {
              "format" : "HH:mm:ss",
              "pact:matcher:type" : "time",
              "value" : "14:31:11"
            }
            """#
        )
    }
}
