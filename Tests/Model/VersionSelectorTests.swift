//
//  Created by Marko Justinek on 28/8/21.
//  Copyright © 2021 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

@testable import PactSwift

import XCTest

final class VersionSelectorTests: XCTestCase {

    func testVersionSelectorInitializes() {
        let testSubject = VersionSelector(tag: "test-tag")

        XCTAssertEqual(testSubject.tag, "test-tag")
        XCTAssertNil(testSubject.fallbackTag)
        XCTAssertTrue(testSubject.latest)
        XCTAssertNil(testSubject.consumer)
    }

    func testVersionSelectorSetsFallbackTag() {
        let testSubject = VersionSelector(tag: "test-tag", fallbackTag: "fallback-tag")

        XCTAssertEqual(testSubject.tag, "test-tag")
        XCTAssertEqual(testSubject.fallbackTag, "fallback-tag")
    }

    func testVersionSelectorSetsLatest() {
        let testSubject = VersionSelector(tag: "test-tag", latest: false)

        XCTAssertFalse(testSubject.latest)
    }

    func testVersionSelectorSetsConsumer() {
        let testSubject = VersionSelector(tag: "test-tag", consumer: "api-consumer")

        XCTAssertEqual(testSubject.consumer, "api-consumer")
    }

    func testVersionSelectorJSONString() throws {
        let testSubject = try VersionSelector(tag: "test", fallbackTag: "main", latest: true, consumer: "api-consumer").toJSONString()

        XCTAssertTrue(testSubject.contains("\"tag\":\"test\""))
        XCTAssertTrue(testSubject.contains("\"fallbackTag\":\"main\""))
        XCTAssertTrue(testSubject.contains("\"latest\":true"))
        XCTAssertTrue(testSubject.contains("\"consumer\":\"api-consumer\""))
    }
}
