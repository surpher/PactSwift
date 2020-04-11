//
//  EqualTo.swift
//  PactSwift
//
//  Created by Marko Justinek on 11/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation

public struct EqualTo: MatchingRuleExpressible {

	internal let value: Any
	internal let rules: [[String: AnyEncodable]] = [["match": AnyEncodable("equality")]]

	// MARK: - Initializers

	init(_ value: Any) {
		self.value = value
	}

}
