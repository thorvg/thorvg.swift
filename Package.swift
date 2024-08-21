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
            path: "swift"
        ),
        .target(
            name: "thorvg",
            path: "thorvg/src",
            exclude: [
                "bindings/wasm",
                "loaders/external_jpg",
                "loaders/external_png",
                "loaders/external_webp",
                "renderer/gl_engine",
                "renderer/wg_engine",
                "savers/gif",
                "tools",
            ],
            publicHeadersPath: "bindings/capi",
            cxxSettings: [
                .headerSearchPath("inc"),
                .headerSearchPath("common"),
                .headerSearchPath("bindings"),
                .headerSearchPath("loaders/jpg"),
                .headerSearchPath("loaders/lottie"),
                .headerSearchPath("loaders/lottie"),
                .headerSearchPath("loaders/lottie/jerryscript"),
                .headerSearchPath("loaders/lottie/rapidjson"),
                .headerSearchPath("loaders/lottie/jerryscript/jerry-core"),
                .headerSearchPath("loaders/lottie/jerryscript/jerry-core/jcontext"),
                .headerSearchPath("loaders/lottie/jerryscript/jerry-core/lit"),
                .headerSearchPath("loaders/lottie/jerryscript/jerry-core/include"),
                .headerSearchPath("loaders/lottie/jerryscript/jerry-core/parser"),
                .headerSearchPath("loaders/lottie/jerryscript/jerry-core/jrt"),
                .headerSearchPath("loaders/lottie/jerryscript/jerry-core/vm"),
                .headerSearchPath("loaders/lottie/jerryscript/jerry-core/ecma"),
                .headerSearchPath("loaders/lottie/jerryscript/jerry-core/jmem"),
                .headerSearchPath("loaders/lottie/jerryscript/jerry-core/api"),
                .headerSearchPath("loaders/lottie/jerryscript/jerry-core/parser/regexp"),
                .headerSearchPath("loaders/lottie/jerryscript/jerry-core/parser/js"),
                .headerSearchPath("loaders/lottie/jerryscript/jerry-core/ecma/builtin-objects"),
                .headerSearchPath("loaders/lottie/jerryscript/jerry-core/ecma/operations"),
                .headerSearchPath("loaders/lottie/jerryscript/jerry-core/ecma/base"),
                .headerSearchPath("loaders/lottie/jerryscript/jerry-core/ecma/builtin-objects/typedarray"),
                .headerSearchPath("loaders/lottie/rapidjson/internal"),
                .headerSearchPath("loaders/lottie/rapidjson/error"),
                .headerSearchPath("loaders/png"),
                .headerSearchPath("loaders/raw"),
                .headerSearchPath("loaders/svg"),
                .headerSearchPath("loaders/ttf"),
                .headerSearchPath("loaders/tvg"),
                .headerSearchPath("renderer"),
                .headerSearchPath("renderer/sw_engine"),
            ],
            linkerSettings: [
                .linkedLibrary("pthread")
            ]
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
