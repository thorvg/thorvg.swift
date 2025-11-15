# Changelog

All notable changes to ThorVGSwift will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure
- Low-level API for direct Lottie frame rendering
- High-level Views API (SwiftUI and UIKit)
- LottieViewModel for state management
- Playback controls (play, pause, stop, seek)
- Loop modes (playOnce, loop, repeat, autoReverse)
- Content modes (aspect fit, aspect fill)
- Error handling through Combine publishers
- Comprehensive test suite with snapshot testing
- Sample iOS app demonstrating all features
- Cross-platform support (iOS 13.0+, macOS 10.15+)
- Pre-built XCFramework for easy integration
- Automated build scripts
- Complete documentation

### Technical Details
- ThorVG version: v0.14.7 (commit e3a6bf)
- Supported platforms: macOS (arm64 + x86_64), iOS (arm64), iOS Simulator (arm64)
- Built with Meson build system
- Static library distribution via XCFramework

---

## [0.1.0] - YYYY-MM-DD (Template for first release)

### Added
- Initial public release of ThorVGSwift
- Lottie animation rendering support
- SwiftUI `LottieView` component
- UIKit `LottieUIKitView` component
- `LottieViewModel` for animation state management
- Multiple playback loop modes
- Speed control for animations
- Progress tracking and seeking
- Error handling and reporting
- Comprehensive documentation
- Sample app with examples
- Support for iOS 13.0+ and macOS 10.15+

### Known Limitations
- Only Lottie animations are currently supported (SVG and other formats coming in future releases)
- Threading disabled on iOS and macOS to avoid OpenMP linking issues with Swift Package Manager

---

<!-- Template for future releases:

## [X.Y.Z] - YYYY-MM-DD

### Added
- New features and capabilities

### Changed
- Changes to existing functionality

### Deprecated
- Features marked for removal in future versions

### Removed
- Features removed in this version

### Fixed
- Bug fixes

### Security
- Security fixes

-->

[Unreleased]: https://github.com/thorvg/thorvg.swift/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/thorvg/thorvg.swift/releases/tag/v0.1.0

