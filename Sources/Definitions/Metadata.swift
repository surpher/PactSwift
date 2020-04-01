//
//  Metadata.swift
//  PactSwift
//
//  Created by Marko Justinek on 1/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

import Foundation

enum Metadata {

	typealias MetadataTypeValue = [String: [String: [String: String]]]

	static let values: MetadataTypeValue = [
		"metadata": [
			"pactSpecification": Metadata.pactSpecVersion,
			"pact-swift": Metadata.pactSwiftVersion
		]
	]

	static private var pactSpecVersion: [String: String] {
		["version": "3.0.0"]
	}

	static private var pactSwiftVersion: [String: String] {
		["version": Bundle.pact.shortVersion!]
	}

}
