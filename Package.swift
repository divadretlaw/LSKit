// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LSKit",
    platforms: [
        .macOS(.v12),
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "LSKit",
            targets: ["LSKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/divadretlaw/BinaryUtils.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "LSKit",
            dependencies: [
                .product(name: "BinaryUtils", package: "BinaryUtils")
            ]
        ),
        .testTarget(
            name: "LSKitTests",
            dependencies: ["LSKit"],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
