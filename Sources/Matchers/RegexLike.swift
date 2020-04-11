//
//  TermLike.swift
//  PactSwift
//
//  Created by Marko Justinek on 11/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation

public struct RegexLike: MatchingRuleExpressible {

	internal let value: Any
	internal let term: String

	internal var rules: [[String: AnyEncodable]] {
		[
			[
				"match": AnyEncodable("regex"),
				"regex": AnyEncodable(term)
			]
		]
	}

	// MARK: - Iitializer

	init(_ value: String, term: String) {
		self.value = value
		self.term = term
	}

}
