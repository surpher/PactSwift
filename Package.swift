// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "PactSwift",

	platforms: [
		.macOS(.v13),
		.iOS(.v16),
		.tvOS(.v16)
	],

	products: [
		.library(
			name: "PactSwift",
			targets: ["PactSwift"]
		)
	],

	dependencies: [
        .package(url: "https://github.com/ittybittyapps/PactSwiftMockServer.git", branch: "main")
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

		// Tests
		.testTarget(
			name: "PactSwiftTests",
			dependencies: [
				"PactSwift"
			],
			path: "./Tests"
		),

	],

	swiftLanguageVersions: [.v5]

)
