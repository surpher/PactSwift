import Foundation
import PackagePlugin

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@main
struct DownloaderPlugin: CommandPlugin {

    private let launchPath = "/usr/bin/env"
    private let libName = "libpact_ffi"
    private let libExt = "so"
    private let libReleaseBaseURLString = "https://github.com/pact-foundation/pact-reference/releases/download"
    private let libVersion = "v0.4.20"
    private let localLibsDirName = "lib" // IMPORTANT: If you change this value, you must also change it in LibsLocationPlugin.swift

    fileprivate enum ColourCode: String {
        case yellow = "\u{001B}[0;33m"
        case `none` = "\u{001B}[0m"
    }

    func performCommand(context: PluginContext, arguments: [String]) async throws {
      #if os(Linux)
        let os = try shell(launchPath: launchPath, arguments: ["uname"]).lowercased()
        let arch = try shell(launchPath: launchPath, arguments: ["uname", "-p"]).lowercased()
        let archive_filename = "\(libName)-\(os)-\(arch).\(libExt).gz"

        let fileURL = URL(string: "\(libReleaseBaseURLString)/\(libName)-\(libVersion)/\(archive_filename)")!
        let shaFileURL = URL(string: "\(libReleaseBaseURLString)/\(libName)-\(libVersion)/\(archive_filename).sha256")!

        print("info: Fetching \(libName) binary archive file from '\(fileURL.absoluteString)'")

        let libsFolder = context.package.directory.appending(localLibsDirName)
        let folderURL = URL(fileURLWithPath: libsFolder.string)
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)

        let destinationURL = URL(fileURLWithPath: libsFolder.appending(archive_filename).string)

        guard let libData = try await downloadResource(from: fileURL) else {
            throw NSError(domain: "\(#function)", code: -1, userInfo: [ NSLocalizedDescriptionKey: "No data available fetching '\(fileURL.absoluteString)'!"])
        }
        try saveData(libData, to: destinationURL)

        let remoteSHA = try await getRemoteSHA(resource: shaFileURL)
        let localSHA = try getLocalSHA(resource: destinationURL, in: context.package.directory)

        guard remoteSHA == localSHA else {
            try FileManager.default.removeItem(at: destinationURL)
            throw NSError(domain: "\(#file)", code: -9, userInfo: [ NSLocalizedDescriptionKey: "SHA checksum do not match!"])
        }

        let result = try unarchiveGzipArchiveAndRename(resource: destinationURL, to: "\(libName).\(libExt)")
        print(result)

        print("\(ColourCode.yellow.rawValue)IMPORTANT:\(ColourCode.none.rawValue) When running `swift test` use flags `-Xlinker` and `-L/path/to/libs/folder`. eg: `swift test -Xlinker -L/usr/bin/libs`")
        print("\(ColourCode.yellow.rawValue)IMPORTANT:\(ColourCode.none.rawValue) Run the following command to add the path to your 'libpact_ffi.so' binary to environment variable:")

        // Intentionally printed last on own lines hopefully allowing for automation.
        print("export LD_LIBRARY_PATH=\"\(libsFolder.string):$LD_LIBRARY_PATH\"")

      #else
        print("\(ColourCode.yellow.rawValue)NOTE:\(ColourCode.none.rawValue) This plugin is only available on devices running Linux operating system.")
      #endif
    }
}

// MARK: - Private DownloaderPlugin extension

private extension DownloaderPlugin {

    @discardableResult
    func unarchiveGzipArchiveAndRename(resource: URL, to newName: String) throws -> String {
        var destinationPath = resource.path
        print("info: Decompressing '\(destinationPath)'...")
        try shell(launchPath: launchPath, arguments: ["gzip", "-dvf", "\(destinationPath)"])

        // Remove .gz from destinationPath variable since it no longer exists after 'gzip -d'!
        destinationPath = destinationPath.deleteSuffix(".gz")

        // Rename resource
        let renameResult = try shell(
            launchPath: launchPath,
            arguments: [ "mv", "-v", "\(destinationPath)", destinationPath.replacingOccurrences(of: destinationPath.lastPathComponent, with: newName) ]
        )

        return renameResult
    }

    func getRemoteSHA(resource: URL) async throws -> String {
        guard
            let remoteSHAData = try await downloadResource(from: resource),
            let remoteSHA = String(data: remoteSHAData, encoding: .utf8)?.split(separator: " ").first
        else {
            throw NSError(domain: "\(#file)", code: -99, userInfo: [ NSLocalizedDescriptionKey: "Failed to get SHA from \(resource.absoluteString)"])
        }
        return String(remoteSHA)
    }

    func getLocalSHA(resource: URL, in directory: Path) throws -> String {
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        let executableURL = directory.appending(subpath: ".build/debug/CryptoWrapper")
        let process = Process()

        process.arguments = [resource.path]
        process.executableURL = URL(fileURLWithPath: executableURL.string)
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()

        let output = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)!
        let errorOutput = String(data: errorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)!

        process.waitUntilExit()

        if process.terminationStatus == 0 {
            return output.trimmingCharacters(in: .newlines)
        } else {
            throw NSError(domain: "\(#file)", code: -77, userInfo: [ NSLocalizedDescriptionKey: "Failed to get SHA for \(resource.absoluteString)! \(errorOutput)" ])
        }
    }

    func downloadResource(from url: URL) async throws -> Data? {
        let (data, response) = try await URLSession.shared.asyncData(from: url)
        guard
            let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            throw NSError(domain: "\(#file)", code: -66, userInfo: [ NSLocalizedDescriptionKey: "Failed to download file" ])
        }

        return data
    }

    func saveData(_ data: Data, to destination: URL) throws {
        try data.write(to: destination)
    }

    @discardableResult
    func shell(launchPath: String, arguments: [String]) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: launchPath)
        process.arguments = arguments

        let pipe = Pipe()
        process.standardOutput = pipe
        try process.run()

        let output_from_command = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)!

        // remove the trailing new-line char
        if output_from_command.count > 0 {
            let lastIndex = output_from_command.index(before: output_from_command.endIndex)
            return String(output_from_command[output_from_command.startIndex..<lastIndex])
        }
        return output_from_command
    }
}

// MARK: - Private String extension

private extension String {
    /// Removes suffix if string contains the given substring
    func deleteSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else {
            return self
        }
        return String(self.dropLast(suffix.count))
    }
}

// MARK: - Private URLSession

private extension URLSession {

  /// Defines the possible errors
  enum URLSessionAsyncErrors: Error {
      case invalidUrlResponse(String?)
      case missingResponseData
  }

  func asyncData(from url: URL) async throws -> (Data?, URLResponse?) {
    return try await withCheckedThrowingContinuation { continuation in
      let task = self.dataTask(with: url) { data, response, error in
        if let error = error {
          continuation.resume(throwing: NSError(domain: "\(#file)", code: -1000, userInfo: [ NSLocalizedDescriptionKey: error.localizedDescription ]))
          return
        }

        guard
          let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode)
        else {
          continuation.resume(throwing: URLSessionAsyncErrors.invalidUrlResponse("\((response as? HTTPURLResponse)?.statusCode ?? 0)"))
          return
        }

        guard let data = data else {
          continuation.resume(throwing: URLSessionAsyncErrors.missingResponseData)
          return
        }

        continuation.resume(returning: (data, response))
      }
      task.resume()
    }
  }
}
