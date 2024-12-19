//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherContentTypeTests: MatcherTestCase {

    /* TODO: Disabled for the moment. Until I understand its use case.
    func testMatcher_MatchContentType() throws {
        let json = try jsonString(for: .contentType("image/jpeg"))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "contentType",
              "value" : "image/jpeg"
            }
            """#
        )
    }
    */
}
