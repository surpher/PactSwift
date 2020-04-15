//
//  ProviderState.swift
//  PactSwift
//
//  Created by Marko Justinek on 2/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation

public struct ProviderState: Encodable {

	let name: String
	let params: [String: String]

}

extension ProviderState: Equatable {

	static public func ==(lhs: ProviderState, rhs: ProviderState) -> Bool {
		lhs.name == rhs.name && lhs.params == rhs.params
	}

}
