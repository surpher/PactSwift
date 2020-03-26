//
//  Created by Marko Justinek on 29/8/21.
//  Copyright © 2021 Marko Justinek. All rights reserved.
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

final class PactHTTPMehtodTests: XCTestCase {

	func testPactHTTPMethods() {
		XCTAssertEqual(PactHTTPMethod.GET.method, "get")
		XCTAssertEqual(PactHTTPMethod.HEAD.method, "head")
		XCTAssertEqual(PactHTTPMethod.POST.method, "post")
		XCTAssertEqual(PactHTTPMethod.PUT.method, "put")
		XCTAssertEqual(PactHTTPMethod.PATCH.method, "patch")
		XCTAssertEqual(PactHTTPMethod.DELETE.method, "delete")
		XCTAssertEqual(PactHTTPMethod.TRACE.method, "trace")
		XCTAssertEqual(PactHTTPMethod.CONNECT.method, "connect")
		XCTAssertEqual(PactHTTPMethod.OPTIONS.method, "options")
	}

}
