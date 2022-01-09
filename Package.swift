// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlowKit",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "FlowKit",
            targets: ["FlowKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FlowKit",
            resources: [
                .copy("Preview/potValue.json"),
                .copy("Preview/getProjectedPerformance.json")
            ]),
        .testTarget(
            name: "FlowKitTests",
            dependencies: ["FlowKit"]),
    ]
)
