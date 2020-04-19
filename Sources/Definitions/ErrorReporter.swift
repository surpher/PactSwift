//
//  ErrorReporter.swift
//  PactSwift
//
//  Created by Marko Justinek on 20/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation
import Nimble

class ErrorReporter: ErrorReportable {

	func reportFailure(_ message: String) {
		fail(message)
	}

	func reportFailure(_ message: String, file: FileString, line: UInt) {
		fail(message, file: file, line: line)
	}

}
