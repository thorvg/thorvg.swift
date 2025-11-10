// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ThorVGSwift",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "ThorVGSwift",
            targets: ["ThorVGSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", .upToNextMinor(from: "1.15.0")),
    ],
    targets: [
        .target(
            name: "ThorVGSwift",
            dependencies: ["ThorVG"],
            path: "swift",
            resources: [.process("Resources")]
        ),
        .binaryTarget(
            name: "ThorVG",
            path: "ThorVG.xcframework"
        ),
        .testTarget(
            name: "ThorVGSwift-tests",
            dependencies: [
                "ThorVGSwift",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            path: "swift-tests",
            exclude: ["SnapshotTests/__Snapshots__"],
            resources: [.process("Resources")]
        ),
    ],
    cxxLanguageStandard: .cxx14
)
