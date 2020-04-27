//
//  TypeMatcher.swift
//  PactSwift
//
//  Created by Marko Justinek on 9/4/20.
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
/// Defines a Pact matcher that expects a specific `Type`.
///
/// Use this matcher where you expect a specific `Type` in
/// the interaction between consumer and provider, but the
/// value is not important.
///
/// ```
/// [
///   "foo": SomethingLike("bar"),
///   "bar": SomethingLike(1)
/// ]
/// ```
///
public struct SomethingLike: MatchingRuleExpressible {

	internal let value: Any
	internal let rules: [[String: AnyEncodable]] = [["match": AnyEncodable("type")]]

	// MARK: - Initializers

	///
	/// Defines a Pact matcher that expects a specific `Type`.
	///
	/// - parameter value: The value MockService should expect or respond with
	///
	public init(_ value: Any) {
		self.value = value
	}

}
