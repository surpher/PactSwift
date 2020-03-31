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

	/// The rule for the PACT contract
	var rule: [String: Any] {
		var matcherRule = merge(jsonClass, with: value)
		if let data = data { matcherRule = merge(matcherRule, with: data) }

		return matcherRule
	}

}

// MARK: - Private

private extension Matcher {

	var jsonClass: [String: String] {
		let jsonClass = "json_class"
		let pactPrefix = "Pact::"

		switch self {
		case .expression: 	return [jsonClass: pactPrefix + "Term"]
		case .set: 					return [jsonClass: pactPrefix + "ArrayLike"]
		case .type: 				return [jsonClass: pactPrefix + "SomethingLike"]
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
