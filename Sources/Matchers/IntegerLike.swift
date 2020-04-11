//
//  MatchInteger.swift
//  PactSwift
//
//  Created by Marko Justinek on 11/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation

public struct IntegerLike: MatchingRuleExpressible {

	internal let value: Any
	internal let rules: [[String: AnyEncodable]] = [["match": AnyEncodable("integer")]]

	// MARK: - Initializer

	init(_ value: Int) {
		self.value = value
	}

}
