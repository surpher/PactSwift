//
//  DecimalLike.swift
//  PactSwift
//
//  Created by Marko Justinek on 11/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation

public struct DecimalLike: MatchingRuleExpressible {

	internal let value: Any
	internal let rules: [[String: AnyEncodable]] = [["match": AnyEncodable("decimal")]]

	// MARK: - Initializer

	init(_ value: Decimal) {
		self.value = value
	}
}
