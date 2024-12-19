//
//  Created by Oliver Jones on 16/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

@available(macOS 13, *)
class UUIDFormatTests: XCTestCase {

    func testExampleMatchesRegex() throws {
        for format in UUIDFormat.allCases {
            let regex = try Regex(format.matchingRegex)
            let match = try XCTUnwrap(format.example.wholeMatch(of: regex))
            XCTAssertFalse(match.isEmpty)
        }
    }

    func testExampleMatchesRegex_Negative() throws {
        for format in UUIDFormat.allCases {
            let regex = try Regex(format.matchingRegex)
            let match = "not a uuid".wholeMatch(of: regex)
            XCTAssertNil(match)
        }
    }
}
