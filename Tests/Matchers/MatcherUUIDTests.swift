//
//  Created by Marko Justinek on 31/1/2025.
//  Copyright © 2025 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

final class MatcherUUIDTests: MatcherTestCase {

    func testMatcher_uuid() throws {
        let uuid = UUID()
        let json = try jsonString(for: .uuid(uuid))

        XCTAssertEqual(
            json,
            """
            {
              "pact:matcher:type" : "regex",
              "regex" : "^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$",
              "value" : "\(uuid)"
            }
            """
        )
    }

}
