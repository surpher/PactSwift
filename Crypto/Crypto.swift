import ArgumentParser
import Foundation

#if os(Linux)
import Crypto
#else
import CryptoKit
#endif

@main
struct Crypto: ParsableCommand {

    @Argument(help: "Path to file")
    var filePath: String

    func run() throws {
        // Convert file path to URL
        let fileURL = URL(fileURLWithPath: filePath)

        // Read file into Data
        let fileData = try Data(contentsOf: fileURL)
        let sha256hash = SHA256.hash(data: fileData).compactMap { String(format: "%02x", $0) }.joined()
        print(sha256hash)
    }
}
