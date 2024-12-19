//
//  Created by Oliver Jones on 12/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation

/// Type erasing wrapper around `any Matcher`.
public struct AnyMatcher: Matcher {

    var matcher: any Matcher

    public init(_ matcher: any Matcher) {
        self.matcher = matcher
    }

    public func encode(to encoder: Encoder) throws {
        try matcher.encode(to: encoder)
    }
}

extension Matcher {

    func asAny() -> AnyMatcher {
        AnyMatcher(self)
    }
}
