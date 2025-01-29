//
//  Created by Oliver Jones on 10/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

@testable import PactSwift

@_exported import PactSwiftMockServer
import XCTest

class InteractionTestCase: XCTestCase {

    var builder: PactBuilder!

    private var pactDirectory: String {
        "./.tmp"
    }

    @MainActor
    class override func setUp() {
        super.setUp()
        try! Logging.initialize(
            [
                Logging.Sink.Config(.standardOut, filter: .trace),
            ]
        )
    }

    override func setUp() async throws {
        try await super.setUp()
        try await Logging.initialize()
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        builder = try createBuilder()
    }

    // MARK: - Internal

    internal func suppressingPactFailure(_ block: () async throws -> Void) async throws {
        do {
            try await block()
        } catch PactBuilder.Error.pactFailure {
            return
        }
    }
}

// MARK: - Private

private extension InteractionTestCase {

    func createBuilder() throws -> PactBuilder {
        let pact = try Pact(consumer: "Consumer", provider: "Provider")
            .withSpecification(.v4)
            .withMetadata(namespace: "namespace1", name: "name1", value: "value1")
            .withMetadata(namespace: "namespace2", name: "name2", value: "value2")

        let config = PactBuilder.Config(pactDirectory: pactDirectory)

        return PactBuilder(pact: pact, config: config)
    }
}
