// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "NetworkExplorer",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "NetworkExplorer", targets: ["NetworkExplorer"])
    ],
    targets: [
        .executableTarget(
            name: "NetworkExplorer",
            resources: [
                .process("../../Resources")
            ]
        ),
        .testTarget(name: "NetworkExplorerTests", dependencies: ["NetworkExplorer"])
    ]
)
