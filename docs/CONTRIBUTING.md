# Contributing to ThorVGSwift

Thank you for your interest in contributing! This guide will help you get started with the project.

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
    └── BUILD_SYSTEM.md              # Build system details
```

## Quick Start

### Prerequisites

- macOS with Xcode installed
- [Meson](https://mesonbuild.com/) build system: `brew install meson`
- Command line tools: `xcode-select --install`

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

## Making Changes

### Updating Swift Code

1. Make your changes in `swift/` or `swift-tests/`
2. Run tests: `swift test` (macOS) and in Xcode (iOS)
3. Submit a pull request

### Updating the XCFramework

If you need to rebuild the binary (e.g., updating ThorVG version, changing build options):

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

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests and ensure they pass
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to your fork (`git push origin feature/amazing-feature`)
7. Open a Pull Request

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
