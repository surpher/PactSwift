//
//  Created by Marko Justinek on 29/1/25.
//  Copyright © 2025 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

class XCTFailCaptureTestCase: XCTestCase {

    var capturedMessage: String?

    override func record(_ issue: XCTIssue) {
        if issue.type == .assertionFailure {
            capturedMessage = issue.description
        }

        super.record(issue)
    }
}
