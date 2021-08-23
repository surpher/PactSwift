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
			case broker(Broker)
			case directories([String])
			case files([String])
			case urls([URL])
		}

		/// Provider states filter
		public enum ProviderStates {
			case noState
			case filterStates([String])
			case filterDescriptions([String])
			case filterConsumers([String])
		}

		// MARK: - Properties

		/// The port of provider being verified
		let port: Int

		/// URL of the provider being verified
		let providerURL: URL?

		/// Only validated interactions that match this filter
		let filterProviderStates: ProviderStates?

		/// Pacts source
		let pactsSource: PactsSource

		/// Includes pending pacts in verification
		let includePending: Bool

		let consumerTags: [String]?

		let providerTags: [String]?

		/// Sets the log level
		let logLevel: LogLevel

		// MARK: - Initialization

		/// Defines the options to use when verifying a provider
		///
		/// - Parameters:
		///   - provider: The provider information
		///   - pactsSource: The locations of pacts
		///   - filterStates: Only validates the interactions that match the filter
		///   - includePending: Verify pending pacts ([https://pact.io/pending](https://pact.io/pending))
		///   - logLevel: Logging level
		///
		public init(
			provider: Provider,
			pactsSource: PactsSource,
			filterStates: ProviderStates? = nil,
			includePending: Bool = false,
			consumerTags: [String]? = nil,
			providerTags: [String]? = nil,
			logLevel: LogLevel = .warn
		) {
			self.providerURL = provider.url
			self.port = provider.port
			self.pactsSource = pactsSource
			self.filterProviderStates = filterStates
			self.includePending = includePending
			self.consumerTags = consumerTags
			self.providerTags = providerTags
			self.logLevel = logLevel
		}
	}

}

extension ProviderVerifier.Options {

	/// Newline delimited provider verification arguments
	var args: String {
		var newLineDelimitedArgs = [String]()

		// Set verified provider port
		newLineDelimitedArgs.append("--port\n\(self.port)")

		// Set verified provider url
		if let providerURL = providerURL {
			newLineDelimitedArgs.append("--hostname\n\(providerURL.absoluteString)")
		}

		// Pacts source
		switch pactsSource {

		case .broker(let broker):
			newLineDelimitedArgs.append("--broker-url\n\(broker.url)")

			// Broker authentication type
			switch broker.authentication {
			case .auth(let auth):
				newLineDelimitedArgs.append("--user\n\(auth.username)")
				newLineDelimitedArgs.append("--password\n\(auth.password)")

			case .token(let auth):
				newLineDelimitedArgs.append("--token\n\(auth.token)")
			}

			// Use the pact for provider with name
			newLineDelimitedArgs.append("--provider-name\n\(broker.providerName)")

			// Publishing verification results
			if broker.publishVerificationResult, let providerVersion = broker.providerVersion, providerVersion.isEmpty == false {
				newLineDelimitedArgs.append("--publish")
				newLineDelimitedArgs.append("--provider-version\n\(providerVersion)")
			}

		case .directories(let pactDirs) where pactDirs.isEmpty == false:
			pactDirs.forEach { newLineDelimitedArgs.append("--dir\n\($0)") }

		case .files(let files) where files.isEmpty == false:
			files.forEach { newLineDelimitedArgs.append("--file\n\($0)") }

		case .urls(let pactURLs) where pactURLs.isEmpty == false:
			pactURLs.forEach { newLineDelimitedArgs.append("--url\n\($0)") }

		default:
			break
		}

		// Pending pacts
		if includePending {
			newLineDelimitedArgs.append("--enable-pending")
		}

		// Set state filters
		if let filterProviderStates = filterProviderStates {
			switch filterProviderStates {

			case .noState:
				newLineDelimitedArgs.append("--filter-no-state\ntrue")

			case .filterStates(let states) where states.isEmpty == false:
				states.forEach { newLineDelimitedArgs.append("--filter-state\n\($0)") }

			case .filterDescriptions(let descriptions) where descriptions.isEmpty == false:
				descriptions.forEach { newLineDelimitedArgs.append("--filter-description\n\($0)") }

			case .filterConsumers(let consumers) where consumers.isEmpty == false:
				consumers.forEach { newLineDelimitedArgs.append("--filter-consumer\n\($0)") }

			default:
				break
			}
		}

		// Consumer tags
		if let consumerTags = consumerTags {
			newLineDelimitedArgs.append("--consumer-version-tags\n\(consumerTags.joined(separator: ","))")
		}

		// Provider tags
		if let providerTags = providerTags {
			newLineDelimitedArgs.append("--provider-tags\n\(providerTags.joined(separator: ","))")
		}

		// Set logging level
		newLineDelimitedArgs.append("--loglevel\n\(self.logLevel.rawValue)")

		// Convert all verification arguments to a ``String`` and return it
		return newLineDelimitedArgs.joined(separator: "\n")
	}

}
