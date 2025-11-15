# Scripts

This directory contains build and release automation scripts for ThorVGSwift.

## Available Scripts

### build_frameworks.sh

**Purpose**: Builds the ThorVG XCFramework for all supported platforms.

**Usage**:
```bash
./scripts/build_frameworks.sh
```

**What it does**:
1. Detects your Xcode installation and SDK paths automatically
2. Builds ThorVG static libraries for:
   - macOS (arm64 + x86_64)
   - iOS Device (arm64)
   - iOS Simulator (arm64)
3. Creates `ThorVG.xcframework` with all platform binaries
4. Generates standalone macOS library in `lib/` for local development

**Requirements**:
- Xcode with command-line tools
- Meson build system: `brew install meson`
- Ninja build tool: `brew install ninja`

**When to use**:
- Setting up the project for local development
- After updating the ThorVG submodule
- Testing XCFramework changes

**Outputs**:
- `ThorVG.xcframework/` - Multi-platform XCFramework (gitignored)
- `lib/libthorvg.a` - Standalone macOS library (gitignored)
- `build/` - Intermediate build artifacts (gitignored)

---

### release.sh

**Purpose**: Automates the release process with pre-built XCFramework binaries.

**Usage**:
```bash
./scripts/release.sh <version>
```

**Example**:
```bash
./scripts/release.sh 0.1.0
```

**What it does**:
1. Validates version format (semantic versioning)
2. Checks for uncommitted changes
3. Verifies tag doesn't already exist
4. Builds XCFramework using `build_frameworks.sh`
5. Creates release commit (with XCFramework force-added)
6. Creates annotated git tag
7. Provides instructions for pushing and creating GitHub release

**Requirements**:
- Clean working directory (no uncommitted changes)
- Version number in semantic versioning format (X.Y.Z)
- All prerequisites for `build_frameworks.sh`

**When to use**:
- Creating a new release
- Publishing a version with pre-built binaries

**Post-release cleanup**:
```bash
# After pushing the tag, reset to remove XCFramework from working tree
git reset --hard HEAD~1
```

**See also**: [docs/RELEASE_POLICY.md](../docs/RELEASE_POLICY.md) for complete release guidelines.

---

## Development Notes

### Script Locations
All build and release scripts are located in this `scripts/` directory to keep the project root clean and organized.

### Permissions
Both scripts are executable and should remain so. If you need to restore execute permissions:
```bash
chmod +x scripts/*.sh
```

### Customization
If you need to modify build configurations:
- **Platform support**: Edit `build_frameworks.sh` to add/remove architectures
- **Release process**: Edit `release.sh` for custom release workflows
- **Build options**: Adjust `MESON_OPTIONS_BASE` in `build_frameworks.sh`

### Troubleshooting

**Build fails with SDK not found**:
- Verify Xcode is installed: `xcode-select -p`
- Install command-line tools: `xcode-select --install`

**Meson/Ninja not found**:
- Install via Homebrew: `brew install meson ninja`

**Release script fails**:
- Ensure working directory is clean: `git status`
- Verify you're on the main branch: `git branch`
- Check tag doesn't exist: `git tag -l`

For more detailed troubleshooting, see [docs/BUILD_SYSTEM.md](../docs/BUILD_SYSTEM.md).

## Contributing

When modifying these scripts:
1. Test thoroughly on both Intel and Apple Silicon Macs if possible
2. Update this README if adding new scripts or changing behavior
3. Ensure scripts remain POSIX-compatible for maximum portability
4. Add appropriate error handling and validation

## References

- [Build System Documentation](../docs/BUILD_SYSTEM.md)
- [Release Policy](../docs/RELEASE_POLICY.md)
- [Contributing Guide](../docs/CONTRIBUTING.md)

