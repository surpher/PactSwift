//
//  Created by Marko Justinek on 19/8/21.
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

import Foundation
import PactSwiftMockServer

public extension ProviderVerifier {

	/// Defines the options to use when verifying a provider
	struct Options {

		// MARK: - Types

		/// Logging level for provider verification
		public enum LogLevel: String {
			case error
			case warn
			case info
			case debug
			case trace
			case none
		}

		/// The source of Pact files
		public enum PactsSource {

			/// Verify pacts on a Pact Broker
			case broker(PactBroker)

			/// Verify pacts in directories
			case directories([String])

			/// Verify specific pact files
			case files([String])

			/// Verify specific pacts at URLs
			case urls([URL])
		}

		/// Filter pacts
		public enum FilterPacts {

			/// Only validate interactions that have no defined provider state
			case noState

			/// Only validate interactions whose provider states match this filter
			case states([String])

			/// Only validate interactions whose descriptions match this filter
			case descriptions([String])

			/// Consumer name to filter the pacts to be verified
			case consumers([String])
		}

		// MARK: - Properties

		/// The port of provider being verified
		let port: Int

		/// URL of the provider being verified
		let providerURL: URL?

		/// Only validated interactions that match this filter
		let filterPacts: FilterPacts?

		/// Pacts source
		let pactsSource: PactsSource

		/// URL to post state change requests to
		let stateChangeURL: URL?

		/// Sets the log level
		let logLevel: LogLevel

		// MARK: - Initialization

		/// Defines the options to use when verifying a provider
		///
		/// - Parameters:
		///   - provider: The provider information
		///   - pactsSource: The locations of pacts
		///   - filter: Only validates the interactions that match the filter
		///   - stateChangeURL: URL to post state change requests to
		///   - logLevel: Logging level
		///
		public init(
			provider: Provider,
			pactsSource: PactsSource,
			filter: FilterPacts? = nil,
			stateChangeURL: URL? = nil,
			logLevel: LogLevel = .warn
		) {
			self.providerURL = provider.url
			self.port = provider.port
			self.pactsSource = pactsSource
			self.filterPacts = filter
			self.stateChangeURL = stateChangeURL
			self.logLevel = logLevel
		}
	}

}

extension ProviderVerifier.Options {

	/// The typed options passed to `PactSwiftMockServer`'s handle-based verifier.
	///
	/// - Note: `logLevel` is currently not mapped. The `pactffi_verifier_*` API has no
	///   per-verification log level setter (verification logging is configured globally).
	var verificationOptions: VerificationOptions {
		VerificationOptions(
			provider: providerInfo,
			sources: sources,
			filter: filter,
			consumerFilters: consumerFilters,
			stateChange: stateChange,
			publish: publish
		)
	}

	private var providerInfo: VerificationOptions.Provider {
		let path = (providerURL?.path).flatMap { $0.isEmpty ? nil : $0 } ?? "/"
		return VerificationOptions.Provider(
			name: providerName,
			scheme: providerURL?.scheme ?? "http",
			host: providerURL?.host ?? "localhost",
			port: UInt16(port),
			path: path
		)
	}

	/// The provider name only exists on a broker source; otherwise the FFI default is used.
	private var providerName: String {
		if case .broker(let broker) = pactsSource {
			return broker.providerName
		}
		return "provider"
	}

	private var sources: [VerificationOptions.Source] {
		switch pactsSource {
		case .broker(let broker):
			return [.broker(broker.brokerSource)]
		case .directories(let directories):
			return directories.map { .directory($0) }
		case .files(let files):
			return files.map { .file($0) }
		case .urls(let urls):
			return urls.map { .url($0, authentication: nil) }
		}
	}

	/// - Note: `pactffi_verifier_set_filter_info` accepts a single state and a single
	///   description, so only the first value is forwarded when several are provided.
	private var filter: VerificationOptions.Filter? {
		switch filterPacts {
		case .noState:
			return VerificationOptions.Filter(noState: true)
		case .states(let states):
			return VerificationOptions.Filter(state: states.first)
		case .descriptions(let descriptions):
			return VerificationOptions.Filter(description: descriptions.first)
		case .consumers, .none:
			return nil
		}
	}

	private var consumerFilters: [String] {
		if case .consumers(let consumers) = filterPacts {
			return consumers
		}
		return []
	}

	private var stateChange: VerificationOptions.StateChange? {
		stateChangeURL.map { VerificationOptions.StateChange(url: $0) }
	}

	private var publish: VerificationOptions.Publish? {
		guard
			case .broker(let broker) = pactsSource,
			broker.publishVerificationResult,
			let providerVersion = broker.providerVersion, providerVersion.isEmpty == false
		else {
			return nil
		}
		return VerificationOptions.Publish(
			providerVersion: providerVersion,
			providerTags: broker.providerTags ?? []
		)
	}
}

private extension PactBroker {

	var brokerSource: VerificationOptions.Broker {
		VerificationOptions.Broker(
			url: URL(string: url) ?? URL(fileURLWithPath: url),
			authentication: brokerAuthentication,
			enablePending: includePending ?? (includeWIP != nil),
			includeWIPPactsSince: includeWIP?.sinceDate,
			providerTags: providerTags ?? [],
			consumerVersionSelectors: consumerVersionSelectorStrings
		)
	}

	var brokerAuthentication: VerificationOptions.Authentication {
		switch authentication {
		case .auth(let simple):
			return .basic(username: simple.username, password: simple.password)
		case .token(let apiToken):
			return .token(apiToken.token)
		}
	}

	var consumerVersionSelectorStrings: [String] {
		(consumerTags ?? []).compactMap { selector in
			do {
				return try selector.toJSONString()
			} catch {
				Logger.log(message: "Failed to encode consumer version selector: \(error)")
				return nil
			}
		}
	}
}
