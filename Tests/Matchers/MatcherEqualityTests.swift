//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherEqualityTests: MatcherTestCase {

    func testMatcher_EqualityString_SerializesToJSON() throws {
        let json = try jsonString(for: .equals("test"))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "equality",
              "value" : "test"
            }
            """#
        )
    }

    func testMatcher_EqualityInteger_SerializesToJSON() throws {
        let json = try jsonString(for: .equals(1234))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "equality",
              "value" : 1234
            }
            """#
        )
    }

    func testMatcher_EqualityArray_SerializesToJSON() throws {
        let json = try jsonString(for: .equals(["one", "two"]))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "equality",
              "value" : [
                "one",
                "two"
              ]
            }
            """#
        )
    }

    func testMatcher_EmptyArray_SerializesToJSON() throws {
        // We discard whitespace lines here to work around issue where Xcode is causing whitespace issues in string literal below.
        let json = try jsonString(for: .emptyArray())
            .split(separator: "\n")
            .filter { $0.isEmpty == false }
            .joined(separator: "\n")

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "equality",
              "value" : [
              ]
            }
            """#
        )
    }
}
