// swift-tools-version:5.0

import PackageDescription

 let package = Package(
	name: "PactSwiftServices",
	platforms: [
		.macOS(.v10_12),
		.iOS(.v12),
		.tvOS(.v12)
	],
	products: [
		.library(
			name: "PactSwiftServices",
			targets: ["PactSwiftServices"]
		)
	],
	dependencies: [
		.package(path: "../PactMockServer"),
		.package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
	],
	targets: [
		.target(
			name: "PactSwiftServices",
			dependencies: [
				"PactMockServer",
				"Nimble"
			],
			path: "./Sources"
		),
		.testTarget(
			name: "PactSwiftServicesTests",
			dependencies: ["PactSwiftServices",],
			path: "./Tests"
		),
	],
	swiftLanguageVersions: [.v5]
)