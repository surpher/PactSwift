//
//  Created by Marko Justinek on 29/1/25.
//  Copyright © 2025 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

final class ErrorReporterTests: XCTFailCaptureTestCase {

    private var reporter: ErrorReporter!
    private let message = "Foo went Bar"

    override func setUp() {
        super.setUp()

        reporter = ErrorReporter()
    }

    override func tearDown() {
        reporter = nil

        super.tearDown()
    }

    // MARK: - Tests

    func testReportFailure() throws {
        XCTExpectFailure("Testing reporting a failure \(#function)") {
            reporter.reportFailure(message)
        }

        XCTAssertEqual(capturedMessage, "Assertion Failure at ErrorReporter.swift:15: failed - \(message)")
    }

    func testReportingFailureWithSource() throws {
        XCTExpectFailure("Testing reporting a failure \(#function)") {
            reporter.reportFailure(message, file: #file, line: #line)
        }

        XCTAssertEqual(capturedMessage, "Assertion Failure at ErrorReporterTests.swift:41: failed - \(message)")
    }
}
