//
//  Created by Marko Justinek on 27/9/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
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

enum PactLoggingLevel {

	case `default`
	case debug
	case error
	case fault
	case info
	case none

	init?(rawValue: String?) {
		switch rawValue {
		case "debug":
			self = .debug
		default:
			self = .none
		}
	}

	var osLogLevelType: OSLogType {
		switch self {
		case .default, .none: return .default
		case .debug: return .debug
		case .error: return .error
		case .fault: return .fault
		case .info: return .info
		}
	}

}
