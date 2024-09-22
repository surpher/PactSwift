//
//  Created by Marko Justinek on 11/9/20.
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

public struct ExampleGenerator {
	// This is a namespace placeholder
	// Implement any Example Generators as `Struct`s in an extension.

	// ⚠️ IMPORTANT ⚠️
	// Make sure PactBuilder.swift handles the example generator
	// There is a bug in Swift where protocols are not handled properly when
	// used as generics.

	// Example Generators are Encodable objects that conform to the defined structure.
	// When DSL is being processed the Example Generator object is created and added to Pact.
	// Every Example Generator conforms to ExampleGeneratorExpressible protocol which
	// defines that at least `type` key is provided. Generally an Example Generator would
	// set its type from the `generator` property. That then matches the agreed generator name
	// and attributes defined in Pact Specification version 3 (see link below). The example values
	// generated in PactSwift are re-generated with each test run and are re-generated at
	// mock server point (when running `PactSwiftMockServer.verify()`).
	//
	// We use `AnyEncodable` type eraser because we can not predict what type the user will provide.
	//
	// As an example, the `RandomInt` example generator would use `ExampleGenerator.Generator`
	// and dictionary `rules` defines the attributes to of the generated example value.
	//
	// Imagine the following properties of an Example Generator:
	//
	//    let value: Any
	//    let generator: Example.Generator = .int
	//    let rules: [String: AnyEncodable] = ["min": AnyEncodable(3), "max": AnyEncodable(9)]
	//
	// would generate an object for the jsonPath where the example generator was used:
	//
	//    {
	//      "type": "RandomInt",
	//      "min": 3,
	//      "max": 9
	//    }
	//
	// This JSON object is applied to the specific jsonPath whilst the DSL structure is being processed.
	//
	// Example:
	//
	//    // DSL
	//    let body = [
	//      "randomInt": ExampleGenerator.RandomInt(min: 3, max: 9)
	//    ]
	//
	//    // Extract from Pact contract (JSON file)
	//    "generators": {
	//      "body": {
	//        "$.randomInt": {
	//          "type": "RandomInt",
	//          "min": 3,
	//          "max": 9
	//        }
	//      }
	//    }
	//
	// See: https://github.com/pact-foundation/pact-specification/tree/version-3#introduce-example-generators
	//

}

extension ExampleGenerator {

	// A list of implemented Example Generators that map to a generator in Pact Specification
	// See: https://github.com/pact-foundation/pact-specification/tree/version-3#introduce-example-generators
	enum Generator: String {
		case bool = "RandomBoolean"
		case date = "Date"
		case dateTime = "DateTime"
		case decimal = "RandomDecimal"
		case hexadecimal = "RandomHexadecimal"
		case int = "RandomInt"
		case providerState = "ProviderState"
		case regex = "Regex"
		case string = "RandomString"
		case time = "Time"
		case uuid = "Uuid"
	}

}

// MARK: - Objective-C

/// Acts as a bridge defining the Swift specific Generator type
protocol ObjcGenerator {

	var type: ExampleGeneratorExpressible { get }

}
