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

let kTimeout: TimeInterval = 30

open class MockService {

	private let mockServer: MockServer
	private var pact: Pact

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

	public func run(_ file: FileString? = #file, line: UInt? = #line, timeout: TimeInterval? = nil, testFunction: @escaping (_ testCompleted: @escaping () -> Void) throws -> Void) {
		pact.interactions = interactions
		waitForPactUntil(timeout: timeout ?? kTimeout, file: file, line: line) { [unowned self, pactData = pact.data] completion in //swiftlint:disable:this line_length
			self.mockServer.setup(pact: pactData!) {
				switch $0 {
				case .success:
					do {
						try testFunction {
							completion()
						}
					} catch {
						self.failWith("Error thrown in test function (check build log): \(error.localizedDescription)", file: file, line: line) //swiftlint:disable:this line_length
					}
				case .failure(let error):
					self.failWith(error.localizedDescription)
					completion()
				}
			}
		}
	}

	public func verify() {
		// Verify the interactions by running consumer's code
		self.mockServer.verify {
			switch $0 {
			case .success:
				self.mockServer.finalize {
					switch $0 {
					case .success:
						debugPrint("TODO") // completion()
					case .failure(let error):
						self.failWith(error.localizedDescription)
					}
				}
			case .failure(let error):
				failWith(error.localizedDescription)
				debugPrint("warning: Make sure the testComplete() fuction is called at the end of your test.")
			}
		}
	}

}

private extension MockService {

	func failWith(_ message: String, file: FileString? = nil, line: UInt? = nil) {
		if let file = file, let line = line {
			fail(message, file: file, line: line) // Quick/Nimble
		} else {
			fail(message) // Quick/Nimble
		}
	}

	func waitForPactUntil(timeout: TimeInterval, file: FileString?, line: UInt?, action: @escaping (@escaping () -> Void) -> Void) {
		if let file = file, let line = line {
			return waitUntil(timeout: timeout, file: file, line: line, action: action) // Quick/Nimble
		} else {
			return waitUntil(timeout: timeout, action: action)  // Quick/Nimble
		}
	}

}
