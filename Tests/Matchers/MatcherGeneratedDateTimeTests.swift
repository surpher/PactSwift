//
//  Created by Marko Justinek on 18/9/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherGeneratedDateTimeTests: MatcherTestCase {

    func testGeneratedDate_SerializesToJSON() throws {
        let json = try jsonString(for: .generatedDate("2023-01-09", format: "yyyy-MM-dd", expression: "today"))

        XCTAssertEqual(
            json,
            #"""
            {
              "expression" : "today",
              "format" : "yyyy-MM-dd",
              "pact:generator:type" : "Date",
              "pact:matcher:type" : "type",
              "value" : "2023-01-09"
            }
            """#
        )
    }

    func testGeneratedTime_SerializesToJSON() throws {
        let json = try jsonString(for: .generatedTime("14:34:12", format: "HH:mm:ss", expression: "noon"))

        XCTAssertEqual(
            json,
            #"""
            {
              "expression" : "noon",
              "format" : "HH:mm:ss",
              "pact:generator:type" : "Time",
              "pact:matcher:type" : "type",
              "value" : "14:34:12"
            }
            """#
        )
    }

    func testGeneratedDatetime_SerializesToJSON() throws {
        let json = try jsonString(for: .generatedDatetime("2023-01-09 14:34:12", format: "yyyy-MM-dd HH:mm:ss", expression: "today"))

        XCTAssertEqual(
            json,
            #"""
            {
              "expression" : "today",
              "format" : "yyyy-MM-dd HH:mm:ss",
              "pact:generator:type" : "DateTime",
              "pact:matcher:type" : "type",
              "value" : "2023-01-09 14:34:12"
            }
            """#
        )
    }
}
