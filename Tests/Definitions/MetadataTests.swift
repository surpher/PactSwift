//
//  Created by Marko Justinek on 1/4/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
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

import XCTest

@testable import PactSwift

class MetadataTests: XCTestCase {

	func testMetadata_SetsPactSpecificationVersion() {
		XCTAssertEqual(Metadata().pactSpec.version, "3.0.0")
	}

	func testMetadata_SetsPactSwiftVersion() throws {
		guard let expectedResult = bundleVersion() else {
			XCTFail("Expexted version number")
			return
		}
		XCTAssertEqual(try XCTUnwrap(Metadata().pactSwift.version), expectedResult)
	}

}

private extension MetadataTests {

	func bundleVersion() -> String? {
		#if os(iOS)
		return Bundle(identifier: "au.com.pact-foundation.iOS.PactSwift")?.infoDictionary?["CFBundleShortVersionString"] as? String
		#elseif os(macOS)
		return Bundle(identifier: "au.com.pact-foundation.macOS.PactSwift")?.infoDictionary?["CFBundleShortVersionString"] as? String ?? pactSwiftVersion
		#endif
	}

}
