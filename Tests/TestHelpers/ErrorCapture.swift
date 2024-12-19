//
//  Created by Marko Justinek on 20/4/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

@testable import PactSwift

import Foundation

class ErrorCapture: ErrorReportable {

    public var error: ErrorReceived?

    func reportFailure(_ message: String) {
        self.error = ErrorReceived(message: message, file: nil, line: nil)
    }

    func reportFailure(_ message: String, file: FileString, line: UInt) {
        self.error = ErrorReceived(message: message, file: file, line: line)
    }
}
