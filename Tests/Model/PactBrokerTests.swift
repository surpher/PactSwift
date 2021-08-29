//
//  Created by Marko Justinek on 29/8/21.
//  Copyright © 2021 Marko Justinek. All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

import XCTest

@testable import PactSwift

class PactBrokerTests: XCTestCase {

	func testDoesNotSetPublishVerificationResults() {
		let testSubject = PactBroker(
			url: URL(string: "http://test.url")!,
			auth: .token(.init(token: "test-token")),
			providerName: "test provider",
			publishResults: nil
		)

		XCTAssertEqual(testSubject.url, "http://test.url")
		XCTAssertEqual(testSubject.providerName, "test provider")
		XCTAssertFalse(testSubject.publishVerificationResult)
		XCTAssertNil(testSubject.providerTags)
		XCTAssertNil(testSubject.includePending)
		XCTAssertNil(testSubject.includeWIP)

		guard case .token(let testToken) = testSubject.authentication else {
			XCTFail("Expected token authentication option")
			return
		}
		XCTAssertEqual(testToken.token, "test-token")
	}

	func testSetsPublishVerificationResultsDetails() throws {
		let testTags = ["test-tags", "dev-tag"]
		let testSubject = PactBroker(
			url: URL(string: "http://test.url/")!,
			auth: .token(.init(token: "test-token")),
			providerName: "test provider",
			publishResults: .init(providerVersion: "unit-test-version", providerTags: testTags)
		)

		XCTAssertTrue(testSubject.publishVerificationResult)
		XCTAssertTrue(try testTags.allSatisfy { try XCTUnwrap(testSubject.providerTags).contains($0) })
		XCTAssertNil(testSubject.includePending)
		XCTAssertNil(testSubject.includeWIP)
	}

	func testUsernamePasswordAuthOption() {
		let testSubject = PactBroker(
			url: URL(string: "http://some.pact.broker.url")!,
			auth: .auth(.init(username: "test-user", password: "test-pass")),
			providerName: "Test API Provider"
		)

		XCTAssertEqual(testSubject.url, "http://some.pact.broker.url")
		XCTAssertEqual(testSubject.providerName, "Test API Provider")
		guard case .auth(let testAuth) = testSubject.authentication else {
			XCTFail("Expected basic authentication option")
			return
		}
		XCTAssertEqual(testAuth.username, "test-user")
		XCTAssertEqual(testAuth.password, "test-pass")
	}

	func testPactBrokerSetsProviderTags() {
		let testTags = [
			VersionSelector(tag: "SIT"),
			VersionSelector(tag: "prod"),
		]

		let testSubject = PactBroker(
			url: URL(string: "http://test.pact.broker")!,
			auth: .token(.init(token: "some-test-token")),
			providerName: "Test API Provider",
			consumerTags: testTags
		)

		XCTAssertEqual(testSubject.consumerTags, testTags)
	}

}
