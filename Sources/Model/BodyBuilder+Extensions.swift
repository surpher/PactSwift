//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation
@_exported import PactSwiftMockServer

public extension BodyBuilder {

    /// Add a null body with the specified `contentType` (defaults to `text/plain`).
    @discardableResult
    func nullBody(contentType: String? = "text/plain") throws -> Self {
        try body(nil, contentType: contentType)
    }

    /// Adds a json body to the ``Interaction``.
    @discardableResult
    func jsonBody(_ bodyString: String? = nil, contentType: String = "application/json") throws -> Self {
        try body(bodyString, contentType: contentType)
    }

    /// Adds a json body to the ``Interaction``.
    @discardableResult
    func jsonBody(_ example: AnyMatcher, contentType: String = "application/json") throws -> Self {
        let bodyString = String(data: try JSONEncoder().encode(example), encoding: .utf8)
        return try body(bodyString, contentType: contentType)
    }

    /// Adds a HTML body to the ``Interaction``.
    @discardableResult
    func htmlBody(_ bodyString: String? = nil, contentType: String = "text/html") throws -> Self {
        try body(bodyString, contentType: contentType)
    }
}
