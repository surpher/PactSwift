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
		.package(url: "https://github.com/surpher/PactSwiftMockServer.git", .upToNextMinor(from: "0.3.0")),
		.package(name: "PactSwiftToolbox", url: "https://github.com/surpher/PactSwiftToolbox.git", .upToNextMinor(from: "0.2.0")),
	],

	targets: [

		// PactSwift
		.target(
			name: "PactSwift",
			dependencies: [
				.product(name: "PactSwiftMockServer", package: "PactSwiftMockServer", condition: .when(platforms: [.iOS, .macOS, .tvOS])),
				.product(name: "PactSwiftMockServerLinux", package: "PactSwiftMockServer", condition: .when(platforms: [.linux])),
				"PactSwiftToolbox"
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
