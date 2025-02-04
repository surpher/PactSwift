//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation
@_exported import PactSwiftMockServer

public extension HeaderBuilder {

    /// Set the `Content-Type` header.
    @discardableResult
    func contentType(_ contentType: String) throws -> Self {
        try header("Content-Type", value: contentType)
    }

    @discardableResult
    func header(_ name: String, value: String) throws -> Self {
        try header(name, value: value)
    }

    @discardableResult
    func header(_ name: String, matching: AnyMatcher) throws -> Self {
        let valueString = try String(data: JSONEncoder().encode(matching), encoding: .utf8)!
        return try header(name, value: valueString)
    }
}
