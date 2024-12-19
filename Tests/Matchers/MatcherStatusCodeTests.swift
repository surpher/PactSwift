//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherStatusCodeTests: MatcherTestCase {

    func testMatcher_ClientError_SerializeAsJSON() throws {
        let json = try jsonString(for: .statusCode(.clientError))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "statusCode",
              "value" : "clientError"
            }
            """#
        )
    }

    func testMatcher_Codes_SerializeAsJSON() throws {
        let json = try jsonString(for: .statusCode(.statusCodes([200, 201])))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "statusCode",
              "value" : [
                200,
                201
              ]
            }
            """#
        )
    }

}
