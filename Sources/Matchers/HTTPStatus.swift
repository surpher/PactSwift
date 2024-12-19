//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation

public enum HTTPStatus {
    case information
    case success
    case redirect
    case clientError
    case serverError
    case nonError
    case error
    case statusCodes([Int])
}
