//
//  Created by Marko Justinek on 31/7/21.
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

import Foundation

#if compiler(>=5.5)
// This is ridiculous! This works when building on macOS 11+.
@_implementationOnly import PactSwiftMockServer
#else
import PactSwiftMockServer
#endif

/// Defines the transfer protocol on which `MockService` runs.
@objc public enum TransferProtocol: Int {
	case standard
	case secure

	var bridge: PactSwiftMockServer.TransferProtocol {
		switch self {
		case .standard: return .standard
		case .secure: return .secure
		}
	}
}

extension TransferProtocol {

	/// HTTP Transfer protocol
	var `protocol`: String {
		switch self {
		case .standard: return "http"
		case .secure: return "https"
		}
	}

}
