// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "PactSwift",

	platforms: [
		.macOS(.v10_13),
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
		.package(url: "https://github.com/surpher/PactSwiftServer.git", .exact("0.4.7"))
	],

	targets: [

		// PactSwift
		.target(
			name: "PactSwift",
			dependencies: [
				.product(name: "PactSwiftMockServer", package: "PactSwiftServer"),
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
