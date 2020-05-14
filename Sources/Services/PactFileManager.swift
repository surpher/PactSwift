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

	/// Where Pact contracts are written to.
	///
	/// ## macOS
	/// Running macOS it defaults to app's Documents folder:
	///
	/// (eg: `~/Library/Containers/au.com.pact-foundation.Pact-macOS-Example/Data/Documents`)
	///
	/// If testing a sandboxed macOS app, this is the default location and it can not be overwritten.
	/// If testing a macOS app that is not sandboxed, define a `PACT_DIR` Environment Variable (in the scheme)
	/// with the path to where you want Pact contracts to be written to.
	///
	/// ## iOS/tvOS or non-Xcode project
	///
	/// Default location where Pact contracts are written is `/tmp/pacts`.
	///
	/// For iOS/tvOS you can override
	/// that by defining a `PACT_DIR` Environment Variable.
	///
	static var pactDirectoryPath: String {
		#if os(macOS) || os(OSX)
		let defaultPath = NSHomeDirectory() + "/Documents"
		if isSandboxed {
			debugPrint("App is sandboxed. Using NSHomeDirectory() as the directory for Pact contracts.")
			return defaultPath
		}
		return ProcessInfo.processInfo.environment["PACT_DIR"] ?? defaultPath
		#else
		return ProcessInfo.processInfo.environment["PACT_DIR"] ?? "/tmp/pacts"
		#endif
	}

	static private var pactDirectoryURL: URL {
		URL(fileURLWithPath: pactDirectoryPath, isDirectory: true)
	}

	/// Returns true if the directory where Pact contracts are set to be written to exists.
	/// If it does not exists, it attempts to create it and if successful, returns true.
	static func isPactDirectoryAvailable() -> Bool {
		if !FileManager.default.fileExists(atPath: pactDirectoryPath) {
			do {
				try FileManager.default.createDirectory(at: pactDirectoryURL, withIntermediateDirectories: true, attributes: nil)
			} catch let error as NSError {
				debugPrint("Directory \(pactDirectoryURL) could not be created! \(error.localizedDescription)")
				return false
			}
		}
		return true
	}

	/// Returns true if app is sandboxed
	static private var isSandboxed: Bool {
		let environment = ProcessInfo.processInfo.environment
		return environment["APP_SANDBOX_CONTAINER_ID"] != nil
	}

}
