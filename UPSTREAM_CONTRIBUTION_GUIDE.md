# Upstream Contribution Guide for ThorVG

This guide outlines potential contributions to the ThorVG repository based on the work done for the Swift package.

## Current iOS Build Support in ThorVG

ThorVG already has iOS build support via [GitHub Actions](https://github.com/thorvg/thorvg/blob/main/.github/workflows/build_ios.yml). However, it's incomplete for our needs:

**What exists:**
- ✅ Builds for `ios_x86_64` (Intel simulator)
- ✅ Builds for `ios_arm64` (device)
- ✅ Uses Meson with `-Dstatic=true`

**What's missing:**
- ❌ No `ios_simulator_arm64` (Apple Silicon simulator)
- ❌ No XCFramework creation
- ❌ Individual artifacts, not combined
- ❌ No module maps for Swift integration

## Files to Review in ThorVG Submodule

```bash
cd thorvg
git status
```

You'll see:
- **Modified**: `cross/ios_aarch64.txt`, `cross/ios_x86_64.txt`
- **Untracked**: `cross/ios_simulator_arm64.txt`
- **Untracked**: `src/renderer/config.h` (build artifact, ignore)

## Proposed Contributions

### 1. Add iOS Simulator Apple Silicon Support (HIGH PRIORITY)

**File**: `thorvg/cross/ios_simulator_arm64.txt` (NEW)

**Why**: This file doesn't exist in upstream ThorVG but is essential for building on Apple Silicon simulators.

**Proposed Content** (with dynamic SDK detection):
```ini
# build for the ios simulator on Apple Silicon

[binaries]
cpp = ['clang++', '-arch', 'arm64', '-isysroot', '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk']
ar = 'ar'
strip = 'strip'

[properties]
root = '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer'
has_function_printf = true

[built-in options]
cpp_args = ['-miphoneos-version-min=11.0']
cpp_link_args = ['-miphoneos-version-min=11.0']

[host_machine]
system = 'darwin'
subsystem = 'ios'
kernel = 'xnu'
cpu_family = 'aarch64'
cpu = 'aarch64'
endian = 'little'
```

**Note**: The SDK path is hardcoded here. You may want to propose a mechanism for dynamic detection.

### 2. ~~Lower iOS Minimum Version~~ (NOT NEEDED)

**Status**: We now match upstream at iOS 13.0

The upstream default of iOS 13.0 is appropriate because:
- iOS 13+ represents >99% of active devices
- Most modern apps target iOS 13+ anyway
- No practical benefit to supporting older versions for a rendering library

### 3. Update Cross-Compilation Files for Modern Xcode (LOW PRIORITY)

**Issue**: Current cross-compilation files may reference older SDK versions.

**Proposed**: Add comments or documentation about:
1. How to update SDK paths for different Xcode versions
2. Using `xcrun --show-sdk-path` to find the correct paths
3. Handling renamed Xcode installations

**Example Documentation**:
```
# Finding your SDK path:
# xcrun --show-sdk-path --sdk iphoneos
# xcrun --show-sdk-path --sdk iphonesimulator

# For renamed Xcode installations, use xcode-select:
# sudo xcode-select -s /Applications/Xcode-26.app/Contents/Developer
```

### 4. Document iOS Build Limitations (HIGH PRIORITY)

**Location**: `README.md` or `docs/` folder in ThorVG

**Topics to Cover**:

#### a. SIMD Must Be Disabled for iOS
```bash
# When building for iOS with Meson:
-Dsimd=false

# Why: Meson incorrectly adds -mfpu=neon for arm64, 
# which is an ARM32 flag and causes build errors
```

#### b. Threading Must Be Disabled for iOS
```bash
# When building for iOS with Meson:
-Dthreads=false

# Why: iOS doesn't use pthread as a separate library;
# threading is built into the system libraries
```

#### c. PNG/JPG Loaders Have External Dependencies
```bash
# Avoid for iOS unless you handle the dependencies:
-Dloaders=svg,tvg,lottie,ttf  # Safe for iOS
-Dloaders=png,jpg              # Requires external libs
```

### 5. Update GitHub Actions Workflow (MEDIUM PRIORITY)

**File**: `.github/workflows/build_ios.yml`

**Proposed Changes:**
```yaml
# Add a job for iOS Simulator arm64
build_arm64_simulator:
  runs-on: macos-latest
  steps:
  - uses: actions/checkout@v4
    with:
      submodules: true
  
  - name: Install Packages
    run: |
      export HOMEBREW_NO_INSTALL_FROM_API=1
      brew update
      brew install meson
  
  - name: Build
    run: |
      meson setup build -Dlog=true -Dloaders=all -Dsavers=all -Dbindings=capi -Ddefault_library=static --cross-file ./cross/ios_simulator_arm64.txt
      ninja -C build install
  
  - uses: actions/upload-artifact@v4
    with:
      name: result_arm64_simulator
      path: build/src/libthorvg*
```

**Note**: The workflow uses `-Dstatic=true` which is deprecated. Should be `-Ddefault_library=static`.

### 6. Add Example iOS Build Script (LOW PRIORITY)

**Location**: `examples/ios_build.sh` or similar

**Content**: A simplified version of `build_frameworks.sh` that demonstrates:
- Building for iOS device
- Building for iOS simulator
- Using cross-compilation files
- Recommended Meson options for iOS

## Preparing Your Contribution

### Step 1: Create a Clean Branch
```bash
cd thorvg
git checkout -b ios-improvements
```

### Step 2: Review Your Changes
```bash
git diff cross/ios_aarch64.txt
git diff cross/ios_x86_64.txt
```

### Step 3: Stage the Changes
```bash
# Add the new simulator file
git add cross/ios_simulator_arm64.txt

# Add the modified cross-compilation files (if you want to propose version changes)
git add cross/ios_aarch64.txt cross/ios_x86_64.txt
```

### Step 4: Important Considerations

#### SDK Path Hardcoding
The current implementation uses hardcoded Xcode paths. Consider:

**Option A**: Keep hardcoded paths with clear documentation
- Pros: Simple, works out of the box for most users
- Cons: May break with renamed Xcode installations

**Option B**: Propose a Meson variable/option for SDK paths
- Pros: More flexible, works with any Xcode installation
- Cons: Requires Meson build system changes

#### Version Numbers
Your changes reference specific versions:
- **Xcode**: 26.0 (likely a beta)
- **iOS SDK**: 26.0 (likely a beta)

For upstream contribution, you may want to:
1. Update to stable versions (e.g., 15.0, 16.0)
2. Add comments about updating these versions
3. Propose a way to make these configurable

### Step 5: Test Your Changes

Before submitting, test the cross-compilation files:
```bash
cd thorvg

# Test iOS device build
meson setup build-ios-device . \
    --cross-file=cross/ios_aarch64.txt \
    -Ddefault_library=static \
    -Dengines=sw \
    -Dsimd=false \
    -Dthreads=false \
    -Dloaders=svg,tvg,lottie,ttf
meson compile -C build-ios-device

# Test iOS simulator build  
meson setup build-ios-sim . \
    --cross-file=cross/ios_simulator_arm64.txt \
    -Ddefault_library=static \
    -Dengines=sw \
    -Dsimd=false \
    -Dthreads=false \
    -Dloaders=svg,tvg,lottie,ttf
meson compile -C build-ios-sim
```

### Step 6: Commit and Push
```bash
git commit -m "Add iOS Simulator arm64 support and improve iOS cross-compilation

- Add ios_simulator_arm64.txt for Apple Silicon simulator builds
- Update iOS minimum version to 11.0 (from 13.0)
- Update SDK paths for modern Xcode versions
- Add documentation for iOS-specific build requirements"

git push origin ios-improvements
```

### Step 7: Create Pull Request

Go to the ThorVG repository and create a pull request with:

**Title**: "Improve iOS cross-compilation support"

**Description**:
```markdown
This PR enhances iOS support for ThorVG:

## Changes
1. **Add Apple Silicon simulator support** - New `ios_simulator_arm64.txt` file
2. **Lower iOS minimum version** - Change from 13.0 to 11.0 (no breaking changes)
3. **Update SDK paths** - Support for modern Xcode versions

## Testing
Tested on:
- macOS with Xcode 16
- iOS device (arm64)
- iOS Simulator (arm64)

## Notes
- SIMD must be disabled for iOS (Meson limitation)
- Threading must be disabled for iOS (no separate pthread lib)

## Related Issues
Fixes #XXX (if there's an existing issue)
```

## Alternative: Start with Documentation

If you're not ready to propose code changes, consider starting with documentation:

1. **Create an issue** describing iOS build challenges
2. **Share your build script** as a reference
3. **Document workarounds** for SIMD and threading issues
4. **Gather feedback** before proposing changes

## Questions to Ask Upstream

Before contributing, you might want to ask:

1. **Is there interest in iOS 11 support?** (vs keeping 13.0 minimum)
2. **Would you accept a build script for iOS XCFramework creation?**
3. **Are there plans to fix the SIMD detection for iOS arm64?**
4. **Should cross-compilation files use absolute or relative SDK paths?**

## Summary

**High Value Contributions**:
1. ✅ `ios_simulator_arm64.txt` file (NEW) - Fill a gap in platform support
2. ✅ iOS build documentation - Help future developers

**Medium Value Contributions**:
1. 📝 iOS version changes (11.0 vs 13.0) - Depends on project policy
2. 📝 SDK path updates - May need project-wide discussion

**Nice to Have**:
1. 💡 Example iOS build script
2. 💡 XCFramework creation documentation

---

**Remember**: The ThorVG maintainers may have specific preferences or policies. Start with a discussion or issue before investing time in a large PR.

