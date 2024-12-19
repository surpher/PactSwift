//
//  Created by Marko Justinek on 21/8/21.
//  Copyright © 2021 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation

public extension ProviderVerifier {

    /// The provider being verified
    struct Provider {

        /// The port of provider being verified
        let port: Int

        /// URL of the provider being verified
        let url: URL?

        /// The provider being verified
        public init(url: URL? = nil, port: Int) {
            self.url = url
            self.port = port
        }
    }

}
