// swift-tools-version:5.0

import PackageDescription

 let package = Package(
    name: "PactSwiftServices",
    platforms: [
        .macOS(.v10_12), .iOS(.v12), .tvOS(.v12)
    ],
    products: [
        .library(name: "PactSwiftServices", targets: ["PactSwiftServices"])
    ],
    dependencies: [ ],
    targets: [
        .target(
            name: "PactSwiftServices",
            dependencies: [],
            path: "./Sources"
        ),
        .testTarget(
            name: "PactSwiftServicesTests",
            dependencies: ["PactSwiftServices"],
            path: "./Tests"
        ),
    ]
)