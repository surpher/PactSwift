//
//  Created by José Jeria on 8/7/2026.
//  Copyright © 2026 José Jeria. All rights reserved.
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

/// A ``Matcher`` for the `arrayContains` matching rule.
///
/// It serialises to the integration JSON format expected by the Pact FFI:
///
/// ```json
/// {
///   "pact:matcher:type": "arrayContains",
///   "variants": [ ... ]
/// }
/// ```
///
/// Each variant is an example value (typically an object) that may contain nested
/// matchers inline. The FFI extracts those nested matchers into per-variant rules.
struct ArrayContainsMatcher<Variant: Encodable>: Matcher {

	var variants: [Variant]

	enum CodingKeys: String, CodingKey {
		case type = "pact:matcher:type"
		case variants
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode("arrayContains", forKey: .type)
		try container.encode(variants, forKey: .variants)
	}
}
