// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LSKit",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "LSKit",
            targets: ["LSKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/divadretlaw/BinaryUtils.git", from: "1.1.0"),
        .package(url: "https://github.com/facebook/zstd", from: "1.5.6")
    ],
    targets: [
        .target(
            name: "LSKit",
            dependencies: [
                .product(name: "BinaryUtils", package: "BinaryUtils"),
                .product(name: "libzstd", package: "zstd")
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
