//
//  Created by Marko Justinek on 19/8/21.
//  Copyright © 2021 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation

/// Provides a way to configure which pacts the provider verifies.
public struct VersionSelector: Codable, Equatable {

    // MARK: - Properties

    /// The name of the tag which applies to the pacticipant versions of the pacts to verify
    let tag: String

    /// Whether or not to verify only the pact that belongs to the latest application version
    let latest: Bool

    /// A fallback tag if a pact for the specified `tag` does not exist
    let fallbackTag: String?

    /// Filter pacts by the specified consumer
    ///
    /// When omitted, all consumers are included.
    let consumer: String?

    // MARK: - Initialization

    /// Defines a version configuration for which pacts the provider verifies
    ///
    /// - Parameters:
    ///   - tag: The version `tag` name of the consumer to verify
    ///   - fallbackTag: The version `tag` to use if the initial `tag` does not exist
    ///   - latest: Whether to verify only the pact belonging to the latest application version
    ///   - consumer: Filter pacts by the specified consumer
    ///
    /// See [https://docs.pact.io/selectors](https://docs.pact.io/selectors) for more context.
    ///
    public init(tag: String, fallbackTag: String? = nil, latest: Bool = true, consumer: String? = nil) {
        self.tag = tag
        self.fallbackTag = fallbackTag
        self.latest = latest
        self.consumer = consumer
    }

}

// MARK: - Internal

extension VersionSelector {

    /// Converts to JSON string
    ///
    /// - Returns: A `String` representing `ProviderVerifier` in JSON format
    ///
    func toJSONString() throws -> String {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(self)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw ProviderVerifier.VerificationError.error("Invalid consumer version selector specified: \(self)")
        }

        return jsonString
    }

}
