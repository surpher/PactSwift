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

    func testMatcher_StatusCodes() throws {
        let statusCodes: [HTTPStatus: String] = [
            HTTPStatus.information: "information",
            .success: "success",
            .redirect: "redirect",
            .clientError: "clientError",
            .serverError: "serverError",
            .nonError: "nonError",
            .error: "error"
        ]

        for (key, value) in statusCodes {
            let json = try jsonString(for: .statusCode(key))

            XCTAssertEqual(
                json,
                """
                {
                  "pact:matcher:type" : "statusCode",
                  "value" : "\(value)"
                }
                """
            )
        }
    }
}

// MARK: - Utilities

extension HTTPStatus: @retroactive Hashable, @retroactive Equatable {

    public static func == (lhs: HTTPStatus, rhs: HTTPStatus) -> Bool {
        switch (lhs, rhs) {
        case (.information, .information),
             (.success, .success),
             (.redirect, .redirect),
             (.clientError, .clientError),
             (.serverError, .serverError),
             (.nonError, .nonError),
             (.error, .error):
            return true
        case (.statusCodes(let lhsCodes), .statusCodes(let rhsCodes)):
            return lhsCodes == rhsCodes
        default:
            return false
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .information:
            hasher.combine(1)
        case .success:
            hasher.combine(2)
        case .redirect:
            hasher.combine(3)
        case .clientError:
            hasher.combine(4)
        case .serverError:
            hasher.combine(5)
        case .nonError:
            hasher.combine(6)
        case .error:
            hasher.combine(7)
        case .statusCodes(let codes):
            hasher.combine(8)
            hasher.combine(codes)
        }
    }
}
