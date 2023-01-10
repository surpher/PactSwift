//
//  Created by Oliver Jones on 10/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
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

import XCTest
@testable import PactSwift
import PactSwiftMockServer

class InteractionTestCase: XCTestCase {

	let session = URLSession(configuration: .ephemeral)
	var builder: PactBuilder!
	
	private var pactDirectory: String {
		NSTemporaryDirectory().appending("pacts/")
	}
		
	override func setUpWithError() throws {
		try super.setUpWithError()

		guard builder == nil else {
			return
		}
		
		builder = try createBuilder()
	}
	
	private func createBuilder() throws -> PactBuilder {
		try Pact.initialize(logSinks: [.init(.standardError, filter: .trace)])
		let pact = try Pact(consumer: "\(name)-Consumer", provider: "\(name)-Provider")
			.withSpecification(.v4)
			.withMetadata(namespace: "namespace1", name: "name1", value: "value1")
			.withMetadata(namespace: "namespace2", name: "name2", value: "value2")
		
		let config = PactBuilder.Config(pactDirectory: pactDirectory)
		
		return PactBuilder(pact: pact, config: config)
	}

	internal func suppressingPactFailure(_ block: () async throws -> Void) async throws {
		do {
			try await block()
		} catch PactBuilder.Error.pactFailure {
			return
		}
	}
	
}
