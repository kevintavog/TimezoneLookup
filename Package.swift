// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TimezoneLookup",
    products: [
        .executable(name: "TimezoneLookup", targets: ["TimezoneLookup"]),
        .library(name: "TimezoneLookupCore", targets: ["TimezoneLookupCore"]),
    ],
    dependencies: [
		.package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-CURL.git", from: "3.0.0"),
// Until SwiftyJSON master is Linux compatible, use the branch waiting to be merged
// .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .branch("swift-test-macos")),
		.package(url: "https://github.com/FabrizioBrancati/Queuer.git", from: "1.3.1")
    ],
    targets: [
        .target(
            name: "TimezoneLookup",
            dependencies: ["TimezoneLookupCore"]),
        .target(
            name: "TimezoneLookupCore",
            dependencies: ["PerfectHTTPServer", "PerfectCURL", "SwiftyJSON", "Queuer"]),
    ]
)
