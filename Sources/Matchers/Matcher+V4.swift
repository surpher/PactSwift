//
//  Created by Oliver Jones on 12/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
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

// MARK: - Pact Specification v4 matchers

public extension Matcher {

	/// A matcher that checks that the actual array contains an element matching every provided
	/// variant.
	///
	/// Each variant is an example object whose values may themselves be matchers. Variant order
	/// does not matter, and the actual array may contain additional elements.
	///
	/// For example, to assert that a HAL `actions` array contains both an "add-item" and a
	/// "delete-item" action:
	///
	/// ```swift
	/// .arrayContains([
	///   ["name": .regex("add\\-item", example: "add-item"), "method": .regex("POST", example: "POST")],
	///   ["name": .regex("delete\\-item", example: "delete-item"), "method": .regex("DELETE", example: "DELETE")],
	/// ])
	/// ```
	///
	/// - Note: Requires `Pact.Specification.v4`.
	/// - Parameters:
	///   - variants: Example objects describing the variants that the actual array must satisfy.
	///
	static func arrayContains(_ variants: [[String: AnyMatcher]]) -> AnyMatcher {
		ArrayContainsMatcher(variants: variants).asAny()
	}

	/// A matcher that checks that the actual array contains an element matching every provided
	/// variant.
	///
	/// Variant order does not matter, and the actual array may contain additional elements. Use
	/// this overload for matcher-wrapped scalar, array, or otherwise prebuilt variants.
	///
	/// - Note: Requires `Pact.Specification.v4`.
	/// - Parameters:
	///   - variants: Matchers describing the variants that the actual array must satisfy.
	///
	static func arrayContains(_ variants: [AnyMatcher]) -> AnyMatcher {
		ArrayContainsMatcher(variants: variants).asAny()
	}

	/// A matcher that checks the response status against a status class or explicit set of codes.
	///
	/// - Note: Requires `Pact.Specification.v4`.
	/// - Parameters:
	///   - statusCode: The status class or explicit status codes that are accepted.
	///
	static func statusCode(_ statusCode: HTTPStatus) -> AnyMatcher {
		switch statusCode {
		case .information:
			return GenericMatcher(type: "statusCode", value: "information").asAny()
		case .success:
			return GenericMatcher(type: "statusCode", value: "success").asAny()
		case .redirect:
			return GenericMatcher(type: "statusCode", value: "redirect").asAny()
		case .clientError:
			return GenericMatcher(type: "statusCode", value: "clientError").asAny()
		case .serverError:
			return GenericMatcher(type: "statusCode", value: "serverError").asAny()
		case .nonError:
			return GenericMatcher(type: "statusCode", value: "nonError").asAny()
		case .error:
			return GenericMatcher(type: "statusCode", value: "error").asAny()
		case .statusCodes(let codes):
			return GenericMatcher(type: "statusCode", value: codes).asAny()
		}
	}

	/// A matcher that requires a value to be present, non-null, and not an empty string.
	///
	/// - Note: Requires `Pact.Specification.v4`.
	///
	static func notEmpty() -> AnyMatcher {
		GenericMatcher(type: "notEmpty", value: "non-empty").asAny()
	}

	/// A matcher that requires the string representation of a value to be a valid semantic version.
	///
	/// - Note: Requires `Pact.Specification.v4`.
	///
	/// - Parameters:
	///   - value: An example semantic version, such as `"1.2.3"`.
	///
	static func semver(_ value: String) -> AnyMatcher {
		GenericMatcher(type: "semver", value: value).asAny()
	}

	// TODO: "eachKey", "eachValue"
}
