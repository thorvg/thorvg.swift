# ThorVGSwift Build System

This document explains how ThorVGSwift builds and packages the ThorVG library for distribution via Swift Package Manager.

## Overview

ThorVGSwift uses a **pre-built binary** approach rather than compiling C++ source directly through Swift Package Manager. The build process:

1. Compiles ThorVG as a **static library** (`.a` files) using its native **Meson** build system
2. Builds for multiple platforms: macOS (arm64 + x86_64), iOS (arm64), iOS Simulator (arm64)
3. Packages everything into a single **XCFramework** that Swift Package Manager can use

This approach provides several benefits:
- ✅ **Simplicity**: Users don't need Meson or complex build tools
- ✅ **Speed**: No compilation time for end users
- ✅ **Maintenance**: ThorVG's build system handles platform-specific complexity
- ✅ **Reliability**: Consistent builds across all developer environments

## Build Script: `build_frameworks.sh`

The entire build process is automated by `build_frameworks.sh`, which:

### 1. Dynamic Environment Detection

```bash
# Automatically detects Xcode installation
XCODE_DEVELOPER_DIR=$(xcode-select -p)

# Finds SDK paths dynamically
IPHONEOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
IPHONESIMULATOR_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
```

This ensures the build works regardless of whether you have `Xcode.app`, `Xcode-26.app`, or any other Xcode installation.

### 2. Platform-Specific Builds

The script builds ThorVG separately for each target platform:

#### macOS (arm64 + x86_64)
```bash
# Build for arm64
meson setup build/macosx-arm64 --buildtype=release ...
ninja -C build/macosx-arm64

# Build for x86_64
meson setup build/macosx-x86_64 --buildtype=release ...
ninja -C build/macosx-x86_64

# Combine into universal binary
lipo -create \
  build/macosx-arm64/src/libthorvg.a \
  build/macosx-x86_64/src/libthorvg.a \
  -output libthorvg-macos.a
```

#### iOS Device (arm64)
```bash
meson setup build/iphoneos-arm64 \
  --cross-file cross-iphoneos-arm64.txt \
  --buildtype=release ...
ninja -C build/iphoneos-arm64
```

#### iOS Simulator (arm64)
```bash
meson setup build/iphonesimulator-arm64 \
  --cross-file cross-iphonesimulator-arm64.txt \
  --buildtype=release ...
ninja -C build/iphonesimulator-arm64
```

### 3. XCFramework Creation

The script creates an XCFramework with the correct structure:

```
ThorVG.xcframework/
├── Info.plist                           # Framework metadata
├── macos-arm64_x86_64/                  # macOS universal binary
│   ├── libthorvg.a
│   └── Headers/
│       ├── thorvg_capi.h
│       └── module.modulemap
├── ios-arm64/                           # iOS device
│   ├── libthorvg.a
│   └── Headers/
│       ├── thorvg_capi.h
│       └── module.modulemap
└── ios-arm64_x86_64-simulator/          # iOS Simulator
    ├── libthorvg.a
    └── Headers/
        ├── thorvg_capi.h
        └── module.modulemap
```

Each platform slice includes:
- **Static library** (`.a` file) with the compiled ThorVG code
- **Header file** (`thorvg_capi.h`) with the C API declarations
- **Module map** (`module.modulemap`) to expose the library to Swift

## Cross-Compilation

Cross-compilation is the process of building code on one platform (macOS) for execution on another (iOS device/simulator). The build script creates temporary **cross-compilation files** that tell Meson how to build for each target.

### Key Differences: Device vs Simulator

The critical distinction between iOS device and simulator builds is the **target triple**:

```bash
# iOS Device
arm64-apple-ios13.0           # Platform ID: 2 (iOS)

# iOS Simulator  
arm64-apple-ios13.0-simulator # Platform ID: 7 (iOS Simulator)
```

The `-simulator` suffix ensures Xcode correctly identifies simulator binaries. Without this, you'll get linker errors like:
```
Building for 'iOS-simulator', but linking in object file built for 'iOS'
```

### Cross-Compilation File Format

Each cross-file specifies:
- **Compiler**: `clang++` with appropriate `-target` flag
- **SDK path**: Points to platform-specific SDK (iPhoneOS.sdk vs iPhoneSimulator.sdk)
- **Minimum version**: iOS 13.0 deployment target
- **Host machine**: CPU architecture and platform information

Example for iOS Simulator:
```ini
[binaries]
cpp = ['clang++', '-target', 'arm64-apple-ios13.0-simulator', '-isysroot', '<SDK_PATH>']

[host_machine]
system = 'darwin'
subsystem = 'ios'
cpu_family = 'aarch64'
cpu = 'aarch64'
```

## Build Script Options

The build script uses carefully tuned Meson options for each platform:

### Common Options (All Platforms)
```bash
-Ddefault_library=static      # Build static library, not dynamic
-Dloaders=svg,tvg,lottie,ttf  # Enable specific file format loaders
-Dsavers=                      # Disable savers (not needed for rendering)
-Dengines=sw                   # Use software rendering engine
-Dbindings=capi               # Enable C API bindings (for Swift interop)
-Dexamples=false              # Don't build examples
-Dtests=false                 # Don't build tests
-Dtools=                      # Don't build command-line tools
-Dlog=false                   # Disable logging
-Dextra=lottie_expressions    # Enable Lottie expression support
-Dbuildtype=release           # Optimize for release
-Dstrip=true                  # Strip debug symbols (smaller binary)
```

### macOS-Specific Options
```bash
-Dthreads=true               # Enable pthread support (available on macOS)
-Dsimd=true                  # Enable SIMD optimizations (AVX on x86_64)
```

**Why threading works on macOS**: pthread is a standard UNIX library that's always available on macOS.

**Why SIMD works on macOS**: Desktop CPUs support advanced SIMD instructions like AVX for faster rendering.

### iOS-Specific Options
```bash
-Dthreads=false              # Disable pthread (integrated into iOS system libs)
-Dsimd=false                 # Disable SIMD (avoid ARM-specific flags)
```

**Why threading is disabled on iOS**: iOS integrates pthread directly into the system libraries. Trying to link against a separate pthread library causes build failures. Threading still works; we just don't explicitly link the library.

**Why SIMD is disabled on iOS**: Meson's SIMD detection tries to add `-mfpu=neon` which is invalid for ARM64 (that flag is for ARM32). Modern ARM64 CPUs have NEON built-in by default, so we don't need to explicitly enable it.

### Impact on Performance

| Platform | Threads | SIMD | Performance Notes |
|----------|---------|------|-------------------|
| macOS arm64 | ✅ | ✅ | Full multi-core + vector optimizations |
| macOS x86_64 | ✅ | ✅ | Full multi-core + AVX optimizations |
| iOS device | ⚠️ System | ⚠️ Built-in | Single-threaded, but NEON is implicit |
| iOS simulator | ⚠️ System | ⚠️ Built-in | Single-threaded, but NEON is implicit |

**Note**: iOS performance is still excellent for typical use cases. Most Lottie animations render in milliseconds even without explicit threading.

## Build Outputs

After running `build_frameworks.sh`, you'll have:

```
ThorVG.xcframework/          # ← Commit this to Git
├── Info.plist
├── ios-arm64/
├── ios-arm64_x86_64-simulator/
└── macos-arm64_x86_64/

build/                       # ← Don't commit (in .gitignore)
├── cross-iphoneos-arm64.txt
├── cross-iphonesimulator-arm64.txt
├── iphoneos-arm64/
├── iphonesimulator-arm64/
├── macosx-arm64/
└── macosx-x86_64/

lib/                         # ← Don't commit (in .gitignore)
└── libthorvg.a             # Standalone macOS library (for local dev)
```

### What Gets Committed

**Only commit `ThorVG.xcframework/`** to the repository. This pre-built binary is essential for Swift Package Manager users who depend on your package. They download the XCFramework directly without needing to build ThorVG themselves.

**Don't commit `build/` or `lib/`** - these are temporary build artifacts added to `.gitignore`.

## How Swift Package Manager Uses the XCFramework

When a user adds ThorVGSwift to their `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/thorvg/thorvg.swift", from: "0.1.0")
]
```

SPM will:
1. Clone the repository (including the committed `ThorVG.xcframework`)
2. Read `Package.swift` and find the binary target
3. Select the appropriate platform slice:
   - macOS build → uses `macos-arm64_x86_64/libthorvg.a`
   - iOS device → uses `ios-arm64/libthorvg.a`
   - iOS simulator → uses `ios-arm64_x86_64-simulator/libthorvg.a`
4. Link the static library directly to the user's app
5. Compile only the Swift wrapper code in `swift/`

**No C++ compilation happens** for end users - they get instant builds!

## Updating ThorVG Version

To update to a newer version of ThorVG:

```bash
# 1. Update the submodule
cd thorvg
git fetch --tags
git checkout v0.15.16  # or whatever version you want
cd ..

# 2. Rebuild the XCFramework
rm -rf ThorVG.xcframework build lib
./build_frameworks.sh

# 3. Test
swift build
swift test  # macOS tests
# Also test in Xcode with iOS Simulator

# 4. Commit the new XCFramework
git add thorvg ThorVG.xcframework
git commit -m "Update ThorVG to v0.15.16"
```

## Troubleshooting

### Build fails with "command not found: meson"
```bash
brew install meson
```

### Build fails with SDK not found
The script uses `xcrun` to find SDKs dynamically. Ensure Xcode is installed:
```bash
xcode-select --install
xcode-select -p  # Should show your Xcode path
```

### Linker error: "building for iOS-simulator, but linking object built for iOS"
This means the simulator binary wasn't properly tagged with the `-simulator` target triple. Rebuild:
```bash
rm -rf ThorVG.xcframework build
./build_frameworks.sh
```

### XCFramework seems large
The XCFramework contains optimized static libraries for three platform variants. Users only download what they need. Typical sizes:
- macOS library: ~2-3 MB (universal binary)
- iOS library: ~1-2 MB (arm64 only)
- iOS Simulator library: ~1-2 MB (arm64 only)

Total in repository: ~5-8 MB (compressed by Git)

## Platform Support

| Platform | Architectures | Min Version | Threading | SIMD |
|----------|--------------|-------------|-----------|------|
| macOS | arm64, x86_64 | 10.15+ | ✅ | ✅ |
| iOS | arm64 | 13.0+ | System | Built-in |
| iOS Simulator | arm64 | 13.0+ | System | Built-in |

**Note**: Intel Mac users can run the arm64 simulator build via Rosetta 2. If you need native x86_64 simulator support, modify `build_frameworks.sh` to add an x86_64 simulator build and create a fat binary with `lipo`.

## Additional Resources

- [ThorVG Documentation](https://www.thorvg.org/)
- [ThorVG GitHub](https://github.com/thorvg/thorvg)
- [Meson Build System](https://mesonbuild.com/)
- [XCFramework Documentation](https://developer.apple.com/documentation/xcode/creating-a-multi-platform-binary-framework-bundle)

