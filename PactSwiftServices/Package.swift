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
		.package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", .upToNextMajor(from: "2.0.0")),
	],
	targets: [
		.target(
			name: "PactSwiftServices",
			dependencies: {
                #if os(macOS)
                return [
					"PactMockServer",
                    "CwlPreconditionTesting",
                ]
                #else
                return ["PactMockServer"]
                #endif
            }(),
			path: "./Sources"
		),
		.testTarget(
			name: "PactSwiftServicesTests",
			dependencies: ["PactSwiftServices"],
			path: "./Tests"
		),
	],
	swiftLanguageVersions: [.v5]
)