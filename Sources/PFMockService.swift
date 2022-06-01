//
//  Created by Marko Justinek on 31/7/21.
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

#if !os(Linux)

import Foundation
@_implementationOnly import PactSwiftToolbox
import XCTest

#if os(Linux)
import PactSwiftMockServerLinux
#elseif compiler(>=5.5)
@_implementationOnly import PactSwiftMockServer
#else
import PactSwiftMockServer
#endif

/// Initializes a `PFMockService` object that handles Pact interaction testing for projects written in Objective-C. For Swift projects use `MockService`.
///
/// When initializing with `.secure` scheme, the SSL certificate on Mock Server
/// is a self-signed certificate.
///
@objc open class PFMockService: NSObject {

	// MARK: - Properties

	private let mockService: MockService

	// MARK: - Initialization

	/// Initializes a `MockService` object that handles Pact interaction testing
	///
	/// When initializing with `.secure` transferProtocol,
	/// the SSL certificate on Mock Server is a self-signed certificate.
	///
	/// - Parameters:
	///   - consumer: Name of the API consumer (eg: "mobile-app")
	///   - provider: Name of the API provider (eg: "auth-service")
	///   - transferProtocol: HTTP scheme
	///   - merge: Whether to merge interactions with an existing Pact contract
	///
	@objc(initWithConsumer: provider: transferProtocol: merge:)
	public convenience init(
		consumer: String,
		provider: String,
		transferProtocol: TransferProtocol = .standard,
		merge: Bool = true
	) {
		self.init(consumer: consumer, provider: provider, scheme: transferProtocol, errorReporter: ErrorReporter(), merge: merge)
	}

	internal init(
		consumer: String,
		provider: String,
		scheme: TransferProtocol,
		errorReporter: ErrorReportable? = nil,
		merge: Bool
	) {
		mockService = MockService(consumer: consumer, provider: provider, scheme: scheme, merge: merge, errorReporter: errorReporter ?? ErrorReporter())
	}

	// MARK: - Interface

	/// Describes the `Interaction` between the consumer and provider
	///
	/// It is important that the `description` and provider state
	/// combination is unique per consumer-provider contract.
	///
	/// - parameter description: A description of the API interaction
	///
	@discardableResult
	@objc public func uponReceiving(_ description: String) -> Interaction {
		mockService.uponReceiving(description)
	}

	/// Runs the Pact test with default timeout
	///
	/// Make sure you call the completion block at the end of your test.
	///

	@objc(run:)
	public func objCRun(testFunction: @escaping (String, (@escaping () -> Void)) -> Void) {
		mockService.run(timeout: Constants.kTimeout, testFunction: testFunction)
	}

	/// Runs the Pact test with provided timeout
	///
	/// Make sure you call the completion block at the end of your test.
	///
	@objc(run: withTimeout:)
	public func objCRun(testFunction: @escaping (String, (@escaping () -> Void)) -> Void, timeout: TimeInterval) {
		mockService.run(timeout: timeout, testFunction: testFunction)
	}

	/// Runs the Pact test with provided timeout verifying the provided set of interactions
	///
	/// Make sure you call the completion block at the end of your test.
	///
	@objc(run: verifyInteractions: withTimeout:)
	public func objCRun(testFunction: @escaping (String, (@escaping () -> Void)) -> Void, verify interactions: [Interaction], timeout: TimeInterval) {
		mockService.run(verify: interactions, timeout: timeout, testFunction: testFunction)
	}

}

#endif
