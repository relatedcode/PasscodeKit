// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "PasscodeKit",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "PasscodeKit",
            type: .static,
            targets: ["PasscodeKit"]),
    ],
    targets: [
        .target(
            name: "PasscodeKit",
            dependencies: [],
            path: "./PasscodeKit",
            sources: ["Sources"]
        ),
    ]
)
