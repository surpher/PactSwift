//
//  ErrorReporter.swift
//  PactSwift
//
//  Created by Marko Justinek on 15/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation

#if SWIFT_PACKAGE
public typealias FileString = StaticString
#else
public typealias FileString = String
#endif

//public protocol ErrorReporter {
//	func reportFailure(_ message: String)
//	func reportFailure(_ message: String, file: FileString, line: UInt)
//}
