//
//  ErrorReporter.swift
//  PactSwift
//
//  Created by Marko Justinek on 20/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation

struct ErrorReceived {

	var message: String
	var file: String?
	var line: UInt?

}

#if SWIFT_PACKAGE
public typealias FileString = StaticString
#else
public typealias FileString = String
#endif

public protocol ErrorReportable {

	func reportFailure(_ message: String)
	func reportFailure(_ message: String, file: FileString, line: UInt)

}
