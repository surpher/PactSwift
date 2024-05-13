//
//  DateTime.swift
//  PactSwift
//
//  Created by Marko Justinek on 13/2/22.
//  Copyright © 2022 Marko Justinek. All rights reserved.
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
		///   - format: The format used for datetime
		///   - use: The `Date` object used in consumer tests
		///
		public init(format: String, use date: Date) {
			self.value = date.formatted(format)
			self.rules = [
				"format": AnyEncodable(format),
			]
		}
	}

}

// MARK: - Objective-C

#if !os(Linux)
@objc
(PFGeneratorDateTime)
public class ObjcDateTime: NSObject, ObjcGenerator {

	let type: ExampleGeneratorExpressible

	/// Generates an example value for DateTime using a specific `Date` for consumer tests
	///
	/// - Parameters:
	///   - format: The format used for datetime
	///   - use: The `Date` object used in consumer tests
	///
	@objc(date: format:)
	public init(format: String, use date: Date) {
		type = ExampleGenerator.DateTime(format: format, use: date)
	}

}
#endif
