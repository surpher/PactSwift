//
//  DateTimeExpression.swift
//  PactSwift
//
//  Created by Marko Justinek on 5/3/22.
//  Copyright © 2022 Marko Justinek. All rights reserved.
//

import Foundation

extension ExampleGenerator {

	/// Generates a generator for DateTime using an expression
	///
	/// Warning:
	/// Not all Pact impelmentations support this type of example generator!
	struct DateTimeExpression: ExampleGeneratorExpressible {
		internal let value: Any
		internal let generator: ExampleGenerator.Generator = .dateTime
		internal var rules: [String: AnyEncodable]?

		/// Generates an example generator for DateTime using an expression
		///
		/// It uses Swift's `DateFormatter` to cast the provided `Date` object into `String` with the provided `format`.
		/// This `String` is used as the value for consumer tests.
		///
		/// When defining an expression like `"today +1 day @ 6 o'clock pm"`,
		/// it is your responsibility to create and pass the `Date` object that fits the expression for the needs of your tests.
		///
		/// - Parameters:
		///   - format: The date time format
		///   - expression: The expression provider should use when verifying
		///   - use: The `Date` object for the consumer test. It uses the value of `format` in Mock Server's response.
		///
		/// - Warning: Not all Pact implementations support this type of example generator!
		///
		public init(expression: String, format: String, use date: Date) {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = format

			self.value = dateFormatter.string(from: date)
			self.rules = [
				"format": AnyEncodable(format),
				"expression": AnyEncodable(expression),
			]
		}
	}

}

// MARK: - Objective-C

#if !os(Linux)
@objc(PFGeneratorDateTimeExpression)
public class OjbcDateTimeExpression: NSObject, ObjcGenerator {

	let type: ExampleGeneratorExpressible

	/// Generates an example generator for DateTime using an expression
	///
	/// It uses Swift's `DateFormatter` to cast the provided `Date` object into `String` with the provided `format`.
	/// This `String` is used as the value for consumer tests.
	///
	/// When defining an expression like `"today +1 day @ 6 o'clock pm"`,
	/// it is your responsibility to create and pass the `Date` object that fits the expression for the needs of your tests.
	///
	/// - Parameters:
	///   - format: The date time format
	///   - expression: The expression provider should use when verifying
	///   - use: The `Date` object for the consumer test. It uses the value of `format` in Mock Server's response.
	///
	/// - Warning: Not all Pact implementations support this type of example generator!
	///
	@objc(format: expression: date:)
	public init(expression: String, format: String, use date: Date) {
		type = ExampleGenerator.DateTimeExpression(expression: expression, format: format, use: date)
	}

}
#endif
