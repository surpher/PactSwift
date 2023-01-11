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

/// A generic ``Matcher`` for serialising simple matchers to JSON.
struct GenericMatcher<ValueType: Encodable>: Matcher {

	var type: String
	var value: ValueType
	var generator: GeneratorType? = nil
	var min: Int? = nil
	var max: Int? = nil
	var size: Int? = nil
	var digits: Int? = nil
	var format: String? = nil
	var expression: String? = nil
	var regex: String? = nil

	enum CodingKeys: String, CodingKey {
		case type = "pact:matcher:type"
		case generator = "pact:generator:type"
		case value
		case min
		case max
		case size
		case digits
		case format
		case expression
		case regex
	}
}
