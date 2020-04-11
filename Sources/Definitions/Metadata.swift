//
//  Metadata.swift
//  PactSwift
//
//  Created by Marko Justinek on 1/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation

struct Metadata {

	let pactSpec = PactVersion("3.0.0")
	let pactSwift = PactVersion(Bundle.pact.shortVersion!)

	struct PactVersion: Encodable {
		let version: String

		init(_ version: String) {
			self.version = version
		}
	}

}

extension Metadata: Encodable {

	enum CodingKeys: String, CodingKey {
		case pactSpec = "pactSpecification"
		case pactSwift = "pact-swift"
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(pactSpec, forKey: .pactSpec)
		try container.encode(pactSwift, forKey: .pactSwift)
	}

}
