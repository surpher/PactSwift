//
//  MockService.swift
//  PactSwift
//
//  Created by Marko Justinek on 15/4/20.
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
import PactSwiftServices

open class MockService {

	private let mockServer: MockServer
	private let pact: Pact

	private var interactions: [Interaction] = []

	var baseUrl: String {
		mockServer.baseUrl
	}

	// MARK: - Initializers

	public init(consumer: String, provider: String) {
		pact = Pact(consumer: Pacticipant.consumer(consumer), provider: Pacticipant.provider(provider))
		mockServer = MockServer()
	}

	// MARK: - Interface

	public func uponReceiving(_ description: String) -> Interaction {
		let interaction = Interaction().uponReceiving(description)
		interactions.append(interaction)
		return interaction
	}

	public func run(_ file: FileString? = #file, line: UInt? = #line, timeout: TimeInterval = 30, testFunction: @escaping (_ testComplete: @escaping () -> Void) -> Void) {

		// need to run this in waitUntil(completionBlock)
		// Setup the MockServer with interactions
		self.mockServer.setup(pact: pact.data!) {
			switch $0 {
			case .success:
				testFunction {
//					done() // -> trigger func of waitUntil ( () -> Void )
				}
			case .failure(let error):
				failWithError(error) // or location ?
//				done() // -> trigger func of waitUntil ( () -> Void )
			}
		}

		// Verify the interactions by running consumer's code
		self.mockServer.verify {
			switch $0 {
			case .success:
				debugPrint("PACT interactiosn validated OK! 👍")
				debugPrint("TODO: Write PACT file")
				// mockServer.writeFile { Result<Int, Error> -> Void in
				//	written OK
				//	Failed to write FILE!
				// }
			case .failure(let error):
				failWithError(error)
				debugPrint("warning: Make sure the testComplete() fuction is called at the end of your test.")
				// done() // -> trigger func of waitUntil ( () -> Void )
			}
		}
	}

}

private extension MockService {

	func failWithLocation() {

	}

	func failWithError(_ error: Error) {

	}

}
