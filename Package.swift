// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Wishlist",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "Wishlist",
            path: "Sources/Wishlist",
            resources: [
                .process("Info.plist")
            ],
            swiftSettings: [
                .unsafeFlags(["-strict-concurrency=minimal"])
            ]
        )
    ]
)
