//
//  Request.swift
//  PactSwift
//
//  Created by Marko Justinek on 31/3/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

public struct Request {

	var method: PactHTTPMethod
	var path: Any
	var query: Any?
	var headers: [String: Any]?
	var body: Any?

}
