//
//  Created by Oliver Jones on 12/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation

// MARK: - Pact Specification v4 matchers

public extension Matcher {
    // TODO: "arrayContains"

    /// A matcher that matches the response status code.
    ///
    /// - Note: Requires `Pact.Specification.v4`.
    ///
    static func statusCode(_ statusCode: HTTPStatus) -> AnyMatcher {
        switch statusCode {
        case .information:
            return GenericMatcher(type: "statusCode", value: "information").asAny()
        case .success:
            return GenericMatcher(type: "statusCode", value: "success").asAny()
        case .redirect:
            return GenericMatcher(type: "statusCode", value: "redirect").asAny()
        case .clientError:
            return GenericMatcher(type: "statusCode", value: "clientError").asAny()
        case .serverError:
            return GenericMatcher(type: "statusCode", value: "serverError").asAny()
        case .nonError:
            return GenericMatcher(type: "statusCode", value: "nonError").asAny()
        case .error:
            return GenericMatcher(type: "statusCode", value: "error").asAny()
        case .statusCodes(let codes):
            return GenericMatcher(type: "statusCode", value: codes).asAny()
        }
    }

    /// A matcher that matches a value that must be present and not empty (not null or the empty string).
    ///
    /// - Note: Requires `Pact.Specification.v4`.
    ///
    static func notEmpty() -> AnyMatcher {
        GenericMatcher(type: "notEmpty", value: "non-empty").asAny()
    }

    /// A matcher that matches a value that must be valid based on the `semver` specification.
    ///
    /// - Note: Requires `Pact.Specification.v4`.
    ///
    /// - Parameters:
    ///   - value: An example value (eg: `"1.2.3"`)
    ///
    static func semver(_ value: String) -> AnyMatcher {
        GenericMatcher(type: "semver", value: value).asAny()
    }

    // TODO: "eachKey", "eachValue"
}
