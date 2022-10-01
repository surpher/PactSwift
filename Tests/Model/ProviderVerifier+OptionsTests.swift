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

final class ProviderVerifierOptionsTests: XCTestCase {

	func testArgsWithConfiguredProvider() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(url: URL(string: "https://localhost")!, port: 1234),
			pactsSource: .directories(["/tmp/pacts"])
		)

		XCTAssertTrue(testSubject.args.contains("--port\n1234"))
		XCTAssertTrue(testSubject.args.contains("--hostname\nhttps://localhost"))
	}

	func testArgsWhenPactSourceIsDirectories() {
		let testSubject = ProviderVerifier.Options(
			provider: ProviderVerifier.Provider(port: 8080),
			pactsSource: .directories(["/tmp/pacts"])
		)

		XCTAssertTrue(testSubject.args.contains("--port\n8080"))
		XCTAssertTrue(testSubject.args.contains("--dir\n/tmp/pacts"))
	}

	func testArgsWhenPactsSourceIsFiles() {
		let testSubject = ProviderVerifier.Options(
			provider: ProviderVerifier.Provider(port: 8080),
			pactsSource: .files(["/tmp/pacts/one.json", "/tmp/pacts/two.json"])
		)

		XCTAssertTrue(testSubject.args.contains("--port\n8080"))
		XCTAssertTrue(testSubject.args.contains("--file\n/tmp/pacts/one.json"))
		XCTAssertTrue(testSubject.args.contains("--file\n/tmp/pacts/two.json"))
	}

	func testArgsWhenPactsSourceIsURLs() {
		let testSubject = ProviderVerifier.Options(
			provider: ProviderVerifier.Provider(port: 8080),
			pactsSource: .urls([URL(string: "http://some.url/file.json")!])
		)

		XCTAssertTrue(testSubject.args.contains("--port\n8080"))
		XCTAssertTrue(testSubject.args.contains("--url\nhttp://some.url/file.json"))
	}

	func testArgsWithStateChangeURL() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			stateChangeURL: URL(string: "https://provider.url/stateChangeURL")!
		)

		XCTAssertTrue(testSubject.args.contains("--state-change-url\nhttps://provider.url/stateChangeURL"))
	}

	func testArgsWithLogLevel() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			logLevel: .trace
		)

		XCTAssertTrue(testSubject.args.contains("--loglevel\ntrace"))
	}

	func testArgsWithFilterProviderStates() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			filter: .noState
		)

		XCTAssertTrue(testSubject.args.contains("--filter-no-state\ntrue"))
	}

	func testArgsWithFilterStates() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			filter: .states(["state A", "state B"])
		)

		XCTAssertTrue(testSubject.args.contains("--filter-state\nstate A"))
		XCTAssertTrue(testSubject.args.contains("--filter-state\nstate B"))
	}

	func testArgsWithFilterDescriptions() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			filter: .descriptions(["A description", "B description"])
		)

		XCTAssertTrue(testSubject.args.contains("--filter-description\nA description"))
		XCTAssertTrue(testSubject.args.contains("--filter-description\nB description"))
	}

	func testArgsWithFilterConsumers() {
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			filter: .consumers(["Mobile Consumer", "Web Consumer"])
		)

		XCTAssertTrue(testSubject.args.contains("--filter-consumer\nMobile Consumer"))
		XCTAssertTrue(testSubject.args.contains("--filter-consumer\nWeb Consumer"))
	}

	func testArgsWithPactBrokerUsingToken() {
		let testBroker = PactBroker(
			url: URL(string: "https://broker.url")!,
			auth: .token(PactBroker.APIToken("test-token")),
			providerName: "API Provider Name"
		)

		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 1234),
			pactsSource: .broker(testBroker)
		)

		XCTAssertTrue(testSubject.args.contains("--broker-url\nhttps://broker.url"))
		XCTAssertTrue(testSubject.args.contains("--token\ntest-token"))
		XCTAssertTrue(testSubject.args.contains("--provider-name\nAPI Provider Name"))
	}

	func testArgsWithPactBrokerBasicAuth() {
		let testBroker = PactBroker(
			url: URL(string: "https://broker.url")!,
			auth: .auth(.init(username: "test-user", password: "test-pass")),
			providerName: "API Provider Name"
		)

		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 1234),
			pactsSource: .broker(testBroker)
		)

		XCTAssertTrue(testSubject.args.contains("--user\ntest-user"))
		XCTAssertTrue(testSubject.args.contains("--password\ntest-pass"))
	}

	func testArgsPublishingVerification() {
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

		XCTAssertTrue(testSubject.args.contains("--publish\n"))
		XCTAssertTrue(testSubject.args.contains("--provider-version\ntest-998877"))
		XCTAssertTrue(testSubject.args.contains("--provider-tags\ntest,unit"))
	}

	func testArgsPublishingVerificationWithoutTags() {
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

		XCTAssertTrue(testSubject.args.contains("--publish\n"))
		XCTAssertTrue(testSubject.args.contains("--provider-version\ntest-123456"))
		XCTAssertFalse(testSubject.args.contains("--provider-tags"))
	}

	func testArgsBrokerWithConsumerTags() {
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

		XCTAssertTrue(testSubject.args.contains("--consumer-version-selectors\n{"))
		XCTAssertTrue(testSubject.args.contains("\"tag\":\"prod\""))
		XCTAssertTrue(testSubject.args.contains("\"tag\":\"v2.3.5\""))
		XCTAssertTrue(testSubject.args.contains("\"fallbackTag\":\"main\""))
		XCTAssertTrue(testSubject.args.contains("\"fallbackTag\":\"prod\""))
		XCTAssertTrue(testSubject.args.contains("\"latest\":true"))
		XCTAssertTrue(testSubject.args.contains("\"latest\":false"))
		XCTAssertTrue(testSubject.args.contains("\"consumer\":\"Test-app\""))
		XCTAssertTrue(testSubject.args.contains("\"consumer\":\"Web-app\""))
	}

	func testArgsBrokerWithPendingPacts() {
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

		XCTAssertTrue(testSubject.args.contains("--enable-pending\ntrue"))
	}

	func testArgsBrokerDefaultsNotIncludePendingPacts() {
		let testBroker = PactBroker(
			url: URL(string: "https://broker.url")!,
			auth: .auth(.init(username: "test-user", password: "test-pass")),
			providerName: "API Provider Name"
		)

		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 1234),
			pactsSource: .broker(testBroker)
		)

		XCTAssertFalse(testSubject.args.contains("--enable-pending"))
	}

	func testArgsBrokerDefaltsNotIncludeWIPPacts() {
		let testBroker = PactBroker(
			url: URL(string: "https://broker.url")!,
			auth: .auth(.init(username: "test-user", password: "test-pass")),
			providerName: "API Provider Name"
		)

		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 1234),
			pactsSource: .broker(testBroker)
		)

		XCTAssertFalse(testSubject.args.contains("--enable-pending"))
		XCTAssertFalse(testSubject.args.contains("--include-wip"))
	}

	func testArgsBrokerIncludeWIPPacts() {
		let testDate = Date()
		let todaysISODateString = isoDate(testDate)

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

		XCTAssertTrue(testSubject.args.contains("--enable-pending\ntrue"))
		XCTAssertTrue(testSubject.args.contains("--include-wip-pacts-since\n\(todaysISODateString)"))
		XCTAssertTrue(testSubject.args.contains("--provider-version\nv1.2.3"))
	}

	func testArgsWithValidCustomHeader() {
		let asciiCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 !\"#$%&'()*+,-./:;<=>?@"
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			customHeader: ["Foo": asciiCharacters, "Bar": "BAZ"]
		)

		XCTAssertTrue(["--header\nFoo=\(asciiCharacters)", "--header\nBar=BAZ"].allSatisfy { testSubject.args.contains($0) })
	}

	func testArgsWithInvalidCustomHeader() {
		let invalidCharacters = "çüé abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 !\"#$%&'()*+,-./:;<=>?@"
		let testSubject = ProviderVerifier.Options(
			provider: .init(port: 8080),
			pactsSource: .directories(["/tmp/pacts"]),
			customHeader: ["Foo": invalidCharacters, "Bar": "BAZ"]
		)

		XCTAssertTrue(testSubject.args.contains("--header\nBar=BAZ"))
		XCTAssertFalse(testSubject.args.contains("--header\nFoo=\(invalidCharacters)"))
	}

}

private extension ProviderVerifierOptionsTests {

	func isoDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "YYYY-MM-dd"
		return formatter.string(from: date)
	}

}
