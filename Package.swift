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
		.package(name: "PactMockServer", url: "https://github.com/surpher/PactMockServer.git", from: "0.0.1-beta"),
		.package(name: "PactSwiftMockServer", url: "https://github.com/surpher/PactSwiftMockServer.git", from: "0.4.0"),
		.package(name: "PactSwiftToolbox", url: "https://github.com/surpher/PactSwiftToolbox.git", from: "0.1.0")
	],

	targets: [
		.binaryTarget(
			name: "PactSwift",
			path: "PactSwift.xcframework"
		)
	],

	swiftLanguageVersions: [.v5]

)
