//
//  Created by Marko Justinek on 31/1/2025.
//  Copyright © 2025 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest

extension XCTestCase {

    func AsyncAssertThrowsError<T>(
        _ expression: @autoclosure () async throws -> T,
        _ message: @autoclosure () -> String = "Expected error was not thrown",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: (Error) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            XCTFail(message(), file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
}
