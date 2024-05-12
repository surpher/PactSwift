// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "PactSwift",

    platforms: [
        .macOS(.v10_12),
        .iOS(.v12),
        .tvOS(.v12)
    ],

    products: [
        .library(
            name: "PactSwift",
            targets: ["PactSwift"]
        ),

        .plugin(
            name: "DownloaderPlugin",
            targets: [
                "DownloaderPlugin"
            ]
        ),

        .plugin(
            name: "LibsLocationPlugin",
            targets: [
                "LibsLocationPlugin"
            ]
        )
    ],

    dependencies: [
        .package(url: "https://github.com/surpher/PactSwiftMockServer.git", exact: "0.4.3"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.1"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
    ],

    targets: [

        // PactSwift
        .target(
            name: "PactSwift",
            dependencies: [
                .product(name: "PactSwiftMockServer", package: "PactSwiftMockServer", condition: .when(platforms: [.iOS, .macOS, .tvOS])),
                .product(name: "PactSwiftMockServerLinux", package: "PactSwiftMockServer", condition: .when(platforms: [.linux]))
            ],
            path: "./Sources"
        ),

        // Needed for DownloaderPlugin - command plugins can depend only on executable targets
        .executableTarget(
            name: "CryptoWrapper",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Crypto"
        ),

        // Tests
        .testTarget(
            name: "PactSwiftTests",
            dependencies: [
                "PactSwift"
            ],
            path: "./Tests"
        ),

        // Plugin(s)
        .plugin(
            name: "DownloaderPlugin",
            capability: .command(
                intent: .custom(
                    verb: "download-ffi",
                    description: "Downloads 'libpact_ffi.so' binary from 'github.com/pact-foundation/pact-reference/releases'."
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "Fetch remote `libpact_ffi.so` binary and save it to the package's sub-directory.")
                ]
            ),
            dependencies: [
                "CryptoWrapper"
            ]
        ),

        .plugin(
            name: "LibsLocationPlugin",
            capability: .command(
                intent: .custom(
                    verb: "libs-dir",
                    description: "Prints absolute path to directory containing 'libpact_ffi.so' binaries downloaded using 'download-ffi' plugin."
                ),
                permissions: []
            )
        )
    ],

    swiftLanguageVersions: [.v5]
)
