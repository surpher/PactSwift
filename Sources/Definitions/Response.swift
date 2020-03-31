//
//  Response.swift
//  PACTSwift
//
//  Created by Marko Justinek on 31/3/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

struct Response {

	var statusCode: Int
	var headers: [String: Any]?
	var body: Any?

}
