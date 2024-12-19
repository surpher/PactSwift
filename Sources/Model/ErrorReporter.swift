//
//  Created by Marko Justinek on 20/4/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation
import XCTest

class ErrorReporter: ErrorReportable {

    /// Reports test failure in file and on line where this method is called
    func reportFailure(_ message: String) {
        XCTFail(message, file: #file, line: #line)
    }

    /// Reports test failure in provided file and on provided line
    func reportFailure(_ message: String, file: FileString, line: UInt) {
        XCTFail(message, file: file, line: line)
    }
}
