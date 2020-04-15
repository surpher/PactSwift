//
//  EachLike.swift
//  PactSwift
//
//  Created by Marko Justinek on 10/4/20.
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

public struct EachLike: MatchingRuleExpressible {

	internal let value: Any
	internal let min: Int?
	internal let max: Int?

	internal var rules: [[String: AnyEncodable]] {
		var ruleValue = ["match": AnyEncodable("type")]
		if let min = min { ruleValue["min"] = AnyEncodable(min) }
		if let max = max { ruleValue["max"] = AnyEncodable(max) }
		return [ruleValue]
	}

	// MARK: - Initializers

	init(_ value: Any) {
		self.value = [value]
		self.min = 1
		self.max = nil
	}

	init(_ value: Any, min: Int) {
		self.value = [value]
		self.min = min
		self.max = nil
	}

	init(_ value: Any, max: Int) {
		self.value = [value]
		self.min = nil
		self.max = max
	}

	init(_ value: Any, min: Int, max: Int) {
		self.value = [value]
		self.min = min
		self.max = max
	}

}
