// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HandTrackingClient",
    products: [
        .library(
            name: "HandTrackingModels",
            targets: ["HandTrackingModels"]
        ),
        .library(
            name: "HandTrackingClient",
            targets: ["HandTrackingClient"]
        ),
        .library(
            name: "HandTrackingNetworking",
            targets: ["HandTrackingNetworking"]
        ),
    ],
    targets: [
        .target(
            name: "HandTrackingNetworking",
            path: "./Sources/Networking"
        ),
        .target(
            name: "HandTrackingModels",
            path: "./Sources/Models"
        ),
        .target(
            name: "HandTrackingClient",
            dependencies: [
                .target(name: "HandTrackingModels"),
                .target(name: "HandTrackingNetworking")
            ],
            path: "./Sources/Client"
        ),
        .target(name: "Buildable"),
    ]
)
