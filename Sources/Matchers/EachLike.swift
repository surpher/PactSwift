//
//  EachLike.swift
//  PactSwift
//
//  Created by Marko Justinek on 10/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
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
