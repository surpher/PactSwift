//
//  Matcher.swift
//  PACTSwift
//
//  Created by Marko Justinek on 31/3/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//

public enum Matcher {

	case expression(Expression)
	case set(EachLike)
	case type(SomethingLike)

	// MARK: - Failable inits

	init?(_ set: EachLike) {
		self = .set(set)
	}

	init?(_ somethingLike: SomethingLike) {
		self = .type(somethingLike)
	}

	init?(_ expression: Expression) {
		self = .expression(expression)
	}

}

public extension Matcher {

	/// Rule for the PACT contract
	var rule: [String: Any] {
		var matcherRule = merge(jsonClass, with: value)
		if let data = data { matcherRule = merge(matcherRule, with: data) }

		return matcherRule
	}

}

// MARK: - Private

private extension Matcher {

	typealias RawValue = String

	enum PactJSONClass {

		case array
		case expression
		case type

		private var prefix: String {
			"Pact::"
		}

		var rawValue: RawValue {
			switch self {
			case .array: 				return prefix + "ArrayLike"
			case .expression: 	return prefix + "Term"
			case .type: 				return prefix + "SomethingLike"
			}
		}
	}

	// MARK: - Private properties

	var jsonClass: [String: String] {
		let jsonClass = "json_class"

		switch self {
		case .expression: 	return [jsonClass: PactJSONClass.expression.rawValue]
		case .set: 					return [jsonClass: PactJSONClass.array.rawValue]
		case .type: 				return [jsonClass: PactJSONClass.type.rawValue]
		}
	}

	var value: [String: Any] {
		switch self {
		case .expression(let matcher): 	return ["generate": matcher.generate]
		case .set(let matcher): 				return ["contents": matcher.value]
		case .type(let matcher): 				return ["contents": matcher.value]
		}
	}

	var data: [String: Any]? {
		switch self {
		case .expression(let matcher):
			return [
				"data": [
					"generate": matcher.generate,
					"matcher": [
						"json_class": "Regexp",
						"o": 0,
						"s": matcher.regex
					]
				]
			]
		case .set(let matcher):
			return [
				"min": matcher.min
			]
		case .type: return nil
		}
	}

}
