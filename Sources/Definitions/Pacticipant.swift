//
//  Pacticipant.swift
//  PactSwift
//
//  Created by Marko Justinek on 1/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation

public enum Pacticipant {

	case consumer(String)
	case provider(String)

	var name: String {
		switch self {
		case .consumer(let name),
				 .provider(let name):
			return name
		}
	}

}

extension Pacticipant: Encodable {

	enum CodingKeys: CodingKey {
		case name
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(name, forKey: .name)
	}

}
