// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HandTrackingClient",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "HandTrackingModels",
            targets: ["HandTrackingModels"]
        ),
        .library(
            name: "HandTrackingClient",
            targets: ["HandTrackingClient"]
        ),
    ],
    targets: [
        .target(
            name: "HandTrackingModels",
            path: "Sources/Models"
        ),
        .target(
            name: "HandTrackingClient",
            dependencies: [.target(name: "HandTrackingModels")],
            path: "Sources/Client"
        ),
        .target(name: "Buildable"),
    ]
)
