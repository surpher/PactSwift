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
		.package(path: "PactSwiftServices")
	],
	targets: [
		.target(
			name: "PactSwift",
			dependencies: [ "PactSwiftServices" ],
			path: "./Sources"
		),
		.testTarget(
			name: "PactSwiftTests",
			dependencies: ["PactSwift"],
			path: "./Tests"
		),
	]
)