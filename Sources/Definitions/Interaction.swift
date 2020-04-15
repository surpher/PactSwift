//
//  Interaction.swift
//  PactSwift
//
//  Created by Marko Justinek on 1/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
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
