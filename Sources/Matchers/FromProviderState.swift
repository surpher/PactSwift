//
//  Created by Marko Justinek on 15/8/21.
//  Copyright © 2021 Marko Justinek. All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

import Foundation

public extension Matcher {

	/// Matches the value provided by the provider state
	struct FromProviderState: MatchingRuleExpressible, PactPathParameter {

		/// The type of Provider State provided parameter
		public enum ParameterType {
			case bool(Bool)
			case double(Double)
			case float(Float)
			case int(Int)
			case string(String)
			case decimal(Decimal)
		}

		internal var value: Any
		internal let parameter: String
		internal let rules: [[String: AnyEncodable]] = [["match": AnyEncodable("type")]]

		/// Matches the value provided by the provider state
		///
		/// - Parameters:
		///   - parameter: The provider state parameter name
		///   - value: The value to use in consumer test
		///
		public init(parameter: String, value: ParameterType) {
			self.parameter = parameter

			switch value {
			case .bool(let bool): self.value = bool
			case .decimal(let decimal): self.value = decimal
			case .double(let double): self.value = double
			case .float(let float): self.value = float
			case .int(let int): self.value = int
			case .string(let string): self.value = string
			}
		}
	}

}

// MARK: - Objective-C

#if !os(Linux)
@objc(PFMatcherFromProviderState)
public class ObjcFromProviderState: NSObject, ObjcMatcher {

	let type: MatchingRuleExpressible

	/// Matches the value provided by the provider state
	///
	/// - Parameters:
	///   - parameter: The provider state parameter name
	///   - value: The `Bool` value to use in consumer test
	///
	@objc(parameter: withBoolValue:)
	public init(parameter: String, value: Bool) {
		type = Matcher.FromProviderState(parameter: parameter, value: .bool(value))
	}

	/// Matches the value provided by the provider state
	///
	/// - Parameters:
	///   - parameter: The provider state parameter name
	///   - value: The `Double` value to use in consumer test
	///
	@objc(parameter: withDoubleValue:)
	public init(parameter: String, value: Double) {
		type = Matcher.FromProviderState(parameter: parameter, value: .double(value))
	}

	/// Matches the value provided by the provider state
	///
	/// - Parameters:
	///   - parameter: The provider state parameter name
	///   - value: The `Float` value to use in consumer test
	///
	@objc(parameter: withFloatValue:)
	public init(parameter: String, value: Float) {
		type = Matcher.FromProviderState(parameter: parameter, value: .float(value))
	}

	/// Matches the value provided by the provider state
	///
	/// - Parameters:
	///   - parameter: The provider state parameter name
	///   - value: The `Int` value to use in consumer test
	///
	@objc(parameter: withIntValue:)
	public init(parameter: String, value: Int) {
		type = Matcher.FromProviderState(parameter: parameter, value: .int(value))
	}

	/// Matches the value provided by the provider state
	///
	/// - Parameters:
	///   - parameter: The provider state parameter name
	///   - value: The `String` value to use in consumer test
	///
	@objc(parameter: withStringValue:)
	public init(parameter: String, value: String) {
		type = Matcher.FromProviderState(parameter: parameter, value: .string(value))
	}

	/// Matches the value provided by the provider state
	///
	/// - Parameters:
	///   - parameter: The provider state parameter name
	///   - value: The `Decimal` value to use in consumer test
	///
	@objc(parameter: withDecimalValue:)
	public init(parameter: String, value: Decimal) {
		type = Matcher.FromProviderState(parameter: parameter, value: .decimal(value))
	}

}
#endif
