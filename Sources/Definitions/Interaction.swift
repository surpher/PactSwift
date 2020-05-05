//
//  Interaction.swift
//  PactSwift
//
//  Created by Marko Justinek on 1/4/20.
//  Copyright © 2020 Itty Bitty Apps Pty Ltd / PACT Foundation. All rights reserved.
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

///
/// Defines the interaction between consumer and provider.
///
public class Interaction: Encodable {

	var description: String?
	var providerState: String?
	var providerStates: [ProviderState]?
	var request: Request?
	var response: Response?

}

extension Interaction {

	convenience init(description: String) {
		self.init()
		self.description = description
	}

	convenience init(description: String, providerState: String, request: Request? = nil, response: Response? = nil) {
		self.init()
		self.description = description
		self.providerState = providerState
		self.request = request
		self.response = response
	}

	convenience init(description: String, providerStates: [ProviderState], request: Request? = nil, response: Response? = nil) {
		self.init()
		self.description = description
		self.providerStates = providerStates
		self.request = request
		self.response = response
	}

}

extension Interaction {

	///
	/// Defines the description of the interaction.
	///
	/// - parameter interactionDescription: A `String` describing the interaction
	///
	/// It is important to provide a meaningful description so that
	/// developers on the provider side can understand what the
	/// intent of the interaction is. This description is also listed in
	/// the list of interactions on Pact Broker.
	///
	/// Example:
	/// ```
	/// .uponReceiving("A request for a list of users")
	/// ```
	///
	func uponReceiving(_ interactionDescription: String) -> Interaction {
		self.description = interactionDescription
		return self
	}

	///
	/// Defines the provider state for the given interaction.
	///
	/// - parameter providerState: Description of the state.
	///
	/// It is important to provide a meaningful description with
	/// values that help prepare provider Pact tests.
	///
	/// Example:
	/// ```users exist```
	///
	public func given(_ providerState: String) -> Interaction {
		self.providerState = providerState
		return self
	}

	///
	/// Defines the provider state for the given interaction.
	///
	/// - parameter providerStates: A list of provider states
	///
	/// It is important to provide a meaningful description with
	/// values that help prepare provider side Pact tests.
	///
	/// Example:
	/// ```
	/// .given([
	///   ProviderState(
	///     description: "user exists",
	///     params: ["id": "1"]
	///   )
	/// ])
	/// ```
	///
	public func given(_ providerStates: [ProviderState]) -> Interaction {
		self.providerStates = providerStates
		return self
	}

	///
	/// Defines the provider state for the given interaction.
	///
	/// - parameter providerStates: A list of provider states
	///
	/// It is important to provide a meaningful description with
	/// values that help prepare provider side Pact tests.
	///
	/// Example:
	/// ```
	/// .given([
	///   ProviderState(
	///     description: "user exists",
	///     params: ["id": "1"]
	///   )
	/// ])
	/// ```
	///
	public func given(_ providerStates: ProviderState...) -> Interaction {
		given(providerStates)
	}

	///
	/// Defines the expected request for the interaction.
	///
	/// - parameter method: The HTTP method of the request
	/// - parameter path: The URL path of the request
	/// - parameter query: The query parameters of the request
	/// - parameter headers: The header parameters of the request
	/// - parameter body: The body of the request
	///
	/// At a minimum the `method` and `path` required to test an API request.
	/// By not providing a value for `query`, `headers` or `body` it is
	/// understood that the presence of those values in the request
	/// is _not required_ but they can be present.
	///
	public func withRequest(method: PactHTTPMethod, path: String, query: [String: [String]]? = nil, headers: [String: String]? = nil, body: Any? = nil) -> Interaction {
		self.request = Request(method: method, path: path, query: query, headers: headers, body: body)
		return self
	}

	///
	/// Defines the expected response for the interaction. It defines the
	/// values `MockService` will respond with when it receives the expected
	/// request as defined in this interaction.
	///
	/// - parameter status: The response status code
	/// - parameter headers: The response headers
	/// - parameter body: The response body
	///
	/// At a minimum the `status` is required to test an API response.
	/// By not providing a value for `headers` or `body` it is understood
	/// that the presence of those values in the response is _not required_
	/// but the can be present.
	///
	public func willRespondWith(status: Int, headers: [String: String]? = nil, body: Any? = nil) -> Interaction {
		self.response = Response(statusCode: status, headers: headers, body: body)
		return self
	}

}
