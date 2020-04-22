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
import Nimble
import PactSwiftServices

let kTimeout: TimeInterval = 10

open class MockService {

	// MARK: - Properties

	public var baseUrl: String {
		mockServer.baseUrl
	}

	// MARK: - Private properties

	private var pact: Pact
	private var interactions: [Interaction] = []
	private var currentInteraction: Interaction!
	private var allValidated: Bool = true

	private let mockServer: MockServer
	private let errorReporter: ErrorReportable

	// MARK: - Initializers

	public init(consumer: String, provider: String, errorReporter: ErrorReportable? = nil) {
		pact = Pact(consumer: Pacticipant.consumer(consumer), provider: Pacticipant.provider(provider))
		mockServer = MockServer()
		self.errorReporter = errorReporter ?? ErrorReporter()
	}

	// MARK: - Interface

	public func uponReceiving(_ description: String) -> Interaction {
		currentInteraction = Interaction().uponReceiving(description)
		interactions.append(currentInteraction)
		return currentInteraction
	}

	// Test the API interaction (API calls) between the client and a programmed mock service.
	public func run(_ file: FileString? = #file, line: UInt? = #line, timeout: TimeInterval? = nil, testFunction: @escaping (_ testCompleted: @escaping () -> Void) throws -> Void) {
		pact.interactions = [currentInteraction]
		waitForPactUntil(timeout: timeout ?? kTimeout, file: file, line: line) { [unowned self, pactData = pact.data] completion in //swiftlint:disable:this line_length
			self.mockServer.setup(pact: pactData!) {
				switch $0 {
				case .success:
					do {
						try testFunction {
							completion()
						}
					} catch {
						self.failWith("🚨 Error thrown in test function: \(error.localizedDescription)", file: file, line: line)
					}
				case .failure(let error):
					self.failWith(error.description)
					completion()
				}
			}
		}

		waitForPactUntil(timeout: timeout ?? kTimeout, file: file, line: line) { completion in
			self.mockServer.verify(expected: self.currentInteraction.request?.description ?? "N/A") {
				switch $0 {
				case .success:
					completion()
				case .failure(let error):
					self.failWith(error.description, file: file, line: line)
					completion()
				}
			}
		}
	}

	// Checks if any of the verifications in this object have failed:
	public func finalize(completion: (Result<Void, MockServerError>) -> Void) {
		guard let pactData = pact.data, allValidated else {
			completion(.failure( .validationFaliure))
			return
		}

		self.mockServer.finalize(pact: pactData) {
			switch $0 {
			case .success:
				completion(.success(()))
			case .failure(let error):
				self.failWith(error.description)
				completion(.failure(error))
			}
		}
	}

}

private extension MockService {

	func waitForPactUntil(timeout: TimeInterval, file: FileString?, line: UInt?, action: @escaping (@escaping () -> Void) -> Void) {
		if let file = file, let line = line {
			return waitUntil(timeout: timeout, file: file, line: line, action: action)
		} else {
			return waitUntil(timeout: timeout, action: action)
		}
	}

	func failWith(_ message: String, file: FileString? = nil, line: UInt? = nil) {
		allValidated = false

		if let file = file, let line = line {
			errorReporter.reportFailure(message, file: file, line: line)
		} else {
			errorReporter.reportFailure(message)
		}
	}

}
