// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "MemoryPoolDemo",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "MemoryPool",
            targets: ["MemoryPool"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0-swift-5.9-DEVELOPMENT-SNAPSHOT-2023-04-25-b"),
//        .package(url: "https://github.com/apple/swift-syntax.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "MemoryPool",
            dependencies: [
                "MemoryPoolMacros"
            ]
        ),
        .testTarget(
            name: "MemoryPoolTests",
            dependencies: [
                "MemoryPool",
                "MemoryPoolMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
        .executableTarget(
            name: "Demo",
            dependencies: [
                "MemoryPool"
            ]
        ),
        .macro(
            name: "MemoryPoolMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        )
    ]
)
