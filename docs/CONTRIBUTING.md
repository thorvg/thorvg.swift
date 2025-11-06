# Contributing to ThorVGSwift

<<<<<<< HEAD
Thank you for your interest in contributing! This guide will help you get started with the project.
=======
Thank you for your interest in contributing! This guide will help you understand the project structure and how to build from source.
>>>>>>> 1fa8ad9 (More docs)

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
<<<<<<< HEAD
    └── BUILD_SYSTEM.md              # Build system details
```

## Quick Start

### Prerequisites
=======
    ├── MIGRATION_SUMMARY.md         # Details about the build system migration
    ├── CROSS_COMPILATION_NOTES.md   # Cross-compilation technical notes
    └── UPSTREAM_CONTRIBUTION_GUIDE.md # Guide for contributing to upstream ThorVG
```

## Prerequisites

To build the XCFramework from source, you'll need:
>>>>>>> 1fa8ad9 (More docs)

- macOS with Xcode installed
- [Meson](https://mesonbuild.com/) build system: `brew install meson`
- Command line tools: `xcode-select --install`

<<<<<<< HEAD
### Building

```bash
# Clone with submodules
git clone --recursive https://github.com/thorvg/thorvg.swift
cd thorvg.swift

# Build the XCFramework
./build_frameworks.sh

# Build and test the Swift package
swift build
swift test  # macOS tests only
```

For iOS testing, open `Package.swift` in Xcode, select an iOS Simulator, and run tests (Cmd+U).
=======
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
>>>>>>> 1fa8ad9 (More docs)

## Making Changes

### Updating Swift Code

<<<<<<< HEAD
1. Make your changes in `swift/` or `swift-tests/`
2. Run tests: `swift test` (macOS) and in Xcode (iOS)
=======
1. Make your changes in `swift/`
2. Run tests to ensure everything works
>>>>>>> 1fa8ad9 (More docs)
3. Submit a pull request

### Updating the XCFramework

If you need to rebuild the binary (e.g., updating ThorVG version, changing build options):

<<<<<<< HEAD
```bash
# Update ThorVG submodule (if needed)
cd thorvg
git fetch --tags
git checkout v0.15.16  # or desired version
cd ..
git add thorvg

# Rebuild
rm -rf ThorVG.xcframework build lib
./build_frameworks.sh

# Test thoroughly
swift build
swift test
# Also test in Xcode with iOS Simulator

# Commit the new XCFramework
git add ThorVG.xcframework
git commit -m "Update ThorVG to v0.15.16"
```

**Important**: Always commit the updated `ThorVG.xcframework/` - it's essential for SPM users!

## Understanding the Build System

For detailed information about how the build system works, including:
- Cross-compilation for iOS
- Platform-specific build options
- SIMD and threading configuration
- XCFramework structure
- Troubleshooting build issues

See **[BUILD_SYSTEM.md](BUILD_SYSTEM.md)** for complete details.

## What to Commit

### ✅ DO Commit
- `ThorVG.xcframework/` - Pre-built binary (essential for SPM users!)
- All Swift source code (`swift/`)
- Tests and resources (`swift-tests/`)
- Build scripts (`build_frameworks.sh`)
- Documentation (`README.md`, `docs/`)

### ❌ DON'T Commit
- `build/` - Build artifacts (in `.gitignore`)
- `lib/` - Standalone macOS library (in `.gitignore`)
- `.build/` - SPM build folder (in `.gitignore`)
- `.DS_Store` - macOS metadata (in `.gitignore`)

## Testing

### Running Tests

```bash
# macOS tests from command line
swift build
swift test

# iOS tests in Xcode
open Package.swift  # Opens in Xcode
# Select iOS Simulator as destination
# Press Cmd+U to run tests
```

### Snapshot Tests

The project uses [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) for visual regression testing. Snapshots are stored in `swift-tests/SnapshotTests/__Snapshots__/`.

To record new snapshots:
1. Set `record: true` in the test
2. Run the test once to capture the snapshot
3. Set `record: false` and run again to verify

## Code Style

- Follow standard Swift conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features

## Pull Request Process

1. Create a feature branch (`git checkout -b feature/amazing-feature`)
2. Make your changes
3. Run tests and ensure they pass
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to your branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

### PR Checklist

- [ ] Tests pass on macOS (`swift test`)
- [ ] Tests pass on iOS (in Xcode)
- [ ] No linter warnings
- [ ] Updated documentation if needed
- [ ] XCFramework committed if ThorVG was updated

## Getting Help

- Check [BUILD_SYSTEM.md](BUILD_SYSTEM.md) for build system details
- Review existing issues on GitHub
- Open a new issue for bugs or feature requests
- Join the discussion in Pull Requests

## License

By contributing, you agree that your contributions will be licensed under the MIT License. See the LICENSE file for details.

The ThorVG library is also licensed under the MIT License. See `thorvg/LICENSE` for details.
=======
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

>>>>>>> 1fa8ad9 (More docs)
