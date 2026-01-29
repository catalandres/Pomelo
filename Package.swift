// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pomelo",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Command-line tool
        .executable(
            name: "pomelo",
            targets: ["PomeloApp"]),
        // Library for Salesforce operations
        .library(
            name: "PomeloKit",
            targets: ["PomeloKit"]),
    ],
    dependencies: [
        // SwiftNIO for async networking
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.62.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.25.0"),
        // ArgumentParser for CLI
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
    ],
    targets: [
        // CLI executable target
        .executableTarget(
            name: "PomeloApp",
            dependencies: [
                "PomeloKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "Sources/PomeloApp"),
        
        // Core library target
        .target(
            name: "PomeloKit",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
            ],
            path: "Sources/PomeloKit"),
        
        // Tests
        .testTarget(
            name: "PomeloKitTests",
            dependencies: ["PomeloKit"],
            path: "Tests/PomeloKitTests"),
    ]
)
