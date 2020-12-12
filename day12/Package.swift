// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "day12",
    platforms: [
      .macOS(.v10_11),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/kjn-void/AocUtils.git", from: "1.2.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "day12",
            dependencies: ["AocUtils"]),
        .testTarget(
            name: "day12Tests",
            dependencies: ["day12"]),
    ]
)
