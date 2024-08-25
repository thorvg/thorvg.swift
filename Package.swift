// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ThorVGSwift",
    platforms: [
        .iOS(.v13)
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
            dependencies: ["thorvg"],
            path: "Sources/swift"
        ),
        .target(
            name: "thorvg",
            path: "thorvg",
            exclude: [
                "cross",
                "docs",
                "examples",
                "pc",
                "res",
                "src/bindings/wasm",
                "src/loaders/external_jpg",
                "src/loaders/external_png",
                "src/loaders/external_webp",
                "src/renderer/gl_engine",
                "src/renderer/wg_engine",
                "src/savers/gif",
                "src/tools",
                "test",
                "web"
            ],
            publicHeadersPath: "src/bindings/capi",
            cxxSettings: [
                .headerSearchPath("inc"),
                .headerSearchPath("src/common"),
                .headerSearchPath("src/bindings"),
                .headerSearchPath("src/loaders/jpg"),
                .headerSearchPath("src/loaders/lottie"),
                .headerSearchPath("src/loaders/lottie"),
                .headerSearchPath("src/loaders/lottie/jerryscript"),
                .headerSearchPath("src/loaders/lottie/rapidjson"),
                .headerSearchPath("src/loaders/lottie/jerryscript/jerry-core"),
                .headerSearchPath("src/loaders/lottie/jerryscript/jerry-core/jcontext"),
                .headerSearchPath("src/loaders/lottie/jerryscript/jerry-core/lit"),
                .headerSearchPath("src/loaders/lottie/jerryscript/jerry-core/include"),
                .headerSearchPath("src/loaders/lottie/jerryscript/jerry-core/parser"),
                .headerSearchPath("src/loaders/lottie/jerryscript/jerry-core/jrt"),
                .headerSearchPath("src/loaders/lottie/jerryscript/jerry-core/vm"),
                .headerSearchPath("src/loaders/lottie/jerryscript/jerry-core/ecma"),
                .headerSearchPath("src/loaders/lottie/jerryscript/jerry-core/jmem"),
                .headerSearchPath("src/loaders/lottie/jerryscript/jerry-core/api"),
                .headerSearchPath("src/loaders/lottie/jerryscript/jerry-core/parser/regexp"),
                .headerSearchPath("src/loaders/lottie/jerryscript/jerry-core/parser/js"),
                .headerSearchPath("src/loaders/lottie/jerryscript/jerry-core/ecma/builtin-objects"),
                .headerSearchPath("src/loaders/lottie/jerryscript/jerry-core/ecma/operations"),
                .headerSearchPath("src/loaders/lottie/jerryscript/jerry-core/ecma/base"),
                .headerSearchPath("src/loaders/lottie/jerryscript/jerry-core/ecma/builtin-objects/typedarray"),
                .headerSearchPath("src/loaders/lottie/rapidjson/internal"),
                .headerSearchPath("src/loaders/lottie/rapidjson/error"),
                .headerSearchPath("src/loaders/png"),
                .headerSearchPath("src/loaders/raw"),
                .headerSearchPath("src/loaders/svg"),
                .headerSearchPath("src/loaders/ttf"),
                .headerSearchPath("src/loaders/tvg"),
                .headerSearchPath("src/renderer"),
                .headerSearchPath("src/renderer/sw_engine"),
            ]
        ),
        .testTarget(
            name: "ThorVGSwift-tests",
            dependencies: [
                "ThorVGSwift",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            path: "Sources/swift-tests",
            exclude: ["SnapshotTests/__Snapshots__"],
            resources: [.process("Resources")]
        ),
    ],
    cxxLanguageStandard: .cxx14
)
