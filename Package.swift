// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HandTrackingClient",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "HandTrackingModels",
            targets: ["Models"]
        ),
        .library(
            name: "HandTrackingClient",
            targets: ["Client"]
        ),
    ],
    targets: [
        .target(name: "Models"),
        .target(
            name: "Client",
            dependencies: [.target(name: "Models")]
        ),
        .target(name: "Buildable"),
    ]
)
