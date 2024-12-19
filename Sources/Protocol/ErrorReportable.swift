//
//  Created by Marko Justinek on 20/4/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation

public typealias FileString = StaticString

public protocol ErrorReportable {

    func reportFailure(_ message: String)
    func reportFailure(_ message: String, file: FileString, line: UInt)

}
