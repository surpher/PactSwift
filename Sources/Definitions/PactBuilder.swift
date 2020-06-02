//
//  EncodableWrapper.swift
//  PactSwift
//
//  Created by Marko Justinek on 7/4/20.
//  Copyright © 2020 Itty Bitty Apps Pty Ltd / PACT Foundation. All rights reserved.
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

struct PactBuilder {

	let typeDefinition: Any

	init(with value: Any) {
		self.typeDefinition = value
	}

	///
	/// Returns a tuple of a Pact Contract interaction's node object (eg, request `body`)
	/// and its corresponding matching rules.
	/// It erases node object's type and casts the node and leaf values into an `Encodable` safe type.
	///
	/// Transforms the following suppoerted types into `AnyEncodable`:
	///
	/// - `String`
	/// - `Int`
	/// - `Double`
	/// - `Array<Encodable>`
	/// - `Dictionary<String, Encodable>`
	///
	func encoded(for interactionNode: PactInteractionNode) throws -> (node: AnyEncodable?, rules: AnyEncodable?) {
		do {
			let processedType = try process(element: typeDefinition, at: "$")
			return (
				node: processedType.node,
				rules: AnyEncodable([interactionNode.rawValue: AnyEncodable(AnyEncodable(processedType.rules))])
			)
		} catch {
			throw EncodingError.notEncodable(typeDefinition)
		}
	}

}

extension PactBuilder {

	enum EncodingError: Error {
		case notEncodable(Any?)
		case unknown

		var localizedDescription: String {
			switch self {
			case .notEncodable(let element):
				return "Error casting '\(String(describing: (element != nil) ? element! : "provided value"))' to a JSON safe Type: String, Int, Double, Decimal, Bool, Dictionary<String, Encodable>, Array<Encodable>)" //swiftlint:disable:this line_length
			default:
				return "Error casting unknown type into an Encodable type!"
			}
		}
	}

}

private extension PactBuilder {

	func process(element: Any, at node: String) throws -> (node: AnyEncodable, rules: [String: AnyEncodable]) {
		let processedElement: (node: AnyEncodable, rules: [String: AnyEncodable])

		switch element {
		case let array as [Any]:
			let processedArray = try process(array, at: node)
			processedElement = (node: AnyEncodable(processedArray.node), rules: processedArray.rules)
		case let dict as [String: Any]:
			let processedDict = try process(dict, at: node)
			processedElement = (node: AnyEncodable(processedDict.node), rules: processedDict.rules)
		case let string as String:
			processedElement = (node: AnyEncodable(string), rules: [:])
		case let integer as Int:
			processedElement = (node: AnyEncodable(integer), rules: [:])
		case let double as Double:
			processedElement = (node: AnyEncodable(double), rules: [:])
		case let decimal as Decimal:
			processedElement = (node: AnyEncodable(decimal), rules: [:])
		case let bool as Bool:
			processedElement = (node: AnyEncodable(bool), rules: [:])
		case let matcher as IncludesLike:
			let processedMatcherValue = try process(element: matcher.value, at: node)
			processedElement = (
				node: processedMatcherValue.node,
				rules: [
					node: AnyEncodable([
						"matchers": AnyEncodable(matcher.rules),
						"combine": AnyEncodable(matcher.combine.rawValue)]
					)
				]
			)
		case let matcher as MatchingRuleExpressible:
			let processedMatcherValue = try process(element: matcher.value, at: node)
			processedElement = (
				node: processedMatcherValue.node,
				rules: [node: AnyEncodable(["matchers": AnyEncodable(matcher.rules)])]
			)
		default:
			throw EncodingError.notEncodable(element)
		}

		return processedElement
	}

	func process(_ array: [Any], at node: String) throws -> (node: [AnyEncodable], rules: [String: AnyEncodable]) {
		var encodableArray = [AnyEncodable]()
		var matchingRules: [String: AnyEncodable] = [:]
		do {
			try array
				.enumerated()
				.forEach {
					let childElement = try process(element: $0.element, at: "\(node)[\($0.offset)]")
					encodableArray.append(childElement.node)
					matchingRules = merge(matchingRules, with: childElement.rules)
				}
			return (node: encodableArray, rules: matchingRules)
		} catch {
			throw EncodingError.notEncodable(array)
		}
	}

	func process(_ dictionary: [String: Any], at node: String) throws -> (node: [String: AnyEncodable], rules: [String: AnyEncodable]) {
		var encodableDictionary: [String: AnyEncodable] = [:]
		var matchingRules: [String: AnyEncodable] = [:]
		do {
			try dictionary
				.enumerated()
				.forEach { dict in
					let childElement = try process(element: dict.element.value, at: "\(node).\(dict.element.key)")
					encodableDictionary[dict.element.key] = childElement.node
					matchingRules = merge(matchingRules, with: childElement.rules)
				}
			return (node: encodableDictionary, rules: matchingRules)
		} catch {
			throw EncodingError.notEncodable(dictionary)
		}
	}

}
