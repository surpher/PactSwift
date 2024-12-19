//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherLikeTests: MatcherTestCase {

    func testMatcher_LikeEncodable_SerializesToJSON() throws {
        let json = try jsonString(for: .like(1234))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "type",
              "value" : 1234
            }
            """#
        )
    }

    func testMatcher_LikeArrayEncodable_SerializesToJSON() throws {
        let json = try jsonString(for: .like([1234, 5678]))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "type",
              "value" : [
                1234,
                5678
              ]
            }
            """#
        )
    }

    func testMatcher_LikeArrayEncodableMin_SerializesToJSON() throws {
        let json = try jsonString(for: .eachLike(1234, min: 1))

        XCTAssertEqual(
            json,
            #"""
            {
              "min" : 1,
              "pact:matcher:type" : "type",
              "value" : [
                1234
              ]
            }
            """#
        )
    }

    func testMatcher_LikeArrayEncodableMax_SerializesToJSON() throws {
        let json = try jsonString(for: .eachLike(1234, max: 2))

        XCTAssertEqual(
            json,
            #"""
            {
              "max" : 2,
              "pact:matcher:type" : "type",
              "value" : [
                1234
              ]
            }
            """#
        )
    }

    func testMatcher_LikeArrayEncodableMinMax_SerializesToJSON() throws {
        let json = try jsonString(for: .eachLike(1234, min: 1, max: 2))

        XCTAssertEqual(
            json,
            #"""
            {
              "max" : 2,
              "min" : 1,
              "pact:matcher:type" : "type",
              "value" : [
                1234
              ]
            }
            """#
        )
    }

    func testMatcher_LikeDictionaryEncodable_SerializesToJSON() throws {
        let json = try jsonString(for: .like(["a": 1234, "b": 5678]))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "type",
              "value" : {
                "a" : 1234,
                "b" : 5678
              }
            }
            """#
        )
    }

    func testMatcher_LikeDictionaryAnyMatcher_SerializesToJSON() throws {
        let json = try jsonString(for: .like(["a": .integer(1234), "b": .equals(5678)]))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "type",
              "value" : {
                "a" : {
                  "pact:matcher:type" : "integer",
                  "value" : 1234
                },
                "b" : {
                  "pact:matcher:type" : "equality",
                  "value" : 5678
                }
              }
            }
            """#
        )
    }

}
