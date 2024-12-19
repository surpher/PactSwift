//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation
@_exported import PactSwiftMockServer

public extension QueryBuilder {

    @discardableResult
    func queryParam(_ name: String, matching: AnyMatcher) throws -> Self {
        let valueString = try String(data: JSONEncoder().encode(matching), encoding: .utf8)!
        return try queryParam(name: name, values: [valueString])
    }

    /// Configures a query parameter for the ``Interaction``.
    ///
    /// - Throws: ``Interaction/Error`` when the interaction or Pact can't be modified (i.e. the mock server for it has already started).
    /// - Parameters:
    ///  - name: The query parameter name.
    ///  - value: The query parameter value.
    @discardableResult
    func queryParam(_ name: String, value: String) throws -> Self {
        try queryParam(name: name, values: [value])
    }

    /// Configures a query parameters for the ``Interaction``.
    ///
    /// - Throws: ``Interaction/Error`` when the interaction or Pact can't be modified (i.e. the mock server for it has already started).
    /// - Parameters:
    ///  - name: The query parameter name.
    ///  - value: The query parameter value.
    @discardableResult
    func queryParams(_ items: [URLQueryItem]) throws -> Self {
        for item in items {
            guard let value = item.value else {
                continue
            }

            try queryParam(item.name, value: value)
        }

        return self
    }
}
