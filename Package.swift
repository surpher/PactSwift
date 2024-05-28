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
      targets: ["PactSwift"]
    )
  ],
  
  dependencies: [
    .package(url: "https://github.com/ittybittyapps/PactSwiftMockServer.git", branch: "main"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", exact: "1.16.0"),
  ],
  
  targets: [
    
    // PactSwift
    .target(
      name: "PactSwift",
      dependencies: [
        .product(name: "PactSwiftMockServer", package: "PactSwiftMockServer", condition: .when(platforms: [.iOS, .macOS, .tvOS])),
      ],
      path: "./Sources"
    ),
    
    // Tests
    .testTarget(
      name: "PactSwiftTests",
      dependencies: [
        "PactSwift",
        .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
      ],
      path: "./Tests"
    ),
    
  ],
  
  swiftLanguageVersions: [.v5]
  
)
