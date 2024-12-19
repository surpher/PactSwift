//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation

/// A generic ``Matcher`` for serialising simple matchers to JSON.
struct GenericMatcher<ValueType: Encodable>: Matcher {

    var type: String
    var value: ValueType
    var generator: GeneratorType?
    var min: Int?
    var max: Int?
    var size: Int?
    var digits: Int?
    var format: String?
    var expression: String?
    var regex: String?
    var example: String?

    enum CodingKeys: String, CodingKey {
        case type = "pact:matcher:type"
        case generator = "pact:generator:type"
        case value
        case min
        case max
        case size
        case digits
        case format
        case expression
        case regex
        case example
    }
}
