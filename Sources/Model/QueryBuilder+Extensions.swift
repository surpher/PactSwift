//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation
@_exported import PactSwiftMockServer

public extension QueryBuilder {

    /// Configures a query parameter for the ``Interaction``.
    ///
    /// - Parameters:
    ///  - name: The query parameter name.
    ///  - matching: Pact matcher.
    ///
    /// - Throws: ``Interaction.Error`` when the interaction or Pact can't be modified (i.e. the mock server for it has already started).
    @discardableResult
    internal func queryParam(_ name: String, matching: AnyMatcher) throws -> Self {
        let matcher = try queryParameterSafe(matching)
        let valueString = try String(data: JSONEncoder().encode(matcher), encoding: .utf8)!

        return try queryParam(name: name, values: [valueString])
    }

    /// Configures a query parameter for the ``Interaction``.
    ///
    /// - Parameters:
    ///  - name: The query parameter name.
    ///  - value: The query parameter value.
    ///
    /// - Throws: ``Interaction.Error`` when the interaction or Pact can't be modified (i.e. the mock server for it has already started).
    @discardableResult
    func queryParam(_ name: String, value: String) throws -> Self {
        try queryParam(name: name, values: [value])
    }

    /// Configures a query parameters for the ``Interaction``.
    ///
    /// - Parameters:
    ///  - name: The query parameter name.
    ///  - value: The query parameter value.
    ///
    /// - Throws: ``Interaction.Error`` when the interaction or Pact can't be modified (i.e. the mock server for it has already started).
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

// MARK: - Private

private extension QueryBuilder {

    /// Converts the matcher type to `String` type matcher.
    ///
    /// URL query parameters are always string values and will always have the same type, `String`.
    func queryParameterSafe(_ matcher: AnyMatcher) throws -> AnyMatcher {

        // Handle Bool matcher
        if let matcher = matcher.matcher as? GenericMatcher<Bool> {
            return GenericMatcher(type: .string, value: String(matcher.value)).asAny()
        }

        // Handle String matcher
        if
            let matcher = matcher.matcher as? GenericMatcher<String>,
            isSupported(matcher: matcher) {
            return matcher.asAny()
        }

        // Handle Number matcher (Int)
        if let matcher = matcher.matcher as? GenericMatcher<Int> {
            // maybe I need to do something with .type matcher?
            return asAnyMatcher(matcher.value)
        }

        // Handle Number matcher (Int8)
        if let matcher = matcher.matcher as? GenericMatcher<Int8> {
            return asAnyMatcher(matcher.value)
        }

        // Handle Number matcher (Int16)
        if let matcher = matcher.matcher as? GenericMatcher<Int16> {
            return asAnyMatcher(matcher.value)
        }

        // Handle Number matcher (Int32)
        if let matcher = matcher.matcher as? GenericMatcher<Int32> {
            return asAnyMatcher(matcher.value)
        }

        // Handle Number matcher (Int64)
        if let matcher = matcher.matcher as? GenericMatcher<Int64> {
            return asAnyMatcher(matcher.value)
        }

        // Handle Number matcher (UInt)
        if let matcher = matcher.matcher as? GenericMatcher<UInt> {
            return asAnyMatcher(matcher.value)
        }

        // Handle Number matcher (UInt8)
        if let matcher = matcher.matcher as? GenericMatcher<UInt8> {
            return asAnyMatcher(matcher.value)
        }

        // Handle Number matcher (UInt16)
        if let matcher = matcher.matcher as? GenericMatcher<UInt16> {
            return asAnyMatcher(matcher.value)
        }

        // Handle Number matcher (UInt32)
        if let matcher = matcher.matcher as? GenericMatcher<UInt32> {
            return asAnyMatcher(matcher.value)
        }

        // Handle Number matcher (UInt64)
        if let matcher = matcher.matcher as? GenericMatcher<UInt64> {
            return asAnyMatcher(matcher.value)
        }

        // Handle Number matcher (Double)
        if let matcher = matcher.matcher as? GenericMatcher<Double> {
            return asAnyMatcher(matcher.value)
        }

        // Handle Number matcher (Decimal)
        if let matcher = matcher.matcher as? GenericMatcher<Decimal> {
            return GenericMatcher(type: .type, value: "\(matcher.value)").asAny()
        }

        // Handle Number matcher (Float)
        if let matcher = matcher.matcher as? GenericMatcher<Float> {
            return asAnyMatcher(matcher.value)
        }

        // Anything else is deemed unsupported
        try Logger.log(message: "Unsupported matcher used in a query parameter.", data: JSONEncoder().encode(matcher))

        throw PactSwiftError.notImplemented
    }

    func asAnyMatcher<T: Numeric>(_ value: T) -> AnyMatcher {
        GenericMatcher(type: .regex, value: "\(value)", regex: #"^[+-]?([0-9]*\.[0-9]+|[0-9]+\.[0-9]*)$"#).asAny()
    }

    func asAnyMatcher<T: BinaryInteger>(_ value: T) -> AnyMatcher {
        GenericMatcher(type: .regex, value: String(value), regex: "-?\\d+").asAny()
    }

    func asAnyMatcher<T: BinaryFloatingPoint>(_ value: T) -> AnyMatcher {
        GenericMatcher(type: .regex, value: "\(value)", regex: #"^[+-]?([0-9]*\.[0-9]+|[0-9]+\.[0-9]*)$"#).asAny()
    }

    func isSupported(matcher: GenericMatcher<String>) -> Bool {
        let unsupportedMatchers = [
            MatcherType.semVer,
            .statusCode,
            .time,
            .timestamp,
            .date,
            .include,
        ]

        return unsupportedMatchers.contains(matcher.type) == false
    }
}
