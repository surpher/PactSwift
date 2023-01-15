//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
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

public enum UUIDFormat: String, CaseIterable {
	/// Simple UUID (e.g 936DA01f9abd4d9d80c702af85c822a8)
	case simple = "simple"

	/// lower-case hyphenated (e.g 936da01f-9abd-4d9d-80c7-02af85c822a8)
	case lowerCaseHyphenated = "lower-case-hyphenated"

	/// Upper-case hyphenated (e.g 936DA01F-9ABD-4D9D-80C7-02AF85C822A8)
	case upperCaseHyphenated = "upper-case-hyphenated"

	/// URN (e.g. urn:uuid:936da01f-9abd-4d9d-80c7-02af85c822a8)
	case urn = "URN"
}

public extension UUIDFormat {
	var matchingRegex: String {
		switch self {
		case .lowerCaseHyphenated:
			return "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
		case .upperCaseHyphenated:
			return "^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$"
		case .simple:
			return "^[0-9a-fA-F]{32}$"
		case .urn:
			return "^urn:uuid:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
		}
	}

	var example: String {
		switch self {
		case .simple:
			return "936DA01f9abd4d9d80c702af85c822a8"
		case .lowerCaseHyphenated:
			return "936da01f-9abd-4d9d-80c7-02af85c822a8"
		case .upperCaseHyphenated:
			return "936DA01F-9ABD-4D9D-80C7-02AF85C822A8"
		case .urn:
			return "urn:uuid:936da01f-9abd-4d9d-80c7-02af85c822a8"
		}
	}
}
