//
//  Created by Marko Justinek on 7/4/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
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
	let interactionNode: PactInteractionNode

	/// Creates a PactBuilder object which processes the DSL
	///
	/// - Parameters:
	///   - value: The DSL to process and extract matchers and example generators
	///   - interactionNode: The part of interaction to process (eg: `body`, `header` or `query`)
	init(with value: Any, for interactionNode: PactInteractionNode) {
		self.typeDefinition = value
		self.interactionNode = interactionNode
	}

	/// Returns a tuple of a Pact Contract interaction's node object (eg, request `body`)
	/// and its corresponding matching rules and example generators.
	/// It erases node object's type and casts the node and leaf values into an `Encodable`-safe type.
	///
	/// Transforms the following supported types into `AnyEncodable`:
	/// `String`, `Int`, `Double`, `Decimal`, `Bool`, `Array<Encodable>`, `Dictionary<String, Encodable>`, `PactSwift.Matcher<>`, `PactSwift.ExampleGenerator<>`
	func encoded() throws -> (node: AnyEncodable?, rules: AnyEncodable?, generators: AnyEncodable?) {
		do {
			let processedType = try process(element: typeDefinition, at: interactionNode == .body ? "$" : "")
			let node = processedType.node
			let rules = process(matchingRules: processedType.rules)
			let generators = processedType.generators.isEmpty ? nil : AnyEncodable(processedType.generators)

			return (node: node, rules: rules, generators: generators)
		} catch {
			throw EncodingError.notEncodable(typeDefinition)
		}
	}

}

private extension PactBuilder {

	//swiftlint:disable:next cyclomatic_complexity function_body_length
	func process(element: Any, at node: String) throws -> (node: AnyEncodable, rules: [String: AnyEncodable], generators: [String: AnyEncodable]) {
		let processedElement: (node: AnyEncodable, rules: [String: AnyEncodable], generators: [String: AnyEncodable])

		let elementToProcess = mapPactObject(element)

		switch elementToProcess {

		// Collections:

		case let array as [Any]:
			let processedArray = try process(array, at: node)
			processedElement = (node: AnyEncodable(processedArray.node), rules: processedArray.rules, generators: processedArray.generators)

		case let dict as [String: Any]:
			let processedDict = try process(dict, at: node)
			processedElement = (node: AnyEncodable(processedDict.node), rules: processedDict.rules, generators: processedDict.generators)

		// Simple types:

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

		// Matchers:

		case let matcher as Matcher.DecimalLike:
			processedElement = try processMatcher(matcher, at: node)

		case let matcher as Matcher.EachLike:
			processedElement = try processMatcher(matcher, at: node)

		case let matcher as Matcher.EqualTo:
			processedElement = try processMatcher(matcher, at: node)

		case let matcher as Matcher.IncludesLike:
			let processedMatcherValue = try process(element: matcher.value, at: node)
			processedElement = (
				node: processedMatcherValue.node,
				rules: [node: AnyEncodable(["matchers": AnyEncodable(matcher.rules), "combine": AnyEncodable(matcher.combine.rawValue)])],
				generators: processedMatcherValue.generators
			)

		case let matcher as Matcher.IntegerLike:
			processedElement = try processMatcher(matcher, at: node)

		case let matcher as Matcher.MatchNull:
			processedElement = (
				node: AnyEncodable(nil),
				rules: [node: AnyEncodable(["matchers": AnyEncodable(matcher.rules)])],
				generators: [:]
			)

		case let matcher as Matcher.RegexLike:
			processedElement = try processMatcher(matcher, at: node)

		case let matcher as Matcher.SomethingLike:
			processedElement = try processMatcher(matcher, at: node)

		// Example generators:

		case let exampleGenerator as ExampleGenerator.RandomBool:
			processedElement = try processExampleGenerator(exampleGenerator, at: node)

		case let exampleGenerator as ExampleGenerator.RandomDate:
			processedElement = try processExampleGenerator(exampleGenerator, at: node)

		case let exampleGenerator as ExampleGenerator.RandomDateTime:
			processedElement = try processExampleGenerator(exampleGenerator, at: node)

		case let exampleGenerator as ExampleGenerator.RandomDecimal:
			processedElement = try processExampleGenerator(exampleGenerator, at: node)

		case let exampleGenerator as ExampleGenerator.RandomHexadecimal:
			processedElement = try processExampleGenerator(exampleGenerator, at: node)

		case let exampleGenerator as ExampleGenerator.RandomInt:
			processedElement = try processExampleGenerator(exampleGenerator, at: node)

		case let exampleGenerator as ExampleGenerator.RandomString:
			processedElement = try processExampleGenerator(exampleGenerator, at: node)

		case let exampleGenerator as ExampleGenerator.RandomTime:
			processedElement = try processExampleGenerator(exampleGenerator, at: node)

		case let exampleGenerator as ExampleGenerator.RandomUUID:
			processedElement = try processExampleGenerator(exampleGenerator, at: node)

		// Anything else is not considered safe to encode in PactSwift

		default:
			throw EncodingError.notEncodable(element)
		}

		return processedElement
	}

	func processMatcher(_ matcher: MatchingRuleExpressible, at node: String) throws -> (node: AnyEncodable, rules: [String: AnyEncodable], generators: [String: AnyEncodable]) {
		let processedMatcherValue = try process(element: matcher.value, at: node)
		return (
			node: processedMatcherValue.node,
			rules: [node: AnyEncodable(["matchers": AnyEncodable(matcher.rules)])],
			generators: processedMatcherValue.generators
		)
	}

	func processExampleGenerator(_ exampleGenerator: ExampleGeneratorExpressible, at node: String) throws -> (node: AnyEncodable, rules: [String: AnyEncodable], generators: [String: AnyEncodable]) {
		let processedGeneratorValue = try process(element: exampleGenerator.value, at: node)
		return (
			node: processedGeneratorValue.node,
			rules: processedGeneratorValue.rules,
			generators: [node: AnyEncodable(exampleGenerator.attributes)]
		)
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

	// Processes the rules and handles the specific rule handling for Request path
	func process(matchingRules: [String: AnyEncodable]) -> AnyEncodable? {
		if interactionNode == .path, let pathRulesKey = matchingRules.keys.first, pathRulesKey.isEmpty == true {
			return AnyEncodable(matchingRules.values.first)
		} else {
			return matchingRules.isEmpty ? nil : AnyEncodable(matchingRules)
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
					let childElement = try process(element: $0.element, at: interactionNode == .body ? "\(node)[\($0.offset)]" : "\(node)")
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
					let childElement = try process(element: $0.element.value, at: node.isEmpty ? "\($0.element.key)" : "\(node).\($0.element.key)")
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
