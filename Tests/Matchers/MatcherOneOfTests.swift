//
//  Created by Marko Justinek on 9/7/21.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherOneOfTests: MatcherTestCase {

    func testMatcher_OneOf() throws {
        let json = try jsonString(for: .oneOf(["enabled", "disabled"]))

        let jsonData = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode([String: String].self, from: jsonData)

        XCTAssertEqual(decoded["pact:matcher:type"], "regex")
        XCTAssertEqual(decoded["regex"], "^(disabled|enabled)$")

        let value = try XCTUnwrap(decoded["value"])
        XCTAssertTrue(
            ["disabled", "enabled"].contains(value),
            "Expected value to be either 'disabled' or 'enabled', but got '\(value)'!"
        )
    }
}
