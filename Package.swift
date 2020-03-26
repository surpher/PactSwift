// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "PACTSwift",
  platforms: [
    .macOS(.v10_12), .iOS(.v12), .tvOS(.v12)
  ],
  products: [
    .library(name: "pact-swift", targets: ["PACTSwift"])
  ],
  dependencies: [ ],
  targets: [
    .target(
      name: "PACTSwift",
      dependencies: [],
      path: "./Sources"
    ),
    .testTarget(
            name: "PACTSwiftTests",
            dependencies: ["PACTSwift"],
            path: "./Tests"
        ),
  ]
)
