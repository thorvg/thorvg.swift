# Release Policy

This document outlines the release policy for ThorVGSwift, including versioning, release cadence, testing requirements, and procedures.

## Versioning

ThorVGSwift follows [Semantic Versioning 2.0.0](https://semver.org/) (SemVer):

```
MAJOR.MINOR.PATCH
```

### Version Components

- **MAJOR**: Incremented for incompatible API changes
- **MINOR**: Incremented for new functionality in a backwards-compatible manner
- **PATCH**: Incremented for backwards-compatible bug fixes

### Pre-1.0 Releases

During the initial development phase (versions `0.x.x`), the project is considered unstable:
- Minor version bumps (0.1.0 → 0.2.0) **may** include breaking changes
- Patch version bumps (0.1.0 → 0.1.1) should be backwards-compatible
- Breaking changes should be clearly documented in release notes

### Post-1.0 Releases

Once version 1.0.0 is released:
- The public API is considered stable
- Breaking changes **only** in major version bumps (1.x.x → 2.0.0)
- Deprecation warnings should be added one minor version before removal
- Full adherence to semantic versioning principles

## Release Types

### Stable Releases

Stable releases are tagged with version numbers (e.g., `v0.1.0`, `v1.0.0`) and include:
- Pre-built XCFramework binaries
- Comprehensive release notes
- Full test coverage passing
- Documentation updates

### Beta/Pre-releases

Beta releases may be used for testing major features:
- Tagged with beta suffix (e.g., `v0.2.0-beta.1`)
- Not recommended for production use
- Solicits community feedback
- May have known issues documented

## Release Cadence

### Initial Phase (v0.x)

During the initial development phase:
- **Patch releases**: As needed for critical bugs
- **Minor releases**: When significant new features are ready
- **No fixed schedule**: Prioritizing quality over frequency

### Stable Phase (v1.0+)

After reaching v1.0.0:
- **Patch releases**: Within 1-2 weeks for critical bugs
- **Minor releases**: Every 2-3 months with new features
- **Major releases**: As needed for breaking changes (ideally 12+ months between)

## Release Requirements

Every release must meet these requirements before being published:

### ✅ Code Quality

- [ ] All tests pass on macOS
- [ ] All tests pass on iOS Simulator
- [ ] All tests pass on iOS Device (manual verification)
- [ ] No compiler warnings
- [ ] No linter errors
- [ ] Code review completed (for PRs)

### ✅ Documentation

- [ ] docs/CHANGELOG.md updated with all changes
- [ ] README.md updated if needed
- [ ] API documentation updated for new/changed features
- [ ] Migration guide created for breaking changes (if applicable)
- [ ] Version numbers updated in documentation examples

### ✅ XCFramework

- [ ] XCFramework builds successfully for all platforms:
  - macOS (arm64 + x86_64)
  - iOS Device (arm64)
  - iOS Simulator (arm64)
- [ ] XCFramework size is reasonable (documented if significantly changed)
- [ ] Sample app builds and runs with the new XCFramework

### ✅ Testing

- [ ] Unit tests pass
- [ ] Snapshot tests pass (visual regression)
- [ ] Sample app tested manually
- [ ] Performance benchmarks run (for significant changes)
- [ ] Memory leak checks performed

### ✅ Swift Package Manager

- [ ] Package.swift has correct version references
- [ ] Package builds successfully via SPM
- [ ] Package resolves dependencies correctly
- [ ] Integration test in a fresh project succeeds

## Release Process

The release process is automated using the `scripts/release.sh` script. Follow these steps:

### 1. Pre-Release Preparation

```bash
# Ensure you're on the main branch
git checkout main
git pull origin main

# Verify everything is up to date
git status

# Run full test suite
swift build
swift test

# Test in Xcode (iOS)
open Package.swift
# Run tests in Xcode with iOS Simulator (⌘+U)

# Test sample app
open ThorVGSampleApp/ThorVGSampleApp.xcodeproj
# Build and run (⌘+R), verify all examples work
```

### 2. Update Documentation

Update the following files before creating the release:

#### docs/CHANGELOG.md

Create a new entry at the top of `docs/CHANGELOG.md`:

```markdown
## [0.1.0] - 2024-XX-XX

### Added
- New feature descriptions
- API additions

### Changed
- Modified behaviors
- API changes

### Fixed
- Bug fixes

### Breaking Changes
- List any breaking changes (for v0.x releases)
```

#### README.md

- Update version numbers in installation examples
- Update supported ThorVG version if changed
- Add any new features to the feature list
- Update documentation links if needed

#### Version in Code

If you have version constants in your code, update them:
- Check for hardcoded version strings
- Update build scripts if they embed version info

### 3. Run Release Script

```bash
# Create the release (replace 0.1.0 with your version)
./scripts/release.sh 0.1.0
```

The script will:
1. ✅ Validate version format (semantic versioning)
2. ✅ Check for uncommitted changes
3. ✅ Verify the tag doesn't already exist
4. ✅ Build the XCFramework for all platforms
5. ✅ Create a release commit with the XCFramework
6. ✅ Create an annotated git tag
7. ℹ️ Provide instructions for next steps

### 4. Review and Push

```bash
# Review the release commit
git show HEAD

# Review the tag
git show v0.1.0

# Push the tag to GitHub
git push origin v0.1.0
```

**Important**: Only push the tag, not the main branch. The release commit with the XCFramework should only exist in the tagged commit.

### 5. Create GitHub Release

1. Go to: https://github.com/thorvg/thorvg.swift/releases/new?tag=v0.1.0
2. Title: `ThorVGSwift v0.1.0`
3. Copy the relevant section from docs/CHANGELOG.md into the release notes
4. Enhance with:
   - **Highlights**: Call out major features
   - **Breaking Changes**: Prominently display any breaking changes
   - **Migration Guide**: Link to migration guide if applicable
   - **Thanks**: Acknowledge contributors
5. Check "Set as the latest release" (or "Pre-release" for beta)
6. Click "Publish release"

### 6. Clean Up Local Environment

```bash
# Reset your local branch to remove the XCFramework from working tree
git reset --hard HEAD~1

# Verify you're back to normal development state
git status
ls ThorVG.xcframework  # Should not exist in working directory
```

The XCFramework only exists in the tagged commit, keeping the main branch lightweight.

### 7. Post-Release Tasks

- [ ] Announce release on Discord/social media
- [ ] Update package indices if applicable
- [ ] Monitor for issues in the first 24-48 hours
- [ ] Respond to GitHub issues related to the release
- [ ] Start planning next release milestone

## Hotfix Releases

For critical bugs in production releases:

### When to Create a Hotfix

- **Security vulnerabilities**: Immediate hotfix required
- **Critical bugs**: Breaking core functionality
- **Build failures**: Package doesn't build for users
- **Data corruption**: Issues that could cause data loss

### Hotfix Process

1. Create a hotfix branch from the latest release tag:
   ```bash
   git checkout -b hotfix/v0.1.1 v0.1.0
   ```

2. Make the minimal fix required (only the critical bug)

3. Test thoroughly:
   ```bash
   swift build
   swift test
   # Test in Xcode with iOS Simulator
   ```

4. Update docs/CHANGELOG.md with the hotfix

5. Merge to main:
   ```bash
   git checkout main
   git merge hotfix/v0.1.1
   ```

6. Create the hotfix release:
   ```bash
   ./scripts/release.sh 0.1.1
   git push origin v0.1.1
   ```

7. Create GitHub release with clear explanation of the fix

## Deprecation Policy

When deprecating API elements:

### Pre-1.0 (v0.x)

- Deprecations are **allowed** in minor versions
- Must provide alternatives in deprecation notice
- Can be removed in the next minor version
- Should be documented in CHANGELOG under "Deprecated"

### Post-1.0 (v1.x+)

- Mark as deprecated with `@available` annotations:
  ```swift
  @available(*, deprecated, message: "Use newFunction() instead")
  func oldFunction() { }
  ```
- Deprecation warnings must exist for **at least one minor version**
- Example: Deprecated in v1.2.0, can remove in v2.0.0
- Provide clear migration path in documentation

## Breaking Changes Communication

For any breaking changes:

### Documentation Requirements

1. **docs/CHANGELOG.md**: Dedicated "Breaking Changes" section
2. **GitHub Release Notes**: Prominent callout at the top
3. **Migration Guide**: Create `docs/MIGRATION_vX.md` for major versions
4. **Deprecation Warnings**: Add one version before removal when possible

### Migration Guide Template

```markdown
# Migration Guide: v0.x to v1.0

## Breaking Changes

### Change 1: API Renamed

**Before:**
\```swift
let lottie = Lottie.load(path: "animation.json")
\```

**After:**
\```swift
let lottie = try Lottie(path: "animation.json")
\```

**Reason:** Provides clearer error handling and follows Swift conventions.
```

## Release Checklist Template

Use this checklist for every release:

```markdown
## Release Checklist: v0.1.0

### Pre-Release
- [ ] All tests pass (macOS)
- [ ] All tests pass (iOS Simulator)
- [ ] Sample app works correctly
- [ ] docs/CHANGELOG.md updated
- [ ] README.md updated (version numbers)
- [ ] No uncommitted changes
- [ ] Documentation reviewed

### Build
- [ ] `./scripts/release.sh 0.1.0` executed successfully
- [ ] XCFramework built for all platforms
- [ ] Release commit created
- [ ] Git tag created

### Publish
- [ ] Tag pushed to GitHub: `git push origin v0.1.0`
- [ ] GitHub release created
- [ ] Release notes written
- [ ] Release marked as latest (or pre-release)

### Post-Release
- [ ] Local environment cleaned (`git reset --hard HEAD~1`)
- [ ] Release announcement posted
- [ ] Monitoring for issues
- [ ] Next milestone planned
```

## Version History

This section will be maintained as releases are published:

- **v0.1.0** (TBD): Initial public release
  - Lottie animation rendering
  - SwiftUI and UIKit views
  - iOS 13.0+, macOS 10.15+ support

## Emergency Procedures

### Reverting a Bad Release

If a critical issue is discovered immediately after release:

1. **Do NOT delete the tag/release** (breaks SemVer promise)
2. Instead, create an immediate hotfix release
3. Document the issue in GitHub release notes
4. Notify users via announcements

### Security Issues

For security vulnerabilities:

1. **Do NOT publish details publicly before fix is available**
2. Create a private fix
3. Release hotfix as quickly as possible
4. Coordinate disclosure with security best practices
5. Consider creating a SECURITY.md policy

## References

- [Semantic Versioning 2.0.0](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Swift Package Manager Documentation](https://swift.org/package-manager/)
- [GitHub Release Best Practices](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases)

---

**Last Updated**: 2024-11-15
**Maintainers**: @andyf (add maintainer handles)

