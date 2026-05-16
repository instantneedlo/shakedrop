// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ShakeDrop",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "ShakeDrop",
            path: "Sources/ShakeDrop"
        ),
        .testTarget(
            name: "ShakeDropTests",
            dependencies: ["ShakeDrop"],
            path: "Tests/ShakeDropTests"
        )
    ]
)
