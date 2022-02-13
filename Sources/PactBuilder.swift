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
	///
	init(with value: Any, for interactionNode: PactInteractionNode) {
		self.typeDefinition = value
		self.interactionNode = interactionNode
	}

	/// Returns a tuple of a Pact Contract interaction's node object (eg, request `body`)
	/// and its corresponding matching rules and example generators.
	/// It erases node object's type and casts the node and leaf values into an `Encodable`-safe type.
	///
	/// Type erases the following `Type` into `AnyEncodable`:
	/// `String`, `Int`, `Double`, `Decimal`, `Bool`, `Array<Encodable>`, `Dictionary<String, Encodable>`, `PactSwift.Matcher<>`, `PactSwift.ExampleGenerator<>`
	///
	func encoded() throws -> (node: AnyEncodable?, rules: AnyEncodable?, generators: AnyEncodable?) {
		let processedType = try process(element: typeDefinition, at: interactionNode == .body ? "$" : "", isEachLike: false)
		let node = processedType.node
		let rules = process(keyValues: processedType.rules)
		let generators = process(keyValues: processedType.generators)

		return (node: node, rules: rules, generators: generators)
	}

}

// MARK: - Private

private extension PactBuilder {

	// swiftlint:disable:next cyclomatic_complexity function_body_length
	func process(element: Any, at node: String, isEachLike: Bool) throws -> (node: AnyEncodable, rules: [String: AnyEncodable], generators: [String: AnyEncodable]) {
		let processedElement: (node: AnyEncodable, rules: [String: AnyEncodable], generators: [String: AnyEncodable])

		let elementToProcess = mapPactObject(element)

		switch elementToProcess {

		// MARK: - Process Collections:

		case let array as [Any]:
			let processedArray = try process(array, at: node, isEachLike: isEachLike)
			processedElement = (node: AnyEncodable(processedArray.node), rules: processedArray.rules, generators: processedArray.generators)

		case let dict as [String: Any]:
			let processedDict = try process(dict, at: node)
			processedElement = (node: AnyEncodable(processedDict.node), rules: processedDict.rules, generators: processedDict.generators)

		// MARK: - Process Simple Types

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

		// MARK: - Process Matchers

		// NOTE: There is a bug in Swift on macOS 10.x where type casting against a protocol does not work as expected.
		// Works fine running on macOS 11.x!
		// That is why each Matcher type is explicitly stated in its own case statement and is not DRY.
		case let matcher as Matcher.DecimalLike:
			processedElement = try processMatcher(matcher, at: node)

		case let matcher as Matcher.EachLike:
			processedElement = try processEachLikeMatcher(matcher, at: node)

		case let matcher as Matcher.EqualTo:
			processedElement = try processMatcher(matcher, at: node)

		case let matcher as Matcher.FromProviderState:
			let stateParameterGenerator = ExampleGenerator.ProviderStateGenerator(parameter: matcher.parameter, value: matcher.value)

			// When processing for path, don't bother with setting the matching rule to "type", as it is always going to be a String
			if interactionNode == .path {
				processedElement = try processExampleGenerator(stateParameterGenerator, at: node)
			} else {
				// When processing for anything else then add the matching rule matching "type" along with provider state generated value
				let processedStateParameter = try processExampleGenerator(stateParameterGenerator, at: node)
				let processedMatcherValue = try processMatcher(matcher, at: node)
				processedElement = (
					node: processedMatcherValue.node,
					rules: processedMatcherValue.rules,
					generators: processedStateParameter.generators
				)
			}

		case let matcher as Matcher.IncludesLike:
			let processedMatcherValue = try process(element: matcher.value, at: node, isEachLike: isEachLike)
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

		case let matcher as Matcher.OneOf:
			processedElement = try processMatcher(matcher, at: node)

		case let matcher as Matcher.RegexLike:
			guard
				let value = matcher.value as? String,
				value.range(of: matcher.pattern, options: .regularExpression) != nil
			else {
				throw EncodingError.encodingFailure("Value \"\(matcher.value)\" does not match the pattern \"\(matcher.pattern)\"")
			}

			processedElement = try processMatcher(matcher, at: node)

		case let matcher as Matcher.SomethingLike:
			processedElement = try processMatcher(matcher, at: node)

		// MARK: - Process Example generators

		// NOTE: There is a bug in Swift on macOS 10.x where type casting against a protocol does not work as expected.
		// Works fine running on macOS 11.x!
		// That is why each ExampleGenerator type is explicitly stated in its own case statement and is not DRY.
		case let exampleGenerator as ExampleGenerator.DateTime:
			processedElement = try processExampleGenerator(exampleGenerator, at: node)

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

		case let threwError as EncodingError:
			throw threwError

		default:
			if let encodingError = (elementToProcess as? Interaction)?.encodingErrors.first {
				throw encodingError
			}
			throw EncodingError.encodingFailure("A key or value in the structure does not conform to 'Encodable' protocol. The element attempted to encode: \(element)")
		}

		return processedElement
	}

	// MARK: - Processing

	// Processes a Matcher
	func processMatcher(_ matcher: MatchingRuleExpressible, at node: String) throws -> (node: AnyEncodable, rules: [String: AnyEncodable], generators: [String: AnyEncodable]) {
		let processedMatcherValue = try process(element: matcher.value, at: node, isEachLike: false)

		return (
			node: processedMatcherValue.node,
			rules: [node: AnyEncodable(["matchers": AnyEncodable(matcher.rules)])],
			generators: processedMatcherValue.generators
		)
	}

	// Processes an `EachLike` matcher
	func processEachLikeMatcher(_ matcher: Matcher.EachLike, at node: String) throws -> (node: AnyEncodable, rules: [String: AnyEncodable], generators: [String: AnyEncodable]) {
		var newNode: String
		let elementToProcess = mapPactObject(matcher.value)

		switch elementToProcess {
		case _ as [Any]:
			// Element is an `Array`
			newNode = node + "[*]"
		default:
			// Element is a `Dictionary`
			newNode = node + "[*].*"
		}

		var processedMatcherValue = try process(element: matcher.value, at: newNode, isEachLike: true)
		processedMatcherValue.rules[node] = AnyEncodable(["matchers": AnyEncodable(matcher.rules)])

		return (
			node: processedMatcherValue.node,
			rules: processedMatcherValue.rules,
			generators: processedMatcherValue.generators
		)
	}

	// Processes an Example Generator
	func processExampleGenerator(_ exampleGenerator: ExampleGeneratorExpressible, at node: String) throws -> (node: AnyEncodable, rules: [String: AnyEncodable], generators: [String: AnyEncodable]) {
		let processedGeneratorValue = try process(element: exampleGenerator.value, at: node, isEachLike: false)

		return (
			node: processedGeneratorValue.node,
			rules: processedGeneratorValue.rules,
			generators: [node: AnyEncodable(exampleGenerator.attributes)]
		)
	}

	// Processes the Matchers and Generators giving special consideration of processing `Request`.
	// When processing for `path`, the key is "" as it does not need to conform to JSONPath the same way as body does.
	func process(keyValues: [String: AnyEncodable]) -> AnyEncodable? {
		if interactionNode == .path, let pathRulesKey = keyValues.keys.first, pathRulesKey.isEmpty == true {
			return AnyEncodable(keyValues.values.first)
		} else {
			return keyValues.isEmpty ? nil : AnyEncodable(keyValues)
		}
	}

	// Processes an `Array` object and extracts any matchers or generators
	func process(_ array: [Any], at node: String, isEachLike: Bool) throws -> (node: [AnyEncodable], rules: [String: AnyEncodable], generators: [String: AnyEncodable]) {
		var encodableArray = [AnyEncodable]()
		var matchingRules: [String: AnyEncodable] = [:]
		var generators: [String: AnyEncodable] = [:]

		do {
			try array
				.enumerated()
				.forEach {
					let childElement = try process(element: $0.element, at: interactionNode == .body ? "\(node)\(isEachLike ? "" : "[\($0.offset)]")" : "\(node)", isEachLike: false)
					encodableArray.append(childElement.node)
					matchingRules = merge(matchingRules, with: childElement.rules)
					generators = merge(generators, with: childElement.generators)
				}
			return (node: encodableArray, rules: matchingRules, generators: generators)
		} catch {
			throw EncodingError.encodingFailure("Failed to process array: \(array)")
		}
	}

	// Processes a `Dictionary` object and extracts any matchers or generators
	func process(_ dictionary: [String: Any], at node: String) throws -> (node: [String: AnyEncodable], rules: [String: AnyEncodable], generators: [String: AnyEncodable]) {
		var encodableDictionary: [String: AnyEncodable] = [:]
		var matchingRules: [String: AnyEncodable] = [:]
		var generators: [String: AnyEncodable] = [:]

		try dictionary
			.enumerated()
			.forEach {
				let childElement = try process(element: $0.element.value, at: node.isEmpty ? "\($0.element.key)" : "\(node).\($0.element.key)", isEachLike: false)
				encodableDictionary[$0.element.key] = childElement.node
				matchingRules = merge(matchingRules, with: childElement.rules)
				generators = merge(generators, with: childElement.generators)
			}
		return (node: encodableDictionary, rules: matchingRules, generators: generators)
	}

	// MARK: - Type Mapping

	// Maps ObjC object to a Swift object
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

}
