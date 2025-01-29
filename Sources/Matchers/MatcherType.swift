//
//  Created by Marko Justinek on 28/1/2025.
//  Copyright © 2023 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation

enum MatcherType: String, Codable {
    case type
    case regex

    case boolean
    case decimal
    case date
    case equality
    case include
    case integer
    case null
    case number
    case string
    case time
    case timestamp

    // MARK: - v4

    case statusCode
    case notEmpty
    case semVer = "semver"
}
