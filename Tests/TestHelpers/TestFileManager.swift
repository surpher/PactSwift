// Copyright © 2024 Marko Justinek. All rights reserved.

import Foundation
import PactSwift

enum TestFileManager {

    @discardableResult
    static func fileExists(at path: String) -> Bool {
        FileManager.default.fileExists(atPath: path) ? true : false
    }

    @discardableResult
    static func removeFile(at path: String) -> Bool {
        if fileExists(at: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
                return true
            } catch {
                debugPrint("warning: Failed to remove file at '\(path)'!") // Should really use Logger for this!
                return false
            }
        }
        debugPrint("File '\(path)' does not exist!")
        return false
    }

    @discardableResult
    static func createDirectory(at path: String) -> Bool {
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
            return true
        } catch {
            debugPrint("warning: Failed to create directory at '\(path)'!") 
            return false
        }
    }
}
