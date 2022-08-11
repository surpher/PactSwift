// swift-tools-version:5.3

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
		)
	],

	dependencies: [
		.package(url: "https://github.com/surpher/PactSwiftMockServer.git", .exact("0.4.1"))
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
