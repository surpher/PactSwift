//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

class MatcherTestCase: XCTestCase {

    var encoder: JSONEncoder!

    override func setUpWithError() throws {
        try super.setUpWithError()

        encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
    }

    override func tearDownWithError() throws {
        encoder = nil
        try super.tearDownWithError()
    }

    func jsonString(for matcher: AnyMatcher) throws -> String {
        let data = try encoder.encode(matcher)
        return try XCTUnwrap(String(data: data, encoding: .utf8))
    }

}
