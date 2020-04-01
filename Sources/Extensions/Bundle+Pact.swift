//
//  Bundle+Pact.swift
//  PactSwift
//
//  Created by Marko Justinek on 1/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation

extension Bundle {

	static var pact: Bundle {
		Bundle(identifier: "au.com.pact-foundation.PactSwift")!
	}

	var shortVersion: String? {
		object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
	}

}
