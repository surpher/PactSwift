//
//  DateTime.swift
//  PactSwift
//
//  Created by Marko Justinek on 13/2/22.
//  Copyright © 2022 PACT Foundation. All rights reserved.
//

import Foundation

public extension ExampleGenerator {

	/// Generates an example for DateTime using a specific `Date`
	struct DateTime: ExampleGeneratorExpressible {
		internal let value: Any
		internal let generator: ExampleGenerator.Generator = .dateTime
		internal var rules: [String: AnyEncodable]?

		/// Generates an example value for DateTime using a specific `Date` for consumer tests
		///
		/// - Parameters:
		///   - date: The `Date` object to use in consumer tests
		///   - format: The format used for datetime
		///
		public init(_ date: Date, format: String) {
			self.value = date.formatted(format)
			self.rules = [
				"format": AnyEncodable(format),
			]
		}
	}

}

// MARK: - Objective-C

#if !os(Linux)
@objc(PFGeneratorDateTime)
public class ObjcDateTime: NSObject, ObjcGenerator {

	let type: ExampleGeneratorExpressible

	/// Generates an example value for DateTime using a specific `Date` for consumer tests
	///
	/// - Parameters:
	///   - use: The `Date` object used in consumer tests
	///   - format: The format used for datetime
	///
	@objc(date: format:)
	public init(use date: Date, format: String) {
		type = ExampleGenerator.DateTime(date, format: format)
	}

}
#endif
