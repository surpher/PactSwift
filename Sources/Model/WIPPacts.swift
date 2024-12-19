//
//  Created by Marko Justinek on 24/8/21.
//  Copyright © 2021 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation

/// The configuration used when verifying WIP pacts
public struct WIPPacts {

    /// The date from which the changed pacts are to be included
    let sinceDate: Date

    /// The provider
    let providerVersion: String

    /// Configuration for verifying WIP pacts
    ///
    /// - Parameters:
    ///   - since: The date from which the WIP pacts are to be included in verification
    ///   - providerVersion: The provider version being verified
    ///
    /// See [Work in Progress pacts](https://docs.pact.io/pact_broker/advanced_topics/wip_pacts/) for more

    /// - Warning: The `providerVersion` value set in the `VerificationResult` object is used if provided
    ///
    public init(since date: Date, providerVersion: String) {
        self.sinceDate = date
        self.providerVersion = providerVersion
    }
}
