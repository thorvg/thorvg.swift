# Changelog

All notable changes to ThorVGSwift will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

No unreleased changes yet.

---

## [0.1.0] - 2025-11-15

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

