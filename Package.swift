// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LANExplorer",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "LANExplorer", targets: ["LANExplorer"])
    ],
    targets: [
        .executableTarget(
            name: "LANExplorer",
            resources: [
                .process("../../Resources")
            ]
        )
    ]
)
