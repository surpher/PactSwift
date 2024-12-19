//
//  Created by Marko Justinek on 23/8/21.
//  Copyright © 2021 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation

public extension ProviderVerifier {

    // A bridge to PactSwiftMockServer provider verification errors
    enum VerificationError: Error {
        case error(String)
    }

}
