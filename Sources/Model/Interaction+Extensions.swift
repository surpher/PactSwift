//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation
@_exported import PactSwiftMockServer

public extension Interaction {

    /// Configures the request for the Interaction.
    /// - Throws: ``Error/canNotBeModified`` if the interaction or Pact can't be modified (i.e. the mock server for it has already started)
    /// - Parameters:
    ///   - method: The request method. Defaults to ``HTTPMethod/GET``.
    ///   - regex: The request path regex matcher.
    ///   - example: An example path.
    ///   - builder: A ``RequestBuilder`` closure.
    func withRequest(method: HTTPMethod = .GET, regex: String, example: String, builder: RequestBuilder = { _ in }) throws -> Self {
        try withRequest(
            method: method,
            path: String(data: JSONEncoder().encode(AnyMatcher.regex(regex, example: example)), encoding: .utf8)!,
            builder: builder
        )
    }

}
