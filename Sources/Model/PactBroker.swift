//
//  Created by Marko Justinek on 19/8/21.
//  Copyright © 2021 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation

/// Pact broker configuration used when verifying a provider
public struct PactBroker {

    public enum Either<A, T> {
        case auth(A)
        case token(T)
    }

    /// Simple authentication with Pact Broker
    public struct SimpleAuth {
        let username: String
        let password: String

        /// Initializes authentication configuration store
        ///
        /// - Parameters:
        ///   - username: The username to use when authenticating with Pact Broker
        ///   - password: The password to use when authenticating with Pact Broker
        ///
        public init(username: String, password: String) {
            self.username = username
            self.password = password
        }
    }

    /// API token store for a Pact Broker (Pactflow)
    public struct APIToken {
        let token: String

        /// Initializes the Broker API token store
        ///
        /// - Parameters:
        ///   - token: The authorization token
        ///
        public init(_ token: String) {
            self.token = token
        }
    }

    /// Verification results handling
    public struct VerificationResults {
        let publishResults = true
        let providerVersion: String
        let providerTags: [String]?

        /// Initializes the VerificationResults object
        ///
        /// - Parameters:
        ///   - providerVersion: The semantical version of the Provider API
        ///   - providerTags: Provider tags to use when publishing results
        ///
        public init(providerVersion version: String, providerTags tags: [String]? = nil) {
            self.providerVersion = version
            self.providerTags = tags
        }
    }

    // MARK: - Properties

    /// The URL of Pact Broker for broker-based verification
    let url: String

    /// Pact Broker authentication
    let authentication: Either<SimpleAuth, APIToken>

    /// Whether to publish the verification results to the Pact Broker
    let publishVerificationResult: Bool

    /// The name of provider being verified
    let providerName: String

    /// Version of the provider being verified.
    ///
    /// Required when publishing results
    let providerVersion: String?

    /// Consumer tags to verify
    let consumerTags: [VersionSelector]?

    /// Provider tags to use when publishing results
    let providerTags: [String]?

    /// Includes pending pacts in verification
    let includePending: Bool?

    /// Include WIP pacts in verification
    let includeWIP: WIPPacts?

    // MARK: - Initialization

    /// Pact broker configuration
    ///
    /// - Parameters:
    ///   - url: The URL of Pact Broker
    ///   - auth: The authentication option
    ///   - providerName: The name of provider being verified
    ///   - consumerTags: List of consumer pacts to verify
    ///   - includePending: Include pending pacts in verification
    ///   - includeWIP: Allow pacts that don't match given consumer selectors (or tags) to be verified, without causing the overall task to fail
    ///   - verificationResults: When provided it submits the verification results with given provider version
    ///
    /// You should only submit verification results during CI builds. See [Pact broker](https://docs.pact.io/pact_broker) for more.
    ///
    /// Pending pacts and WIP pacts features are available on [Pactflow](https://pactflow.io/) by default,
    /// and requires [configuration](https://docs.pact.io/pact_broker/advanced_topics/wip_pacts/) if using a self-hosted broker.
    ///
    /// - Warning: When including WIP pacts, `includePending` will be set to `true`.
    ///
    public init(url: URL, auth: Either<SimpleAuth, APIToken>, providerName: String, consumerTags: [VersionSelector]? = nil, includePending: Bool? = nil, includeWIP: WIPPacts? = nil, publishResults verificationResults: VerificationResults? = nil) {
        self.url = url.absoluteString
        self.authentication = auth
        self.providerName = providerName

        self.consumerTags = consumerTags
        self.includePending = includePending
        self.includeWIP = includeWIP

        self.publishVerificationResult = verificationResults?.publishResults ?? false
        // Provider version is only required when publishing verification results
        self.providerVersion = verificationResults?.providerVersion
        self.providerTags = verificationResults?.providerTags
    }

}
