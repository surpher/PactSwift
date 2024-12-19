//
//  Created by Oliver Jones on 12/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation

// MARK: - Pact Specification v1 matchers

public extension Matcher {

    /// A matcher that checks that the values are equal.
    ///
    /// - Note: Requires `Pact.Specification.v1`.
    /// - Parameters:
    ///   - value: The value to match with.
    ///
    static func equals<T: Encodable>(_ value: T) -> AnyMatcher {
        GenericMatcher(type: "equality", value: value).asAny()
    }

    static func emptyArray() -> AnyMatcher {
        equals([String]())
    }
}
