//
//  Created by Oliver Jones on 1/12/2022.
//  Copyright © 2022 Oliver Jones. All rights reserved.
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

@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
extension Task where Failure == Error {
	
	// Start a new Task with a timeout. If the timeout expires before the operation is
	// completed then the task is cancelled and an error is thrown.
	@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
	init(priority: TaskPriority? = nil, timeout: TimeInterval, operation: @escaping @Sendable () async throws -> Success) {
		self = Task(priority: priority) {
			try await withThrowingTaskGroup(of: Success.self) { group -> Success in
				group.addTask(operation: operation)
				group.addTask {
					try await _Concurrency.Task.sleep(nanoseconds: UInt64(timeout * Double(NSEC_PER_SEC)))
					throw TimeoutError(interval: timeout)
				}
				guard let success = try await group.next() else {
					throw _Concurrency.CancellationError()
				}
				group.cancelAll()
				return success
			}
		}
	}
}

struct TimeoutError: LocalizedError {
	var interval: TimeInterval
	var errorDescription: String? { "Task timed out after \(interval) seconds" }
}
