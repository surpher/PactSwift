import Foundation
import PackagePlugin

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@main
struct DownloaderPlugin: CommandPlugin {

    private let localLibsDirName = "lib" // IMPORTANT: If you change this value, you must also change it in DownloaderPlugin.swift


    func performCommand(context: PluginContext, arguments: [String]) async throws {
        #if os(Linux)
            print(context.package.directory.appending(localLibsDirName))
        #else
            print("\(ColourCode.yellow.rawValue)NOTE:\(ColourCode.none.rawValue) This plugin is only available on devices running Linux operating system.")
        #endif
    }
}
