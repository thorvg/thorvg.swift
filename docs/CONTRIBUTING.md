# Contributing to ThorVGSwift

Thank you for your interest in contributing! This guide will help you get started with the project.

## Quick Start for Testing

The **ThorVGSampleApp** is perfect for testing your changes:

1. Make changes to Swift code in `swift/`
2. Open `ThorVGSampleApp/ThorVGSampleApp.xcodeproj` in Xcode
3. Build and run (⌘R)
4. See your changes in action immediately!

The sample app includes all ThorVGSwift features with visual examples.

## Project Structure

```
thorvg.swift/
├── README.md                        # Main documentation
├── Package.swift                    # Swift Package manifest
├── build_frameworks.sh              # Build script for local development
├── release.sh                       # Release preparation script
│
├── swift/                           # Swift wrapper source code
├── swift-tests/                     # Test suite
├── ThorVG.xcframework/              # Pre-built binary (only in releases, not in repo)
├── thorvg/                          # ThorVG C++ submodule
│
└── docs/                            # Additional documentation
    ├── CONTRIBUTING.md              # This file
    └── BUILD_SYSTEM.md              # Build system details

```

## Quick Start

To contribute to this project, you'll need:

- macOS with Xcode installed
- [Meson](https://mesonbuild.com/) build system: `brew install meson ninja`
- Command line tools: `xcode-select --install`

## Building for Local Development

The project uses ThorVG's native Meson build system to create a static library, then packages it as an XCFramework for iOS and macOS:

```bash
# Clone with submodules
git clone --recursive https://github.com/thorvg/thorvg.swift
cd thorvg.swift

# Build the XCFramework locally
./build_frameworks.sh

# Build and test the Swift package
swift build
swift test  # macOS tests only
```

For iOS testing, open `Package.swift` in Xcode, select an iOS Simulator, and run tests (Cmd+U).

> **Note:** The `ThorVG.xcframework` is NOT committed to the repository for regular development. It's only included in tagged releases. You must build it locally using `./build_frameworks.sh` before working on the project.

## Making Changes

### Updating Swift Code

1. Make your changes in `swift/`
2. Run tests to ensure everything works
3. Submit a pull request

### Updating the ThorVG Version

If you need to update to a new version of ThorVG:

1. Update the `thorvg` submodule:
   ```bash
   cd thorvg
   git fetch --tags
   git checkout <new-version-tag>
   cd ..
   git add thorvg
   git commit -m "Update ThorVG submodule to v0.15.16"
   ```

2. Rebuild locally to test:
   ```bash
   rm -rf ThorVG.xcframework build lib
   ./build_frameworks.sh
   swift build
   swift test
   # Also test in Xcode with iOS Simulator
   ```

3. Submit a PR with just the submodule update (don't commit the XCFramework)

**Note**: The XCFramework will be built and included when creating a release (see [Creating a Release](#creating-a-release))

## Understanding the Build System

For detailed information about how the build system works, including:
- Cross-compilation for iOS
- Platform-specific build options
- SIMD and threading configuration
- XCFramework structure
- Troubleshooting build issues

See **[BUILD_SYSTEM.md](BUILD_SYSTEM.md)** for complete details.

## What to Commit

### ✅ DO Commit (Regular Development)
- All Swift source code (`swift/`)
- Tests and resources (`swift-tests/`)
- Build scripts (`build_frameworks.sh`, `release.sh`)
- Documentation (`README.md`, `docs/`)
- `thorvg/` submodule updates
- `Package.swift` changes

### ❌ DON'T Commit (Regular Development)
- `ThorVG.xcframework/` - Only included in release commits (in `.gitignore`)
- `build/` - Build artifacts (in `.gitignore`)
- `lib/` - Standalone macOS library (in `.gitignore`)
- `.build/` - SPM build folder (in `.gitignore`)
- `.DS_Store` - macOS metadata (in `.gitignore`)

### Release Commits (Special Case)
The `ThorVG.xcframework` is **only** committed in release commits created by `./release.sh`. This ensures:
- The repository stays lightweight for contributors
- End users get pre-built binaries when using tagged releases
- Local development requires building from source

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
- [ ] XCFramework NOT committed (it will be built during release)

## Creating a Release

> **Note:** This section is for maintainers with push access to the repository.

To create a new release with pre-built binaries:

```bash
# Ensure you're on the main branch with latest changes
git checkout main
git pull

# Run the release script (e.g., for version 0.1.0)
./release.sh 0.1.0
```

The release script will:
1. ✅ Build the XCFramework for all platforms
2. ✅ Create a release commit (with the XCFramework)
3. ✅ Create an annotated git tag (e.g., `v0.1.0`)
4. ℹ️ Provide instructions for pushing and creating the GitHub release

After the script completes:

```bash
# Push the tag to GitHub
git push origin v0.1.0

# Create a GitHub release from the tag
# Visit: https://github.com/thorvg/thorvg.swift/releases/new?tag=v0.1.0
```

When creating the GitHub release:
- Add release notes describing changes and features
- The XCFramework is already in the tagged commit
- Users can now use this version in their `Package.swift`

### After the Release

Once the tag is pushed, reset your local branch to remove the XCFramework:

```bash
# Move back to before the release commit
git reset --hard HEAD~1

# Now you're back to normal development (XCFramework not in working tree)
```

The XCFramework only exists in the tagged commit, not in the main branch history.

## Getting Help

- Check [BUILD_SYSTEM.md](BUILD_SYSTEM.md) for build system details
- Review existing issues on GitHub
- Open a new issue for bugs or feature requests
- Join the discussion in Pull Requests

## License

By contributing, you agree that your contributions will be licensed under the MIT License. See the LICENSE file for details.

The ThorVG library is licensed under the MIT License. See `thorvg/LICENSE` for details.

