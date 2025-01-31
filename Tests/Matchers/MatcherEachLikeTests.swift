//
//  Created by Marko Justinek on 31/1/2025.
//  Copyright © 2025 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

final class MatcherEachLikeTests: MatcherTestCase {

    func testMatcher_EachLike() throws {
        let json = try jsonString(
            for: .eachLike(
                [
                    "foo": .bool(false),
                    "bar": .like("Bar")
                ]
            )
        )

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "type",
              "value" : [
                {
                  "bar" : {
                    "pact:matcher:type" : "type",
                    "value" : "Bar"
                  },
                  "foo" : {
                    "pact:matcher:type" : "boolean",
                    "value" : false
                  }
                }
              ]
            }
            """#
        )
    }

    func testMatcher_EachLike_WithMin() throws {
        let json = try jsonString(
            for: .eachLike(
                [
                    "foo": .bool(true),
                    "bar": .like("Baz")
                ],
                min: 2
            )
        )

        XCTAssertEqual(
            json,
            #"""
            {
              "min" : 2,
              "pact:matcher:type" : "type",
              "value" : [
                {
                  "bar" : {
                    "pact:matcher:type" : "type",
                    "value" : "Baz"
                  },
                  "foo" : {
                    "pact:matcher:type" : "boolean",
                    "value" : true
                  }
                }
              ]
            }
            """#
        )
    }

    func testMatcher_EachLike_WithMax() throws {
        let json = try jsonString(
            for: .eachLike(
                [
                    "foo": .bool(true),
                    "bar": .like("Baz")
                ],
                max: 10
            )
        )

        XCTAssertEqual(
            json,
            #"""
            {
              "max" : 10,
              "pact:matcher:type" : "type",
              "value" : [
                {
                  "bar" : {
                    "pact:matcher:type" : "type",
                    "value" : "Baz"
                  },
                  "foo" : {
                    "pact:matcher:type" : "boolean",
                    "value" : true
                  }
                }
              ]
            }
            """#
        )
    }

    func testMatcher_EachLike_WithMinMax() throws {
        let json = try jsonString(
            for: .eachLike(
                [
                    "foo": .bool(true),
                    "bar": .like("Baz")
                ],
                min: 5,
                max: 10
            )
        )

        XCTAssertEqual(
            json,
            #"""
            {
              "max" : 10,
              "min" : 5,
              "pact:matcher:type" : "type",
              "value" : [
                {
                  "bar" : {
                    "pact:matcher:type" : "type",
                    "value" : "Baz"
                  },
                  "foo" : {
                    "pact:matcher:type" : "boolean",
                    "value" : true
                  }
                }
              ]
            }
            """#
        )
    }
}
