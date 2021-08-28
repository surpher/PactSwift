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
@_implementationOnly import PactSwiftToolbox

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

	/// Newline delimited provider verification arguments
	var args: String {
		// Verification arguments to pass to pactffi_verify()
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
			// Set broker url
			newLineDelimitedArgs.append("--broker-url\n\(broker.url)")

			// Broker authentication type
			// Authenticate with username and password
			switch broker.authentication {
			case .auth(let auth):
				newLineDelimitedArgs.append("--user\n\(auth.username)")
				newLineDelimitedArgs.append("--password\n\(auth.password)")

			// Authenticate with a Token (Pactflow)
			case .token(let auth):
				newLineDelimitedArgs.append("--token\n\(auth.token)")
			}

			// Use the pact for provider with name
			newLineDelimitedArgs.append("--provider-name\n\(broker.providerName)")

			// Publishing verification results back to Broker
			if broker.publishVerificationResult, let providerVersion = broker.providerVersion, providerVersion.isEmpty == false {
				newLineDelimitedArgs.append("--publish")
				newLineDelimitedArgs.append("--provider-version\n\(providerVersion)")

				if let providerTags = broker.providerTags, providerTags.isEmpty == false {
					newLineDelimitedArgs.append("--provider-tags\n\(providerTags.joined(separator: ","))")
				}
			}

			// Consumer tags
			broker.consumerTags?.forEach {
				do {
					newLineDelimitedArgs.append("--consumer-version-selectors\n\(try $0.toJSONString())")
				} catch {
					Logger.log(message: "Failed to convert provider version to JSON representaion: \(String(describing: broker.consumerTags))")
				}
			}

			// Pending pacts
			if broker.includePending == true {
				newLineDelimitedArgs.append("--enable-pending\ntrue")
			}

			// WIP pacts
			if let includeWIP = broker.includeWIP {
				// Enable pending pacts only if it wasn not set already!
				let enablePendingArgs = "--enable-pending\ntrue"
				if newLineDelimitedArgs.contains(where: { $0 == enablePendingArgs }) == false {
					newLineDelimitedArgs.append(enablePendingArgs)
				}

				// Set the date from which to include WIP pacts
				newLineDelimitedArgs.append("--include-wip-pacts-since\n\(includeWIP.sinceDate.iso8601short)")

				// Explicitly set provider version argument but only when not publishing verification result (otherwise it would be duplicated)
				// See [Work In Progress - Technical details](https://docs.pact.io/pact_broker/advanced_topics/wip_pacts/#technical-details) for more.
				if broker.publishVerificationResult == false {
					newLineDelimitedArgs.append("--provider-version\n\(includeWIP.providerVersion)")
				}
			}

		// Verify pacts from directories
		case .directories(let pactDirs) where pactDirs.isEmpty == false:
			pactDirs.forEach { newLineDelimitedArgs.append("--dir\n\($0)") }

		// Verify specific pact files
		case .files(let files) where files.isEmpty == false:
			files.forEach { newLineDelimitedArgs.append("--file\n\($0)") }

		// Verify pacts from specific URLs
		case .urls(let pactURLs) where pactURLs.isEmpty == false:
			pactURLs.forEach { newLineDelimitedArgs.append("--url\n\($0)") }

		default:
			break
		}

		// Set state filters
		if let filterProviderStates = filterPacts {
			switch filterProviderStates {

			// Only test interactions with no specific state defined
			case .noState:
				newLineDelimitedArgs.append("--filter-no-state\ntrue")

			// Only test interactions with specific states
			case .states(let states) where states.isEmpty == false:
				states.forEach { newLineDelimitedArgs.append("--filter-state\n\($0)") }

			// Only test interactions with specific descriptions
			case .descriptions(let descriptions) where descriptions.isEmpty == false:
				descriptions.forEach { newLineDelimitedArgs.append("--filter-description\n\($0)") }

			// Only test pact contracts with specific consumers
			case .consumers(let consumers) where consumers.isEmpty == false:
				consumers.forEach { newLineDelimitedArgs.append("--filter-consumer\n\($0)") }

			default:
				break
			}
		}

		// State change URL
		if let stateChangeURL = stateChangeURL {
			newLineDelimitedArgs.append("--state-change-url\n\(stateChangeURL.absoluteString)")
		}

		// Set logging level
		newLineDelimitedArgs.append("--loglevel\n\(self.logLevel.rawValue)")

		// Convert all verification arguments to a `String` and return it
		return newLineDelimitedArgs.joined(separator: "\n")
	}

}

private extension Date {

	/// Date represented as string in short ISO8601 format (eg: "2021-08-24")
	var iso8601short: String {
		let formatter = DateFormatter()
		formatter.dateFormat = "YYYY-MM-dd"
		return formatter.string(from: self)
	}

}
