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
	///
	struct DateTimeExpression: ExampleGeneratorExpressible {
		internal let value: Any
		internal let generator: ExampleGenerator.Generator = .dateTime
		internal var rules: [String: AnyEncodable]?

		/// Generates an example generator for DateTime using an expression
		///
		/// - Parameters:
		///   - expression: The expression provider should use when verifying
		///   - format: The date time format
		///
		/// - Warning: Not all Pact implementations support this type of example generator!
		///
		public init(expression: String, format: String) {
			let date = Date()
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
	/// - Parameters:
	///   - expression: The expression provider should use when verifying
	///   - format: The date time format
	///
	/// - Warning: Not all Pact implementations support this type of example generator!
	///
	@objc(expression: format:)
	public init(expression: String, format: String) {
		type = ExampleGenerator.DateTimeExpression(expression: expression, format: format)
	}

}
#endif
