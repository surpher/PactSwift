//
//  Dictionary+PACT.swift
//  PactSwift
//
//  Created by Marko Justinek on 31/3/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

/// Merges two `Dictionary` objects and returns a `Dictionary`
func merge<Key, Value>(_ lhs: [Key: Value], with rhs: [Key: Value]) -> [Key: Value] {
	var result = lhs
	rhs.forEach { result[$0] = $1 }
	return result
}
