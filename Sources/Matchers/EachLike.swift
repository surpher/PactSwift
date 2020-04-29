//
//  EachLike.swift
//  PactSwift
//
//  Created by Marko Justinek on 10/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
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

///
/// Defines a Pact matcher for a `Set` but does not care about the actual values.
///
/// Use this matcher when you expect a `Set` of values.
/// You can specifiy the expected minimum and maximum
/// occurrances of elements, but the actual values are
/// not important. Can contain other matchers.
///
/// ```
/// [
///   "related_ids": EachLike(1, min: 2), // Set of 0-2 ints
///   "names": EachLike("John", min: 1, max: 3), // Set of 1-3 strings
///   "elements": EachLike(
///     [
///       "foo": "bar",
///       "bar": "baz"
///     ],
///     max: 10
///   ) // Set of 0 - 10 objects.
/// ```
///
public struct EachLike: MatchingRuleExpressible {

	internal let value: Any
	internal let min: Int?
	internal let max: Int?

	internal var rules: [[String: AnyEncodable]] {
		var ruleValue = ["match": AnyEncodable("type")]
		if let min = min { ruleValue["min"] = AnyEncodable(min) }
		if let max = max { ruleValue["max"] = AnyEncodable(max) }
		return [ruleValue]
	}

	// MARK: - Initializers

	///
	/// Defines a Pact matcher for a `Set` but does not care about the actual values.
	///
	/// Defines a `Set` where its capacity is of at least `1` occurance of `Value`.
	///
	/// - parameter value: The value to be returned by MockService.
	///
	public init(_ value: Any) {
		self.value = [value]
		self.min = 1
		self.max = nil
	}

	///
	/// Defines a Pact matcher for a `Set` but does not care about the actual values.
	///
	/// Defines a `Set` where its capacity is at least `min` occurances of provided `Value`.
	///
	/// - parameter value: The value to be returned by MockService.
	/// - parameter min: Defines the minimum capacity of the `Set`
	///
	public init(_ value: Any, min: Int) {
		self.value = [value]
		self.min = min
		self.max = nil
	}

	///
	/// Defines a Pact matcher that defines a `Set` but does not care about the actual values.
	///
	/// Defines a `Set` where its capacity can be of `1` to `max` of provided `Value`.
	///
	/// - parameter value: The value to be returned by MockService.
	/// - parameter max: Defines maximum capacity of the `Set`
	///
	public init(_ value: Any, max: Int) {
		self.value = [value]
		self.min = nil
		self.max = max
	}

	///
	/// Defines a Pact matcher for a `Set` but does not care about the actual values.
	///
	/// Defines a `Set` where its capacity can be of `min` to `max` of provided `Value`.
	///
	/// - parameter value: The value to be returned by MockService.
	/// - parameter min: Defines the minimum capacity of the `Set`
	/// - parameter max: Defines maximum capacity of the `Set`
	///
	public init(_ value: Any, min: Int, max: Int) {
		self.value = [value]
		self.min = min
		self.max = max
	}

}
