//
//  DSL+wait.swift
//  PactSwiftServices
//
//  Created by Marko Justinek on 15/4/20.
//  Copyright © 2020 Pact Foundation. All rights reserved.
//
// This code has been pulled out of Quick/Nimble framework and adapted for this project's needs
// LICENSE: https://github.com/Quick/Nimble/blob/master/LICENSE
//
// Changes:
// * Only copied the code required to run `waitUntil()`
// * Modified code style to align with this project's conventions
//

import Dispatch
import Foundation
import XCTest

/// Quick/Nimble/Matchers/Async.swift
/// If you are running on a slower machine, it could be useful to increase the default timeout value
/// or slow down poll interval. Default timeout interval is 1, and poll interval is 0.01.
public struct AsyncDefaults {
	public static var Timeout: TimeInterval = 1
	public static var PollInterval: TimeInterval = 0.01
}

/// Quick/Nimble/DSL+Wait.swift
private enum ErrorResult {
	case exception(NSException)
	case error(Error)
	case none
}

/// Quick/Nimble/DSL+Wait.swift
/// Only classes, protocols, methods, properties, and subscript declarations can be
/// bridges to Objective-C via the @objc keyword. This class encapsulates callback-style
/// asynchronous waiting logic so that it may be called from Objective-C and Swift.
internal class NMBWait: NSObject {

	// About these kind of lines, `@objc` attributes are only required for Objective-C
	// support, so that should be conditional on Darwin platforms and normal Xcode builds
	// (non-SwiftPM builds).
	#if canImport(Darwin) && !SWIFT_PACKAGE
		@objc
		internal class func until(
			timeout: TimeInterval,
			file: FileString = #file,
			line: UInt = #line,
			action: @escaping (@escaping () -> Void) -> Void
		) {
				return throwableUntil(timeout: timeout, file: file, line: line) { done in
					action(done)
				}
			}
	#else
		internal class func until(
			timeout: TimeInterval,
			file: FileString = #file,
			line: UInt = #line,
			action: @escaping (@escaping () -> Void) -> Void
		) {
			return throwableUntil(timeout: timeout, file: file, line: line) { done in
				action(done)
			}
		}
	#endif

	// Using a throwable closure makes this method not objc compatible.
	internal class func throwableUntil(
				timeout: TimeInterval,
				file: FileString = #file,
				line: UInt = #line,
				action: @escaping (@escaping () -> Void) throws -> Void) {
						let awaiter = NimbleEnvironment.activeInstance.awaiter
						let leeway = timeout / 2.0
						// swiftlint:disable:next line_length
						let result = awaiter.performBlock(file: file, line: line) { (done: @escaping (ErrorResult) -> Void) throws -> Void in
								DispatchQueue.main.async {
										let capture = NMBExceptionCapture(
												handler: ({ exception in
														done(.exception(exception))
												}),
												finally: ({ })
										)
										capture.tryBlock {
												do {
														try action {
																done(.none)
														}
												} catch let e {
														done(.error(e))
												}
										}
								}
						}.timeout(timeout, forcefullyAbortTimeout: leeway).wait("waitUntil(...)", file: file, line: line)

						switch result {
						case .incomplete: internalError("Reached .incomplete state for waitUntil(...).")
						case .blockedRunLoop:
								fail(blockedRunLoopErrorMessageFor("-waitUntil()", leeway: leeway),
										file: file, line: line)
						case .timedOut:
								let pluralize = (timeout == 1 ? "" : "s")
								fail("Waited more than \(timeout) second\(pluralize)", file: file, line: line)
						case let .raisedException(exception):
								fail("Unexpected exception raised: \(exception)")
						case let .errorThrown(error):
								fail("Unexpected error thrown: \(error)")
						case .completed(.exception(let exception)):
								fail("Unexpected exception raised: \(exception)")
						case .completed(.error(let error)):
								fail("Unexpected error thrown: \(error)")
						case .completed(.none): // success
								break
						}
		}

	#if canImport(Darwin) && !SWIFT_PACKAGE
		@objc(untilFile:line:action:)
		internal class func until(
				_ file: FileString = #file,
				line: UInt = #line,
				action: @escaping (@escaping () -> Void) -> Void) {
				until(timeout: 1, file: file, line: line, action: action)
		}
	#else
		internal class func until(
				_ file: FileString = #file,
				line: UInt = #line,
				action: @escaping (@escaping () -> Void) -> Void) {
				until(timeout: 1, file: file, line: line, action: action)
		}
	#endif

}

internal func blockedRunLoopErrorMessageFor(_ fnName: String, leeway: TimeInterval) -> String {

	// swiftlint:disable:next line_length
	return "\(fnName) timed out but was unable to run the timeout handler because the main thread is unresponsive (\(leeway) seconds is allow after the wait times out). Conditions that may cause this include processing blocking IO on the main thread, calls to sleep(), deadlocks, and synchronous IPC. Nimble forcefully stopped run loop which may cause future failures in test run."
}

/// Quick/Nimble/DSL+Wait.swift
/// Wait asynchronously until the done closure is called or the timeout has been reached.
///
/// @discussion
/// Call the done() closure to indicate the waiting has completed.
///
/// This function manages the main run loop (`NSRunLoop.mainRunLoop()`) while this function
/// is executing. Any attempts to touch the run loop may cause non-deterministic behavior.
public func waitUntil(timeout: TimeInterval = AsyncDefaults.Timeout, file: FileString = #file, line: UInt = #line, action: @escaping (@escaping () -> Void) -> Void) {
	NMBWait.until(timeout: timeout, file: file, line: line, action: action)
}

/// Quick/Nimble/Adapters/AdapterProtocols
/// Protocol for the assertion handler that Nimble uses for all expectations.
public protocol AssertionHandler {
    func assert(_ assertion: Bool, message: FailureMessage, location: SourceLocation)
}

/// Global backing interface for assertions that Nimble creates.
/// Defaults to a private test handler that passes through to XCTest.
///
/// If XCTest is not available, you must assign your own assertion handler
/// before using any matchers, otherwise Nimble will abort the program.
///
/// @see AssertionHandler
public var NimbleAssertionHandler: AssertionHandler = { () -> AssertionHandler in
    // swiftlint:disable:previous identifier_name

//    return isXCTestAvailable() ? NimbleXCTestHandler() : NimbleXCTestUnavailableHandler()
	// CHANGE: -
	return NimbleXCTestHandler()
}()


/// Quick/Nimble/Adapters/NimbleEnvironment
/// "Global" state of Nimble is stored here. Only DSL functions should access / be aware of this
/// class' existence
internal class NimbleEnvironment: NSObject {
    static var activeInstance: NimbleEnvironment {
        get {
            let env = Thread.current.threadDictionary["NimbleEnvironment"]
            if let env = env as? NimbleEnvironment {
                return env
            } else {
                let newEnv = NimbleEnvironment()
                self.activeInstance = newEnv
                return newEnv
            }
        }
        set {
            Thread.current.threadDictionary["NimbleEnvironment"] = newValue
        }
    }

    // swiftlint:disable:next todo
    // TODO: eventually migrate the global to this environment value
    var assertionHandler: AssertionHandler {
        get { return NimbleAssertionHandler }
        set { NimbleAssertionHandler = newValue }
    }

    var suppressTVOSAssertionWarning: Bool = false
    var awaiter: Awaiter

    override init() {
        let timeoutQueue = DispatchQueue.global(qos: .userInitiated)
        awaiter = Awaiter(
            waitLock: AssertionWaitLock(),
            asyncQueue: .main,
            timeoutQueue: timeoutQueue
        )

        super.init()
    }
}

/// Encapsulates the failure message that matchers can report to the end user.
///
/// This is shared state between Nimble and matchers that mutate this value.
public class FailureMessage: NSObject {
    public var expected: String = "expected"
    public var actualValue: String? = "" // empty string -> use default; nil -> exclude
    public var to: String = "to"
    public var postfixMessage: String = "match"
    public var postfixActual: String = ""
    /// An optional message that will be appended as a new line and provides additional details
    /// about the failure. This message will only be visible in the issue navigator / in logs but
    /// not directly in the source editor since only a single line is presented there.
    public var extendedMessage: String?
    public var userDescription: String?

    public var stringValue: String {
        get {
            if let value = _stringValueOverride {
                return value
            } else {
                return computeStringValue()
            }
        }
        set {
            _stringValueOverride = newValue
        }
    }

    // swiftlint:disable:next identifier_name
    internal var _stringValueOverride: String?
    internal var hasOverriddenStringValue: Bool {
        return _stringValueOverride != nil
    }

    public override init() {
    }

    public init(stringValue: String) {
        _stringValueOverride = stringValue
    }

    internal func stripNewlines(_ str: String) -> String {
        let whitespaces = CharacterSet.whitespacesAndNewlines
        return str
            .components(separatedBy: "\n")
            .map { line in line.trimmingCharacters(in: whitespaces) }
            .joined(separator: "")
    }

    internal func computeStringValue() -> String {
        var value = "\(expected) \(to) \(postfixMessage)"
        if let actualValue = actualValue {
            value = "\(expected) \(to) \(postfixMessage), got \(actualValue)\(postfixActual)"
        }
        value = stripNewlines(value)

        if let extendedMessage = extendedMessage {
            value += "\n\(stripNewlines(extendedMessage))"
        }

        if let userDescription = userDescription {
            return "\(userDescription)\n\(value)"
        }

        return value
    }

    internal func appendMessage(_ msg: String) {
        if hasOverriddenStringValue {
            stringValue += "\(msg)"
        } else if actualValue != nil {
            postfixActual += msg
        } else {
            postfixMessage += msg
        }
    }

    internal func appendDetails(_ msg: String) {
        if hasOverriddenStringValue {
            if let desc = userDescription {
                stringValue = "\(desc)\n\(stringValue)"
            }
            stringValue += "\n\(msg)"
        } else {
            if let desc = userDescription {
                userDescription = desc
            }
            extendedMessage = msg
        }
    }
}

/// Quick/Nimble/Utils/SourceLocation.swift
// Ideally we would always use `StaticString` as the type for tracking the file name
// that expectations originate from, for consistency with `assert` etc. from the
// stdlib, and because recent versions of the XCTest overlay require `StaticString`
// when calling `XCTFail`. Under the Objective-C runtime (i.e. building on Mac), we
// have to use `String` instead because StaticString can't be generated from Objective-C
#if SWIFT_PACKAGE
public typealias FileString = StaticString
#else
public typealias FileString = String
#endif

public final class SourceLocation: NSObject {
    public let file: FileString
    public let line: UInt

    override init() {
        file = "Unknown File"
        line = 0
    }

    init(file: FileString, line: UInt) {
        self.file = file
        self.line = line
    }

    override public var description: String {
        return "\(file):\(line)"
    }
}

/// Quick/Nimble/Utils/Await.swift
internal class Awaiter {
    let waitLock: WaitLock
    let timeoutQueue: DispatchQueue
    let asyncQueue: DispatchQueue

    internal init(
        waitLock: WaitLock,
        asyncQueue: DispatchQueue,
        timeoutQueue: DispatchQueue) {
            self.waitLock = waitLock
            self.asyncQueue = asyncQueue
            self.timeoutQueue = timeoutQueue
    }

    private func createTimerSource(_ queue: DispatchQueue) -> DispatchSourceTimer {
        return DispatchSource.makeTimerSource(flags: .strict, queue: queue)
    }

    func performBlock<T>(
        file: FileString,
        line: UInt,
        _ closure: @escaping (@escaping (T) -> Void) throws -> Void
        ) -> AwaitPromiseBuilder<T> {
            let promise = AwaitPromise<T>()
            let timeoutSource = createTimerSource(timeoutQueue)
            var completionCount = 0
            let trigger = AwaitTrigger(timeoutSource: timeoutSource, actionSource: nil) {
                try closure { result in
                    completionCount += 1
                    if completionCount < 2 {
                        func completeBlock() {
                            if promise.resolveResult(.completed(result)) {
                                CFRunLoopStop(CFRunLoopGetMain())
                            }
                        }

                        if Thread.isMainThread {
                            completeBlock()
                        } else {
                            DispatchQueue.main.async { completeBlock() }
                        }
                    } else {
                        fail("waitUntil(..) expects its completion closure to be only called once",
                             file: file, line: line)
                    }
                }
            }

            return AwaitPromiseBuilder(
                awaiter: self,
                waitLock: waitLock,
                promise: promise,
                trigger: trigger)
    }

    func poll<T>(_ pollInterval: TimeInterval, closure: @escaping () throws -> T?) -> AwaitPromiseBuilder<T> {
        let promise = AwaitPromise<T>()
        let timeoutSource = createTimerSource(timeoutQueue)
        let asyncSource = createTimerSource(asyncQueue)
        let trigger = AwaitTrigger(timeoutSource: timeoutSource, actionSource: asyncSource) {
            let interval = DispatchTimeInterval.nanoseconds(Int(pollInterval * TimeInterval(NSEC_PER_SEC)))
            asyncSource.schedule(deadline: .now(), repeating: interval, leeway: pollLeeway)
            asyncSource.setEventHandler {
                do {
                    if let result = try closure() {
                        if promise.resolveResult(.completed(result)) {
                            CFRunLoopStop(CFRunLoopGetCurrent())
                        }
                    }
                } catch let error {
                    if promise.resolveResult(.errorThrown(error)) {
                        CFRunLoopStop(CFRunLoopGetCurrent())
                    }
                }
            }
            asyncSource.resume()
        }

        return AwaitPromiseBuilder(
            awaiter: self,
            waitLock: waitLock,
            promise: promise,
            trigger: trigger)
    }
}

internal protocol WaitLock {
    func acquireWaitingLock(_ fnName: String, file: FileString, line: UInt)
    func releaseWaitingLock()
    func isWaitingLocked() -> Bool
}

/// Stores debugging information about callers
internal struct WaitingInfo: CustomStringConvertible {
    let name: String
    let file: FileString
    let lineNumber: UInt

    var description: String {
        return "\(name) at \(file):\(lineNumber)"
    }
}

internal class AssertionWaitLock: WaitLock {
    private var currentWaiter: WaitingInfo?
    init() { }

    func acquireWaitingLock(_ fnName: String, file: FileString, line: UInt) {
        let info = WaitingInfo(name: fnName, file: file, lineNumber: line)
        let isMainThread = Thread.isMainThread
        nimblePrecondition(
            isMainThread,
            "InvalidNimbleAPIUsage",
            "\(fnName) can only run on the main thread."
        )
        nimblePrecondition(
            currentWaiter == nil,
            "InvalidNimbleAPIUsage",
            """
            Nested async expectations are not allowed to avoid creating flaky tests.

            The call to
            \t\(info)
            triggered this exception because
            \t\(currentWaiter!)
            is currently managing the main run loop.
            """
        )
        currentWaiter = info
    }

    func isWaitingLocked() -> Bool {
        return currentWaiter != nil
    }

    func releaseWaitingLock() {
        currentWaiter = nil
    }
}

internal struct AwaitTrigger {
    let timeoutSource: DispatchSourceTimer
    let actionSource: DispatchSourceTimer?
    let start: () throws -> Void
}

internal enum AwaitResult<T> {
    /// Incomplete indicates None (aka - this value hasn't been fulfilled yet)
    case incomplete
    /// TimedOut indicates the result reached its defined timeout limit before returning
    case timedOut
    /// BlockedRunLoop indicates the main runloop is too busy processing other blocks to trigger
    /// the timeout code.
    ///
    /// This may also mean the async code waiting upon may have never actually ran within the
    /// required time because other timers & sources are running on the main run loop.
    case blockedRunLoop
    /// The async block successfully executed and returned a given result
    case completed(T)
    /// When a Swift Error is thrown
    case errorThrown(Error)
    /// When an Objective-C Exception is raised
    case raisedException(NSException)

    func isIncomplete() -> Bool {
        switch self {
        case .incomplete: return true
        default: return false
        }
    }

    func isCompleted() -> Bool {
        switch self {
        case .completed: return true
        default: return false
        }
    }
}

/// Holds the resulting value from an asynchronous expectation.
/// This class is thread-safe at receiving an "response" to this promise.
internal final class AwaitPromise<T> {
    private(set) internal var asyncResult: AwaitResult<T> = .incomplete
    private var signal: DispatchSemaphore

    init() {
        signal = DispatchSemaphore(value: 1)
    }

    deinit {
        signal.signal()
    }

    /// Resolves the promise with the given result if it has not been resolved. Repeated calls to
    /// this method will resolve in a no-op.
    ///
    /// @returns a Bool that indicates if the async result was accepted or rejected because another
    ///          value was received first.
    func resolveResult(_ result: AwaitResult<T>) -> Bool {
        if signal.wait(timeout: .now()) == .success {
            self.asyncResult = result
            return true
        } else {
            return false
        }
    }
}

private let timeoutLeeway = DispatchTimeInterval.milliseconds(1)
private let pollLeeway = DispatchTimeInterval.milliseconds(1)

/// Factory for building fully configured AwaitPromises and waiting for their results.
///
/// This factory stores all the state for an async expectation so that Await doesn't
/// doesn't have to manage it.
internal class AwaitPromiseBuilder<T> {
    let awaiter: Awaiter
    let waitLock: WaitLock
    let trigger: AwaitTrigger
    let promise: AwaitPromise<T>

    internal init(
        awaiter: Awaiter,
        waitLock: WaitLock,
        promise: AwaitPromise<T>,
        trigger: AwaitTrigger) {
            self.awaiter = awaiter
            self.waitLock = waitLock
            self.promise = promise
            self.trigger = trigger
    }

    func timeout(_ timeoutInterval: TimeInterval, forcefullyAbortTimeout: TimeInterval) -> Self {
        // = Discussion =
        //
        // There's a lot of technical decisions here that is useful to elaborate on. This is
        // definitely more lower-level than the previous NSRunLoop based implementation.
        //
        //
        // Why Dispatch Source?
        //
        //
        // We're using a dispatch source to have better control of the run loop behavior.
        // A timer source gives us deferred-timing control without having to rely as much on
        // a run loop's traditional dispatching machinery (eg - NSTimers, DefaultRunLoopMode, etc.)
        // which is ripe for getting corrupted by application code.
        //
        // And unlike dispatch_async(), we can control how likely our code gets prioritized to
        // executed (see leeway parameter) + DISPATCH_TIMER_STRICT.
        //
        // This timer is assumed to run on the HIGH priority queue to ensure it maintains the
        // highest priority over normal application / test code when possible.
        //
        //
        // Run Loop Management
        //
        // In order to properly interrupt the waiting behavior performed by this factory class,
        // this timer stops the main run loop to tell the waiter code that the result should be
        // checked.
        //
        // In addition, stopping the run loop is used to halt code executed on the main run loop.
        trigger.timeoutSource.schedule(
            deadline: DispatchTime.now() + timeoutInterval,
            repeating: .never,
            leeway: timeoutLeeway
        )
        trigger.timeoutSource.setEventHandler {
            guard self.promise.asyncResult.isIncomplete() else { return }
            let timedOutSem = DispatchSemaphore(value: 0)
            let semTimedOutOrBlocked = DispatchSemaphore(value: 0)
            semTimedOutOrBlocked.signal()
            let runLoop = CFRunLoopGetMain()
            #if canImport(Darwin)
                let runLoopMode = CFRunLoopMode.defaultMode.rawValue
            #else
                let runLoopMode = kCFRunLoopDefaultMode
            #endif
            CFRunLoopPerformBlock(runLoop, runLoopMode) {
                if semTimedOutOrBlocked.wait(timeout: .now()) == .success {
                    timedOutSem.signal()
                    semTimedOutOrBlocked.signal()
                    if self.promise.resolveResult(.timedOut) {
                        CFRunLoopStop(CFRunLoopGetMain())
                    }
                }
            }
            // potentially interrupt blocking code on run loop to let timeout code run
            CFRunLoopStop(runLoop)
            let now = DispatchTime.now() + forcefullyAbortTimeout
            let didNotTimeOut = timedOutSem.wait(timeout: now) != .success
            let timeoutWasNotTriggered = semTimedOutOrBlocked.wait(timeout: .now()) == .success
            if didNotTimeOut && timeoutWasNotTriggered {
                if self.promise.resolveResult(.blockedRunLoop) {
                    CFRunLoopStop(CFRunLoopGetMain())
                }
            }
        }
        return self
    }

    /// Blocks for an asynchronous result.
    ///
    /// @discussion
    /// This function must be executed on the main thread and cannot be nested. This is because
    /// this function (and it's related methods) coordinate through the main run loop. Tampering
    /// with the run loop can cause undesirable behavior.
    ///
    /// This method will return an AwaitResult in the following cases:
    ///
    /// - The main run loop is blocked by other operations and the async expectation cannot be
    ///   be stopped.
    /// - The async expectation timed out
    /// - The async expectation succeeded
    /// - The async expectation raised an unexpected exception (objc)
    /// - The async expectation raised an unexpected error (swift)
    ///
    /// The returned AwaitResult will NEVER be .incomplete.
    func wait(_ fnName: String = #function, file: FileString = #file, line: UInt = #line) -> AwaitResult<T> {
        waitLock.acquireWaitingLock(
            fnName,
            file: file,
            line: line)

        let capture = NMBExceptionCapture(handler: ({ exception in
            _ = self.promise.resolveResult(.raisedException(exception))
        }), finally: ({
            self.waitLock.releaseWaitingLock()
        }))
        capture.tryBlock {
            do {
                try self.trigger.start()
            } catch let error {
                _ = self.promise.resolveResult(.errorThrown(error))
            }
            self.trigger.timeoutSource.resume()
            while self.promise.asyncResult.isIncomplete() {
                // Stopping the run loop does not work unless we run only 1 mode
                _ = RunLoop.current.run(mode: .default, before: .distantFuture)
            }

            self.trigger.timeoutSource.cancel()
            if let asyncSource = self.trigger.actionSource {
                asyncSource.cancel()
            }
        }

        return promise.asyncResult
    }
}

/// Like Swift's precondition(), but raises NSExceptions instead of sigaborts
internal func nimblePrecondition(
    _ expr: @autoclosure() -> Bool,
    _ name: @autoclosure() -> String,
    _ message: @autoclosure() -> String,
    file: StaticString = #file,
    line: UInt = #line) {
        let result = expr()
        if !result {
#if canImport(Darwin)
            let exception = NSException(
                name: NSExceptionName(name()),
                reason: message(),
                userInfo: nil
            )
            exception.raise()
#else
            preconditionFailure("\(name()) - \(message())", file: file, line: line)
#endif
        }
}

internal func internalError(_ msg: String, file: FileString = #file, line: UInt = #line) -> Never {
    // swiftlint:disable line_length
    fatalError(
        """
        Nimble Bug Found: \(msg) at \(file):\(line).
        Please file a bug to Nimble: https://github.com/Quick/Nimble/issues with the code snippet that caused this error.
        """
    )
    // swiftlint:enable line_length
}

/// Always fails the test with a message and a specified location.
public func fail(_ message: String, location: SourceLocation) {
    let handler = NimbleEnvironment.activeInstance.assertionHandler
    handler.assert(false, message: FailureMessage(stringValue: message), location: location)
}

/// Always fails the test with a message.
public func fail(_ message: String, file: FileString = #file, line: UInt = #line) {
    fail(message, location: SourceLocation(file: file, line: line))
}

/// Always fails the test.
public func fail(_ file: FileString = #file, line: UInt = #line) {
    fail("fail() always fails", file: file, line: line)
}

/// Default handler for Nimble. This assertion handler passes failures along to
/// XCTest.
public class NimbleXCTestHandler: AssertionHandler {
    public func assert(_ assertion: Bool, message: FailureMessage, location: SourceLocation) {
        if !assertion {
            recordFailure("\(message.stringValue)\n", location: location)
        }
    }
}

#if !SWIFT_PACKAGE
/// Helper class providing access to the currently executing XCTestCase instance, if any
@objc final internal class CurrentTestCaseTracker: NSObject, XCTestObservation {
    @objc static let sharedInstance = CurrentTestCaseTracker()

    private(set) var currentTestCase: XCTestCase?

    private var stashed_swift_reportFatalErrorsToDebugger: Bool = false

    @objc func testCaseWillStart(_ testCase: XCTestCase) {
        #if os(macOS) || os(iOS)
        stashed_swift_reportFatalErrorsToDebugger = _swift_reportFatalErrorsToDebugger
        _swift_reportFatalErrorsToDebugger = false
        #endif

        currentTestCase = testCase
    }

    @objc func testCaseDidFinish(_ testCase: XCTestCase) {
        currentTestCase = nil

        #if os(macOS) || os(iOS)
        _swift_reportFatalErrorsToDebugger = stashed_swift_reportFatalErrorsToDebugger
        #endif
    }
}
#endif

public func recordFailure(_ message: String, location: SourceLocation) {
#if SWIFT_PACKAGE
    XCTFail("\(message)", file: location.file, line: location.line)
#else
    if let testCase = CurrentTestCaseTracker.sharedInstance.currentTestCase {
        let line = Int(location.line)
        testCase.recordFailure(withDescription: message, inFile: location.file, atLine: line, expected: true)
    } else {
        let msg = """
            Attempted to report a test failure to XCTest while no test case was running. The failure was:
            \"\(message)\"
            It occurred at: \(location.file):\(location.line)
            """
        NSException(name: .internalInconsistencyException, reason: msg, userInfo: nil).raise()
    }
#endif
}


// Quick/Nimble/Adapters/NonObjectiveC
#if !canImport(Darwin)
// swift-corelibs-foundation doesn't provide NSException at all, so provide a dummy
class NSException {}
#endif

// NOTE: This file is not intended to be included in the Xcode project. It
//       is picked up by the Swift Package Manager during its build process.

/// A dummy reimplementation of the `NMBExceptionCapture` class to serve
/// as a stand-in for build and runtime environments that don't support
/// Objective C.
internal class ExceptionCapture {
    let finally: (() -> Void)?

    init(handler: ((NSException) -> Void)?, finally: (() -> Void)?) {
        self.finally = finally
    }

    func tryBlock(_ unsafeBlock: (() -> Void)) {
        // We have no way of handling Objective C exceptions in Swift,
        // so we just go ahead and run the unsafeBlock as-is
        unsafeBlock()

        finally?()
    }
}

/// Compatibility with the actual Objective-C implementation
typealias NMBExceptionCapture = ExceptionCapture
