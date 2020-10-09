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

	/// Returns a tuple of a Pact Contract interaction's node object (eg, request `body`)
	/// and its corresponding matching rules and example generators.
	/// It erases node object's type and casts the node and leaf values into an `Encodable`-safe type.
	///
	/// Transforms the following supported types into `AnyEncodable`:
	///
	/// - `String`
	/// - `Int`
	/// - `Double`
	/// - `Array<Encodable>`
	/// - `Dictionary<String, Encodable>`
	///
	/// - parameter interactionNode: The top level node in PACT contract file
	func encoded(for interactionNode: PactInteractionNode) throws -> (node: AnyEncodable?, rules: AnyEncodable?, generators: AnyEncodable?) {
		do {
			let processedType = try process(element: typeDefinition, at: "$")
			return (
				node: processedType.node,
				rules: processedType.rules.isEmpty ? nil : AnyEncodable([interactionNode.rawValue: AnyEncodable(AnyEncodable(processedType.rules))]),
				generators: processedType.generators.isEmpty ? nil : AnyEncodable([interactionNode.rawValue: AnyEncodable(AnyEncodable(processedType.generators))])
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

	//swiftlint:disable:next cyclomatic_complexity
	func process(element: Any, at node: String) throws -> (node: AnyEncodable, rules: [String: AnyEncodable], generators: [String: AnyEncodable]) {
		let processedElement: (node: AnyEncodable, rules: [String: AnyEncodable], generators: [String: AnyEncodable])

		let elementToProcess = mapPactObject(element)

		switch elementToProcess {
		case let array as [Any]:
			let processedArray = try process(array, at: node)
			processedElement = (node: AnyEncodable(processedArray.node), rules: processedArray.rules, generators: processedArray.generators)

		case let dict as [String: Any]:
			let processedDict = try process(dict, at: node)
			processedElement = (node: AnyEncodable(processedDict.node), rules: processedDict.rules, generators: processedDict.generators)

		case let string as String:
			processedElement = (node: AnyEncodable(string), rules: [:], generators: [:])

		case let integer as Int:
			processedElement = (node: AnyEncodable(integer), rules: [:], generators: [:])

		case let double as Double:
			processedElement = (node: AnyEncodable(double), rules: [:], generators: [:])

		case let decimal as Decimal:
			processedElement = (node: AnyEncodable(decimal), rules: [:], generators: [:])

		case let bool as Bool:
			processedElement = (node: AnyEncodable(bool), rules: [:], generators: [:])

		case let matcher as Matcher.MatchNull:
			processedElement = (node: AnyEncodable(nil), rules: [node: AnyEncodable(["matchers": AnyEncodable(matcher.rules)])], generators: [:])

		case let matcher as Matcher.IncludesLike:
			let processedMatcherValue = try process(element: matcher.value, at: node)
			processedElement = (
				node: processedMatcherValue.node,
				rules: [node: AnyEncodable(["matchers": AnyEncodable(matcher.rules), "combine": AnyEncodable(matcher.combine.rawValue)])],
				generators: processedMatcherValue.generators
			)

		case let matcher as MatchingRuleExpressible:
			let processedMatcherValue = try process(element: matcher.value, at: node)
			processedElement = (
				node: processedMatcherValue.node,
				rules: [node: AnyEncodable(["matchers": AnyEncodable(matcher.rules)])],
				generators: processedMatcherValue.generators
			)

		case let exampleGenerator as ExampleGeneratorExpressible:
			let processedGeneratorValue = try process(element: exampleGenerator.value, at: node)
			processedElement = (
				node: processedGeneratorValue.node,
				rules: processedGeneratorValue.rules,
				generators: [node: AnyEncodable(exampleGenerator.attributes)]
			)

		default:
			throw EncodingError.notEncodable(element)
		}

		return processedElement
	}

	// Maps Objc object to a Swift object
	func mapPactObject(_ value: Any) -> Any {
		switch value {
		case let matcher as ObjcMatcher:
			return matcher.type
		case let generator as ObjcGenerator:
			return generator.type
		default:
			return value
		}
	}

	// Processes the array object and extracts any matchers or generators
	func process(_ array: [Any], at node: String) throws -> (node: [AnyEncodable], rules: [String: AnyEncodable], generators: [String: AnyEncodable]) {
		var encodableArray = [AnyEncodable]()
		var matchingRules: [String: AnyEncodable] = [:]
		var generators: [String: AnyEncodable] = [:]

		do {
			try array
				.enumerated()
				.forEach {
					let childElement = try process(element: $0.element, at: "\(node)[\($0.offset)]")
					encodableArray.append(childElement.node)
					matchingRules = merge(matchingRules, with: childElement.rules)
					generators = merge(generators, with: childElement.generators)
				}
			return (node: encodableArray, rules: matchingRules, generators: generators)
		} catch {
			throw EncodingError.notEncodable(array)
		}
	}

	// Processes a dictionary object and extracts any matchers or generators
	func process(_ dictionary: [String: Any], at node: String) throws -> (node: [String: AnyEncodable], rules: [String: AnyEncodable], generators: [String: AnyEncodable]) {
		var encodableDictionary: [String: AnyEncodable] = [:]
		var matchingRules: [String: AnyEncodable] = [:]
		var generators: [String: AnyEncodable] = [:]

		do {
			try dictionary
				.enumerated()
				.forEach {
					let childElement = try process(element: $0.element.value, at: "\(node).\($0.element.key)")
					encodableDictionary[$0.element.key] = childElement.node
					matchingRules = merge(matchingRules, with: childElement.rules)
					generators = merge(generators, with: childElement.generators)
				}
			return (node: encodableDictionary, rules: matchingRules, generators: generators)
		} catch {
			throw EncodingError.notEncodable(dictionary)
		}
	}

}
