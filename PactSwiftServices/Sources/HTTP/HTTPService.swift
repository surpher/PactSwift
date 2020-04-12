//
//  HTTPService.swift
//  PactServices
//
//  Created by Marko Justinek on 12/4/20.
//  Copyright © 2020 Pact Foundation. All rights reserved.
//

import Foundation
import os.log

class HTTPService {

	// MARK: - Properties

	let log: OSLog

	private let urlSession: URLSession

	// MARK: - Lifecycle

	init(configuration: URLSessionConfiguration, log: OSLog) {
		self.log = log
		self.urlSession = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
	}

	deinit {
		urlSession.invalidateAndCancel()
	}

}
