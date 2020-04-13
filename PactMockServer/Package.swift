// swift-tools-version:5.0

import PackageDescription

let package = Package(
	name: "PactMockServer",
	products: [
		.library(
			name: "PactMockServer",
			targets: ["PactMockServer"]
		),
	],
	dependencies: [],
	targets: [
		.target(
			name: "PactMockServer",
			dependencies: [],
			path: "./Sources"
		),
	]
)
