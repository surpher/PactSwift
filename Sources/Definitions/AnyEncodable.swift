//
//  AnyEncodable.swift
//  PactSwift
//
//  Created by Marko Justinek on 6/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation

struct AnyEncodable: Encodable {

	private let _encode: (Encoder) throws -> Void

	init<T: Encodable>(_ value: T) {
		self._encode = { encoder in
			var container = encoder.singleValueContainer()
			try container.encode(value)
		}
	}

	func encode(to encoder: Encoder) throws {
		try _encode(encoder)
	}

}
