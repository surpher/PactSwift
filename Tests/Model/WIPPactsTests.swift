//
//  Created by Marko Justinek on 28/8/21.
//  Copyright © 2021 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

@testable import PactSwift

final class WIPPactsTests: XCTestCase {

    func testWIPPactsInitializesWithDate() {
        let testDate = Date()
        let testSubject = WIPPacts(since: testDate, providerVersion: "test")

        XCTAssertEqual(testSubject.sinceDate, testDate)
    }

    func testWIPPactsInitializesWithProviderVersion() {
        let testSubject = WIPPacts(since: Date(), providerVersion: "test")

        XCTAssertEqual(testSubject.providerVersion, "test")
    }

}
