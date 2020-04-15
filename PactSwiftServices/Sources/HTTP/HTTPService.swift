//
//  HTTPService.swift
//  PactServices
//
//  Created by Marko Justinek on 12/4/20.
//  Copyright © 2020 Pact Foundation. All rights reserved.
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
