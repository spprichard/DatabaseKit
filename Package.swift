// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DatabaseKit",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "DatabaseKit",
            targets: [
                "DatabaseKit"
            ]
        ),
    ],
    targets: [
        .target(
            name: "DatabaseKit",
            swiftSettings: [
                .swiftLanguageMode(.v6),
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .executableTarget(
            name: "Demo",
            dependencies: [
                "DatabaseKit"
            ]
        ),
        .testTarget(
            name: "DatabaseKitTests",
            dependencies: [
                "DatabaseKit",
            ]
        ),
    ]
)
