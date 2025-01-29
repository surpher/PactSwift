//
//  Created by Oliver Jones on 10/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

@testable import PactSwift

import XCTest

final class PactTests: XCTestCase {

    func testPactVersion() throws {
        let pact = Pact.init(consumer: "Foo", provider: "Bar")
        XCTAssertEqual(pact.ffi_version, "0.4.25")
    }
}
