// swift-tools-version:5.0

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
		.package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
		.package(url: "https://github.com/surpher/PactMockServer.git", from: "0.0.1-beta")
	],
	targets: [
		.target(
			name: "PactSwift",
			dependencies: [
				"Nimble",
				"PactMockServer"
			],
			path: "./Sources"
		),
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
