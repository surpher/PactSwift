//
//  PACTHTTPMethod.swift
//  PactSwift
//
//  Created by Marko Justinek on 31/3/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation

public enum PactHTTPMethod: String {

	case GET = "get"
	case HEAD = "head"
	case POST = "post"
	case PUT = "put"
	case PATCH = "patch"
	case DELETE = "delete"
	case TRACE = "trace"
	case CONNECT = "connect"
	case OPTIONS = "options"

}

extension PactHTTPMethod: Encodable {

	enum CodingKeys: CodingKey {
		case method
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(rawValue)
	}

}
