//
//  MockService.swift
//  PactSwift
//
//  Created by Marko Justinek on 15/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation
import PactSwiftServices

class MockService {

	private let mockServer: MockServer
	private let pact: Pact

	private var interactions: [Interaction] = []

	// MARK: - Initializers

	init(consumer: String, provider: String) {
		pact = Pact(consumer: Pacticipant.consumer(consumer), provider: Pacticipant.provider(provider))
		mockServer = MockServer()
	}

	// MARK: - Interface

	func uponReceiving(_ description: String) -> Interaction {
		let interaction = Interaction().uponReceiving(description)
		interactions.append(interaction)
		return interaction
	}

}

private extension MockService {

}

private extension MockService {

	func failWithLocation() {

	}

	func failWithError(_ error: Error) {

	}

}
