//
//  Created by Marko Justinek on 9/8/2022.
//  Copyright © 2022 Marko Justinek. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import Foundation

extension String {

    /// Pretty prints a JSON string by parsing and reformatting it with proper indentation
    /// - Returns: A formatted JSON string or the original string if formatting fails
    ///
    /// Usage example:
    ///
    /// ```swift
    /// let jsonString = "{\"name\":\"John\",\"age\":30}"
    /// let prettyJSON = jsonString.prettyPrintedJSON()
    /// ```
    /// This will print:
    ///
    /// ```json
    /// {
    ///     "name": "John",
    ///     "age": 30
    /// }
    /// ```
    @discardableResult
    func prettyPrintedJSON() -> String {
        guard
            let data = self.data(using: .utf8),
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
            let prettyString = String(data: prettyData, encoding: .utf8)
        else {
            return self
        }
        return prettyString
    }
}
