// swift-tools-version:5.7

import PackageDescription

let package = Package(
	name: "PactSwift",
	
	platforms: [
		.macOS(.v13),
		.iOS(.v16),
	],
	
	products: [
		.library(
			name: "PactSwift",
			targets: ["PactSwift"]
		)
	],
	
	dependencies: [
		.package(url: "https://github.com/surpher/PactSwiftMockServerXCFramework", exact: "1.2.0"),
		.package(url: "https://github.com/pointfreeco/swift-snapshot-testing", exact: "1.16.0"),
	],

	targets: [

		// PactSwift
		.target(
			name: "PactSwift",
			dependencies: [
				.product(name: "PactSwiftMockServer", package: "PactSwiftMockServerXCFramework", condition: .when(platforms: [.iOS, .macOS])),
			],
			path: "./Sources"
		),
		
		// Tests
		.testTarget(
			name: "PactSwiftTests",
			dependencies: [
				"PactSwift",
				.product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
			],
			path: "./Tests"
		),
		
	],
	
	swiftLanguageVersions: [.v5]
	
)
