//
//  EachLike.swift
//  PactSwift
//
//  Created by Marko Justinek on 31/3/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

public struct EachLike {

	let min: Int
	let value: [String: Any]

	init(value: [String: Any], min: Int = 1) {
		self.min = min
		self.value = value
	}

}
