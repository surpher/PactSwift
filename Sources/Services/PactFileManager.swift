//
//  MSFileManager.swift
//  PactSwiftServices
//
//  Created by Marko Justinek on 29/4/20.
//  Copyright © 2020 Itty Bitty Apps Pty Ltd / Pact Foundation. All rights reserved.
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

enum PactFileManager {

	static var pactDir: String {
		ProcessInfo.processInfo.environment["PACT_DIR"] ?? NSTemporaryDirectory() +  "pacts"
	}

	static func checkForPath() -> Bool {
		guard !FileManager.default.fileExists(atPath: PactFileManager.pactDir) else {
			return true
		}
		debugPrint("Path not found: \(PactFileManager.pactDir)")
		return canCreatePath()
	}

	static private func canCreatePath() -> Bool {
		var canCreate = false
		do {
			try FileManager.default.createDirectory(
				atPath: PactFileManager.pactDir,
				withIntermediateDirectories: true,
				attributes: nil
			)
			canCreate.toggle()
		} catch let error as NSError {
			debugPrint("Files not written. Path could not be created: \(PactFileManager.pactDir)")
			debugPrint(error.localizedDescription)
		}
		return canCreate
	}

}
