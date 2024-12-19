//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation

enum GeneratorType: String, Encodable {

    case randomInt = "RandomInt"
    case uuid = "Uuid"
    case randomDecimal = "RandomDecimal"
    case randomHex = "RandomHexadecimal"
    case randomString = "RandomString"
    case regex = "Regex"
    case date = "Date"
    case time = "Time"
    case dateTime = "DateTime"
    case randomBoolean = "RandomBoolean"
    case providerState = "ProviderState"
    case mockServerUrl = "MockServerURL"
}
