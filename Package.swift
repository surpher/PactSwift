// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "PactSwift",

  platforms: [
    .macOS(.v13),
    .iOS(.v16),
    .tvOS(.v16),
  ],

  products: [
    .library(
      name: "PactSwift",
      targets: [
        "PactSwift"
      ]
    )
  ],

  dependencies: [
    .package(url: "https://github.com/surpher/PactSwiftMockServerXCFramework.git", .upToNextMinor(from: "1.0.1"))
  ],

  targets: [

    // PactSwift - Apple platforms
    .target(
      name: "PactSwift",
      dependencies: [
        .product(
            name: "PactSwiftMockServer",
            package: "PactSwiftMockServerXCFramework",
            condition: .when(platforms: [.iOS, .macOS, .tvOS])
        )
      ],
      path: "./Sources"
    ),

    // Tests
    .testTarget(
      name: "PactSwiftTests",
      dependencies: [
        "PactSwift"
      ],
      path: "./Tests"
    ),

  ]
)
