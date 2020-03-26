//
//  Created by Marko Justinek on 10/9/20.
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

public struct Matcher {
	// This is a namespace placeholder.
	// Implement any matchers as `Struct`s in a Matcher extension.

	// ⚠️ IMPORTANT ⚠️
	// Make sure PactBuilder.swift handles the the matcher
	// There is a bug in Swift where protocols are not handled properly when
	// used as generics.

	// Matchers are Encodable objects that conform to the defined structure.
	// When DSL is being processed the Matcher object is created and added to Pact.
	// Every Matcher conforms to MatchingRuleExpressible protocol which defines that
	// at least `value` and `rules` keys are defined. Generally a Matcher would
	// set its type as the `match` value in the rules key. That then matches the agreed matcher
	// configuration and attributes defined in Pact Specification version 3 (see link below).
	//
	// We use `AnyEncodable` type eraser because we can not predict what type the user will provide.
	//
	// As an example, the `RegexLike` matcher would use the `value` user provides, sets
	// the `match` value as `regex`, following the specification, and `regex` key's value
	// is set as the regex `pattern` the user provides.
	//
	// Imagine the following properties of a `RegexMatcher` example:
	//
	//    let value: Any
	//    let pattern: String = #"\d{8}"#
	//    let rules: [[String: AnyEncodable]] = ["match": AnyEncodable("regex"), "regex": AnyEncodable(pattern)]
	//
	// would generate a matchers object for the jsonPath where the matcher was used:
	//
	//    "matchers": [
	//      {
	//        "match": "regex",
	//        "regex": "\\d{8}"
	//      }
	//    ]
	//
	// This JSON object is applied to the specific jsonPath whilst the DSL structure is being processed.
	//
	// Example:
	//
	//    // DSL
	//    .willRespondWith(
	//      body = [
	//        "eightDigits": Matcher.RegexLike(value: "12345678", pattern: #"\d{8}"#)
	//      ]
	//    )
	//
	//    // Extract from Pact contract (JSON file)
	//    "response": {
	//      "body": {
	//        "eightDigits": "12345678"
	//      }
	//    }
	//    ...
	//    "matchingRules": {
	//      "body": {
	//        "$.eightDigits": {
	//          "matchers": [
	//            {
	//              "match": "regex",
	//              "regex": "\\d{8}"
	//            }
	//          ]
	//        }
	//      } 
	//    }
	//
	// See: https://github.com/pact-foundation/pact-specification/tree/version-3#matchers
	//

}

// MARK: - Objective-C

/// Acts as a bridge defining the Swift specific Matcher type
protocol ObjcMatcher {

	var type: MatchingRuleExpressible { get }

}
