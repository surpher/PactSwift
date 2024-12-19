//
//  Created by Marko Justinek on 11/4/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherRegexTests: MatcherTestCase {

    func testMatcher_Regex() throws {
        let json = try jsonString(for: .regex(#"\d{4}-\d{2}-\d{2}"#, example: "2020-11-04"))

        XCTAssertEqual(
            json,
            #"""
            {
              "pact:matcher:type" : "regex",
              "regex" : "\\d{4}-\\d{2}-\\d{2}",
              "value" : "2020-11-04"
            }
            """#
        )
    }

}
