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
		.package(name: "PactSwiftMockServer", url: "https://github.com/surpher/PactSwiftMockServer.git", .branch("main")),
		.package(name: "PactSwiftToolbox", url: "https://github.com/surpher/PactSwiftToolbox.git", from: "0.1.0")
	],

	targets: [
		.target(
				name: "PactSwift",
				dependencies: [
					"PactSwiftMockServer",
					"PactSwiftToolbox"
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
