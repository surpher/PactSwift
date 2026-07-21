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

import PactSwiftMockServer

@testable import PactSwift

final class ProviderVerifierOptionsTests: XCTestCase {

	func testMapsConfiguredProvider() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(url: URL(string: "https://localhost")!, port: 1234),
			pactsSource: .directories(["/tmp/pacts"])
		)

		let provider = testSubject.verificationOptions.provider
		XCTAssertEqual(provider.port, 1234)
		XCTAssertEqual(provider.scheme, "https")
		XCTAssertEqual(provider.host, "localhost")
	}

	func testMapsDirectoriesSource() {
		let testSubject = ProviderVerifier.Options(
			provider: ProviderVerifier.Provider(port: 8080),
			pactsSource: .directories(["/tmp/pacts"])
		)

		XCTAssertEqual(testSubject.verificationOptions.provider.port, 8080)
		XCTAssertEqual(testSubject.verificationOptions.sources.compactMap(\.directoryPath), ["/tmp/pacts"])
	}

	func testMapsFilesSource() {
		let testSubject = ProviderVerifier.Options(
			provider: ProviderVerifier.Provider(port: 8080),
			pactsSource: .files(["/tmp/pacts/one.json", "/tmp/pacts/two.json"])
		)

		XCTAssertEqual(
			testSubject.verificationOptions.sources.compactMap(\.filePath),
			["/tmp/pacts/one.json", "/tmp/pacts/two.json"]
		)
	}

	func testMapsURLsSource() {
		let testSubject = ProviderVerifier.Options(
			provider: ProviderVerifier.Provider(port: 8080),
			pactsSource: .urls([URL(string: "http://some.url/file.json")!])
		)

		XCTAssertEqual(
			testSubject.verificationOptions.sources.compactMap(\.urlValue),
			[URL(string: "http://some.url/file.json")!]
		)
	}

	func testMapsStateChangeURL() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			stateChangeURL: URL(string: "https://provider.url/stateChangeURL")!
		)

		XCTAssertEqual(
			testSubject.verificationOptions.stateChange?.url,
			URL(string: "https://provider.url/stateChangeURL")!
		)
	}

	func testMapsFilterNoState() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			filter: .noState
		)

		XCTAssertEqual(testSubject.verificationOptions.filter?.noState, true)
	}

	// NOTE: the FFI accepts a single filter state, so only the first is forwarded.
	func testMapsFilterStatesToFirst() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			filter: .states(["state A", "state B"])
		)

		XCTAssertEqual(testSubject.verificationOptions.filter?.state, "state A")
	}

	// NOTE: the FFI accepts a single filter description, so only the first is forwarded.
	func testMapsFilterDescriptionsToFirst() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			filter: .descriptions(["A description", "B description"])
		)

		XCTAssertEqual(testSubject.verificationOptions.filter?.description, "A description")
	}

	func testMapsFilterConsumers() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			filter: .consumers(["Mobile Consumer", "Web Consumer"])
		)

		XCTAssertEqual(testSubject.verificationOptions.consumerFilters, ["Mobile Consumer", "Web Consumer"])
		XCTAssertNil(testSubject.verificationOptions.filter)
	}

	func testMapsBrokerUsingToken() throws {
		let testBroker = PactBroker(
			url: URL(string: "https://broker.url")!,
			auth: .token(PactBroker.APIToken("test-token")),
			providerName: "API Provider Name"
		)

		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 1234),
			pactsSource: .broker(testBroker)
		)

		let broker = try XCTUnwrap(testSubject.verificationOptions.sources.first?.brokerConfig)
		XCTAssertEqual(broker.url, URL(string: "https://broker.url")!)
		XCTAssertEqual(broker.authentication?.tokenValue, "test-token")
		XCTAssertEqual(testSubject.verificationOptions.provider.name, "API Provider Name")
	}

	func testMapsBrokerBasicAuth() throws {
		let testBroker = PactBroker(
			url: URL(string: "https://broker.url")!,
			auth: .auth(.init(username: "test-user", password: "test-pass")),
			providerName: "API Provider Name"
		)

		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 1234),
			pactsSource: .broker(testBroker)
		)

		let broker = try XCTUnwrap(testSubject.verificationOptions.sources.first?.brokerConfig)
		XCTAssertEqual(broker.authentication?.basicUsername, "test-user")
		XCTAssertEqual(broker.authentication?.basicPassword, "test-pass")
	}

	func testMapsPublishingVerification() {
		let testBroker = PactBroker(
			url: URL(string: "https://broker.url")!,
			auth: .auth(.init(username: "test-user", password: "test-pass")),
			providerName: "API Provider Name",
			publishResults: .init(providerVersion: "test-998877", providerTags: ["test", "unit"])
		)

		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 1234),
			pactsSource: .broker(testBroker)
		)

		XCTAssertEqual(testSubject.verificationOptions.publish?.providerVersion, "test-998877")
		XCTAssertEqual(testSubject.verificationOptions.publish?.providerTags, ["test", "unit"])
	}

	func testMapsPublishingVerificationWithoutTags() {
		let testBroker = PactBroker(
			url: URL(string: "https://broker.url")!,
			auth: .auth(.init(username: "test-user", password: "test-pass")),
			providerName: "API Provider Name",
			publishResults: .init(providerVersion: "test-123456")
		)

		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 1234),
			pactsSource: .broker(testBroker)
		)

		XCTAssertEqual(testSubject.verificationOptions.publish?.providerVersion, "test-123456")
		XCTAssertEqual(testSubject.verificationOptions.publish?.providerTags, [])
	}

	func testDoesNotPublishByDefault() throws {
		let testBroker = PactBroker(
			url: URL(string: "https://broker.url")!,
			auth: .auth(.init(username: "test-user", password: "test-pass")),
			providerName: "API Provider Name"
		)

		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 1234),
			pactsSource: .broker(testBroker)
		)

		XCTAssertNil(testSubject.verificationOptions.publish)
	}

	func testMapsBrokerConsumerVersionSelectors() throws {
		let testBroker = PactBroker(
			url: URL(string: "https://broker.url")!,
			auth: .auth(.init(username: "test-user", password: "test-pass")),
			providerName: "API Provider Name",
			consumerTags: [
				VersionSelector(tag: "prod", fallbackTag: "main", latest: true, consumer: "Test-app"),
				VersionSelector(tag: "v2.3.5", fallbackTag: "prod", latest: false, consumer: "Web-app"),
			]
		)

		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 1234),
			pactsSource: .broker(testBroker)
		)

		let broker = try XCTUnwrap(testSubject.verificationOptions.sources.first?.brokerConfig)
		XCTAssertEqual(broker.consumerVersionSelectors.count, 2)
		let joined = broker.consumerVersionSelectors.joined(separator: " ")
		XCTAssertTrue(joined.contains("\"tag\":\"prod\""))
		XCTAssertTrue(joined.contains("\"tag\":\"v2.3.5\""))
		XCTAssertTrue(joined.contains("\"consumer\":\"Test-app\""))
		XCTAssertTrue(joined.contains("\"consumer\":\"Web-app\""))
	}

	func testMapsBrokerPendingPacts() throws {
		let testBroker = PactBroker(
			url: URL(string: "https://broker.url")!,
			auth: .auth(.init(username: "test-user", password: "test-pass")),
			providerName: "API Provider Name",
			includePending: true
		)

		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 1234),
			pactsSource: .broker(testBroker)
		)

		let broker = try XCTUnwrap(testSubject.verificationOptions.sources.first?.brokerConfig)
		XCTAssertTrue(broker.enablePending)
	}

	func testBrokerDefaultsToNoPendingOrWIP() throws {
		let testBroker = PactBroker(
			url: URL(string: "https://broker.url")!,
			auth: .auth(.init(username: "test-user", password: "test-pass")),
			providerName: "API Provider Name"
		)

		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 1234),
			pactsSource: .broker(testBroker)
		)

		let broker = try XCTUnwrap(testSubject.verificationOptions.sources.first?.brokerConfig)
		XCTAssertFalse(broker.enablePending)
		XCTAssertNil(broker.includeWIPPactsSince)
	}

	func testMapsBrokerIncludeWIPPacts() throws {
		let testDate = Date()

		let testBroker = PactBroker(
			url: URL(string: "https://broker.url")!,
			auth: .auth(.init(username: "test-user", password: "test-pass")),
			providerName: "API Provider Name",
			includeWIP: WIPPacts(since: testDate, providerVersion: "v1.2.3")
		)

		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 1234),
			pactsSource: .broker(testBroker)
		)

		let broker = try XCTUnwrap(testSubject.verificationOptions.sources.first?.brokerConfig)
		// Enabling WIP pacts also enables pending pacts.
		XCTAssertTrue(broker.enablePending)
		XCTAssertEqual(broker.includeWIPPactsSince, testDate)
	}

}

private extension VerificationOptions.Source {

	var directoryPath: String? {
		if case .directory(let path) = self { return path }
		return nil
	}

	var filePath: String? {
		if case .file(let path) = self { return path }
		return nil
	}

	var urlValue: URL? {
		if case .url(let url, _) = self { return url }
		return nil
	}

	var brokerConfig: VerificationOptions.Broker? {
		if case .broker(let broker) = self { return broker }
		return nil
	}
}

private extension VerificationOptions.Authentication {

	var tokenValue: String? {
		if case .token(let token) = self { return token }
		return nil
	}

	var basicUsername: String? {
		if case .basic(let username, _) = self { return username }
		return nil
	}

	var basicPassword: String? {
		if case .basic(_, let password) = self { return password }
		return nil
	}
}
