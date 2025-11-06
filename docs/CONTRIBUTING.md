# Contributing to ThorVGSwift

Thank you for your interest in contributing! This guide will help you understand the project structure and how to build from source.

## Project Structure

```
thorvg.swift/
├── README.md                        # Main documentation
├── Package.swift                    # Swift Package manifest
├── build_frameworks.sh              # Build script for XCFramework
│
├── swift/                           # Swift wrapper source code
├── swift-tests/                     # Test suite
├── ThorVG.xcframework/              # Pre-built binary (committed to repo)
├── thorvg/                          # ThorVG C++ submodule
│
└── docs/                            # Additional documentation
    ├── CONTRIBUTING.md              # This file
    ├── MIGRATION_SUMMARY.md         # Details about the build system migration
    ├── CROSS_COMPILATION_NOTES.md   # Cross-compilation technical notes
    └── UPSTREAM_CONTRIBUTION_GUIDE.md # Guide for contributing to upstream ThorVG
```

## Prerequisites

To build the XCFramework from source, you'll need:

- macOS with Xcode installed
- [Meson](https://mesonbuild.com/) build system: `brew install meson`
- Command line tools: `xcode-select --install`

## Building the XCFramework

The project uses ThorVG's native Meson build system to create a static library, then packages it as an XCFramework for iOS and macOS:

```bash
# Build for all platforms (macOS arm64/x86_64, iOS arm64, iOS Simulator arm64)
./build_frameworks.sh
```

This will:
1. Build ThorVG as a static library for each platform
2. Create universal binaries (e.g., macOS arm64+x86_64)
3. Package everything into `ThorVG.xcframework`

The build script automatically detects your Xcode installation and SDK paths.

## Testing

```bash
# Build the Swift package (macOS only from command line)
swift build

# Run tests in Xcode (recommended for iOS testing)
# 1. Open Package.swift in Xcode
# 2. Select an iOS Simulator
# 3. Run tests (Cmd+U)
```

## Making Changes

### Updating Swift Code

1. Make your changes in `swift/`
2. Run tests to ensure everything works
3. Submit a pull request

### Updating the XCFramework

If you need to rebuild the binary (e.g., updating ThorVG version, changing build options):

1. Update the `thorvg` submodule if needed:
   ```bash
   cd thorvg
   git checkout <new-version-tag>
   cd ..
   git add thorvg
   ```

2. Modify build options in `build_frameworks.sh` if needed (look for `MESON_OPTIONS_BASE`)

3. Rebuild:
   ```bash
   rm -rf ThorVG.xcframework build
   ./build_frameworks.sh
   ```

4. Test thoroughly on both iOS and macOS

5. **Commit the new XCFramework** - it's essential for SPM users:
   ```bash
   git add ThorVG.xcframework
   git commit -m "Update ThorVG to version X.Y.Z"
   ```

## Important Notes

### What Gets Committed

**DO commit:**
- `ThorVG.xcframework/` - Pre-built binary (essential for SPM users!)
- All Swift source code
- Tests and resources
- Build scripts

**DON'T commit:**
- `build/` - Build artifacts (ignored by .gitignore)
- `lib/` - Old standalone library approach (ignored by .gitignore)
- `.build/` - SPM build folder (ignored by .gitignore)

### Why Commit the XCFramework?

Unlike traditional Swift packages that compile C++ source directly, we provide a **pre-built binary** because:

1. **Simplicity**: Users don't need Meson or complex build tools
2. **Speed**: No compilation time for end users
3. **Maintenance**: ThorVG's build system handles platform complexity
4. **Binary size**: Users only download what they need for their platform

When users add this package to their project, Swift Package Manager downloads the XCFramework and links it directly - no compilation required.

## Platform Support

- **iOS**: 13.0+ (device and simulator)
- **macOS**: 10.15+ (arm64 and x86_64)

The build script creates:
- `ios-arm64` - For iPhone/iPad devices
- `ios-arm64_x86_64-simulator` - For iOS Simulator (both Apple Silicon and Intel Macs running simulator)
- `macos-arm64_x86_64` - For macOS (universal binary)

## Getting Help

- Check existing documentation in `docs/`
- Look at `CROSS_COMPILATION_NOTES.md` for technical details
- Open an issue on GitHub

## License

This project is licensed under the MIT License. See the LICENSE file for details.

The ThorVG library is licensed under the MIT License. See `thorvg/LICENSE` for details.

