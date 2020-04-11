//
//  MatchingRuleExpressible.swift
//  PactSwift
//
//  Created by Marko Justinek on 9/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation

protocol MatchingRuleExpressible {

	var value: Any { get }
	var rules: [[String: AnyEncodable]] { get }

}
