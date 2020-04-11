//
//  IncludesLike.swift
//  PactSwift
//
//  Created by Marko Justinek on 11/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation

public struct IncludesLike: MatchingRuleExpressible {

	enum IncludeCombine: String {
		case and = "AND"
		case or = "OR"
	}

	internal let value: Any
	internal let combine: IncludeCombine
	internal var rules: [[String: AnyEncodable]] {
		includeStringValues.map {
			[
				"match": AnyEncodable("include"),
				"value": AnyEncodable($0)
			]
		}
	}

	private var includeStringValues: [String]

	// MARK: - Initializers

	init(_ values: String..., combine: IncludeCombine = .and) {
		self.value = values
		self.includeStringValues = values
		self.combine = combine
	}

}
