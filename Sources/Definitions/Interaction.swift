//
//  Interaction.swift
//  PactSwift
//
//  Created by Marko Justinek on 1/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
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

	public func uponReceiving(_ interactionDescription: String) -> Interaction {
		self.description = interactionDescription
		return self
	}

	public func given(_ providerState: String) -> Interaction {
		self.providerState = providerState
		return self
	}

	public func given(_ providerStates: [ProviderState]) -> Interaction {
		self.providerStates = providerStates
		return self
	}

	public func given(_ providerStates: ProviderState...) -> Interaction {
		given(providerStates)
	}

	func withRequest() { }

	func willRespondWith() { }

}
