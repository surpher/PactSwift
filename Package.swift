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
		.package(url: "https://github.com/surpher/PactMockServer.git", from: "0.0.1-beta"),
		.package(url: "https://github.com/surpher/PactSwiftMockServer-Dist.git", from: "0.2.0"),
		.package(url: "https://github.com/surpher/PactSwiftToolbox.git", from: "0.1.0")
	],
	targets: [
		.target(
			name: "PactSwift",
			dependencies: [
				"PactMockServer",
				"PactSwiftMockServer",
				"PactSwiftToolbox"
			],
			path: "./Sources"
		),
		.testTarget(
			name: "PactSwiftTests",
			dependencies: [
				"PactSwift",
				"PactSwiftMockServer",
				"PactSwiftToolbox"
			],
			path: "./Tests"
		),
	],
	swiftLanguageVersions: [.v5]
)
