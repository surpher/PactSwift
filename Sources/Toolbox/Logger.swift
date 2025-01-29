//
//  Created by Marko Justinek on 9/8/2022.
//  Copyright © 2022 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation
import os.log

enum Logger {

    /// Logs Pact related messages.
    ///
    /// Looks for environment variable `PACT_ENABLE_LOGGING = "all"`.
    /// Can be set in project's scheme. Uses `os_log` on Apple platforms.
    ///
    /// - Parameters:
    ///    - message: The message to log
    ///    - data: Data to log
    ///
    static func log(message: String, data: Data? = nil) {
        guard case .all = PactLoggingLevel(value: ProcessInfo.processInfo.environment["PACT_ENABLE_LOGGING"]) else {
            return
        }

        let stringData = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""

        if #available(iOS 10, OSX 10.14, *) {
            os_log(
                "PactSwift: %{private}s",
                log: .default,
                type: .default,
                "\(message): \(stringData)"
            )
        } else {
            print(message: "PactSwift: \(message)\n\(stringData)")
        }
    }

}

// MARK: - Private

private extension Logger {

    static func print(message: String) {
        debugPrint(message)
    }

    enum PactLoggingLevel: String {
        case all
        case disabled

        init(value: String?) {
            switch value {
            case "all": self = .all
            default: self = .disabled
            }
        }
    }

}
