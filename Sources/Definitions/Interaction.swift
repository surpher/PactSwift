//
//  Created by Marko Justinek on 1/4/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
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

/// Defines the interaction between consumer and provider
@objc public class Interaction: NSObject {

	var interactionDescription: String?
	var providerState: String?
	var providerStates: [ProviderState]?
	var request: Request?
	var response: Response?

}

extension Interaction: Encodable {

	enum CodingKeys: String, CodingKey {
		case interactionDescription = "description"
		case providerState
		case providerStates
		case request
		case response
	}

}

extension Interaction {

	@objc convenience init(description: String) {
		self.init()
		self.interactionDescription = description
	}

	convenience init(description: String, providerState: String, request: Request? = nil, response: Response? = nil) {
		self.init()
		self.interactionDescription = description
		self.providerState = providerState
		self.request = request
		self.response = response
	}

	convenience init(description: String, providerStates: [ProviderState], request: Request? = nil, response: Response? = nil) {
		self.init()
		self.interactionDescription = description
		self.providerStates = providerStates
		self.request = request
		self.response = response
	}

}

extension Interaction {

	/// Defines the description of the interaction
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
	/// - Parameters:
	///   - interactionDescription: A `String` describing the interaction
	///
	@discardableResult
	@objc(uponReceivingARequestWithDescription:)
	func uponReceiving(_ interactionDescription: String) -> Interaction {
		self.interactionDescription = interactionDescription
		return self
	}

	/// Defines the provider state for the given interaction
	///
	/// It is important to provide a meaningful description with
	/// values that help prepare provider Pact tests.
	///
	/// Example:
	/// ```users exist```
	///
	/// - Parameters:
	///   - providerState: Description of the state.
	///
	@discardableResult
	@objc(givenProviderState:)
	public func given(_ providerState: String) -> Interaction {
		self.providerState = providerState
		return self
	}

	/// Defines the provider states with parameters for the given interaction
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
	/// - Parameters:
	///   - providerStates: A list of provider states
	///
	@discardableResult
	public func given(_ providerStates: [ProviderState]) -> Interaction {
		self.providerStates = providerStates
		return self
	}

	/// Defines the provider states with parameters for the given interaction
	@discardableResult
	@objc(givenProviderStates:)
	public func objCGiven(_ providerStates: [ObjCProviderState]) -> Interaction {
		self.providerStates = providerStates.map { $0.state }
		return self
	}

	/// Defines the provider state for the given interaction
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
	/// - Parameters:
	///   - providerStates: A list of provider states
	///
	public func given(_ providerStates: ProviderState...) -> Interaction {
		given(providerStates)
	}

	/// Defines the expected request for the interaction.
	///
	/// At a minimum the `method` and `path` required to test an API request.
	/// By not providing a value for `query`, `headers` or `body` it is
	/// understood that the presence of those values in the request
	/// is _not required_ but they can be present.
	///
	/// `query` expects a dictionary where the value is an array conforming
	///  to `String` or a string `Matcher`.
	///
	///  ```
	///  // Verbatim matching for '?states=VIC,NSW,ACT'
	///  query: ["states": ["ACT", "NSW", "VIC"]]
	///
	///  // Matching using a string Matcher for
	///  query: ["states": [Matcher.SomethingLike("VIC")]] // or
	///  query: ["states": [Matcher.IncludesLike("VIC")]
	///  ```
	///
	/// - Parameters:
	///   - method: The HTTP method of the request
	///   - path: The URL path of the request
	///   - query: The query parameters of the request
	///   - headers: The header parameters of the request
	///   - body: The body of the request
	///
	@discardableResult
	public func withRequest(method: PactHTTPMethod, path: PactPathParameter, query: [String: [Any]]? = nil, headers: [String: Any]? = nil, body: Any? = nil) -> Interaction {
		do {
			self.request = try Request(method: method, path: path, query: query, headers: headers, body: body)
		} catch {
			Logger.log(message: "Can not prepare a Request with non-encodable data!")
		}

		return self
	}

	@discardableResult
	@objc(withRequestHTTPMethod: path: query: headers: body:)
	public func objCWithRequest(method: PactHTTPMethod, path: String, query: [String: [Any]]? = nil, headers: [String: Any]? = nil, body: Any? = nil) -> Interaction {
		withRequest(method: method, path: path, query: query, headers: headers, body: body)
		return self
	}

	/// Defines the expected response for the interaction. It defines the
	/// values `MockService` will respond with when it receives the expected
	/// request as defined in this interaction.
	///
	/// At a minimum the `status` is required to test an API response.
	/// By not providing a value for `headers` or `body` it is understood
	/// that the presence of those values in the response is _not required_
	/// but they can be present.
	///
	/// - Parameters:
	///   - status: The response status code
	///   - headers: The response headers
	///   - body: The response body
	///
	@discardableResult
	@objc public func willRespondWith(status: Int, headers: [String: Any]? = nil, body: Any? = nil) -> Interaction {
		do {
			self.response = try Response(statusCode: status, headers: headers, body: body)
		} catch {
			Logger.log(message: "Can not prepare a Response with non-encodable data!")
		}
		return self
	}

}
