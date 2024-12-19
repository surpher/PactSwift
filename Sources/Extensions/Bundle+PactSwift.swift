//
//  Created by Marko Justinek on 1/4/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation

extension Bundle {

    static var pact: Bundle? {
        #if os(iOS)
            return Bundle(identifier: "au.com.pact-foundation.iOS.PactSwift")
        #elseif os(macOS)
            return Bundle(identifier: "au.com.pact-foundation.macOS.PactSwift")
        #else
            return nil
        #endif
    }

    var shortVersion: String? {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

}
