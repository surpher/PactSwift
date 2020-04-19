//
//  ErrorCapture.swift
//  PactSwift
//
//  Created by Marko Justinek on 20/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation

@testable import PactSwift

struct ErrorReceived {

	var message: String
  var file: String?
  var line: UInt?

}

class ErrorCapture: ErrorReportable {

	public var error: ErrorReceived?

	func reportFailure(_ message: String) {
		self.error = ErrorReceived(message: message, file: nil, line: nil)
	}
	
	func reportFailure(_ message: String, file: String, line: UInt) {
		self.error = ErrorReceived(message: message, file: file, line: line)
	}

	func clear() {
		self.error = nil
	}

}
