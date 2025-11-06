# Cross-Compilation Files Explained

## File Structure

```
thorvg/cross/              # Upstream files (not modified)
├── ios_aarch64.txt        # iOS device (arm64) - iOS 13.0 min
├── ios_x86_64.txt         # iOS simulator (x86_64) - iOS 13.0 min
└── (no arm64 simulator)   # Missing!

build_frameworks.sh creates temporary files at build time:
build/
├── cross-iphoneos-arm64.txt           # iOS device - iOS 11.0 min
├── cross-iphonesimulator-arm64.txt    # iOS simulator (arm64) - iOS 11.0 min
└── (created dynamically during build)
```

## Why We Need Different Files

### Device vs Simulator (Both arm64!)

Even though both use arm64 architecture, they are **different platforms**:

| File | SDK | Platform | Use Case |
|------|-----|----------|----------|
| `ios_aarch64.txt` | `iPhoneOS.sdk` | iOS Device | 📱 Real iPhones |
| `ios_simulator_arm64.txt` | `iPhoneSimulator.sdk` | iOS Simulator | 💻 Mac simulator |

**Why they're different:**
- Different system libraries
- Different platform identifiers  
- Different code signing requirements
- Xcode treats them as separate platforms

The misleading comment in `ios_aarch64.txt` says "ios simulator(Mac) & iphone devices" but the SDK path clearly shows it's for **devices only**.

### macOS Native Build

We don't need a cross-compilation file for macOS because:
- We're building ON macOS FOR macOS
- Just use `-arch` flags for universal binary
- No cross-compilation needed

```bash
# Native macOS build in build_frameworks.sh
meson setup "${BUILD_DIR}/arm64" "$THORVG_DIR" \
    -Dcpp_args="-arch arm64"           # Native compilation
```

## iOS Version Minimum

### Upstream (ThorVG Submodule)
```ini
# thorvg/cross/ios_aarch64.txt line 13
cpp_args = ['-miphoneos-version-min=13.0']
```

### Our Build (build_frameworks.sh)
```bash
# Line 85 in build_frameworks.sh
local MIN_VERSION="13.0"

# Generates temporary cross-file with:
cpp_args = ['-miphoneos-version-min=13.0']
```

**Result**: Our XCFramework matches upstream ThorVG at iOS 13.0+.

## SDK Paths

### Upstream (Hardcoded)
```ini
# thorvg/cross/ios_aarch64.txt line 4
-isysroot '/Applications/Xcode-26.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS26.0.sdk'
```

Problems:
- ❌ Hardcoded to Xcode-26
- ❌ Hardcoded to SDK version 26.0
- ❌ Won't work on standard Xcode installations

### Our Build (Dynamic)
```bash
# Lines 46-54 in build_frameworks.sh
IPHONEOS_SDK=$(xcrun --show-sdk-path --sdk iphoneos)
IPHONESIMULATOR_SDK=$(xcrun --show-sdk-path --sdk iphonesimulator)
XCODE_DEVELOPER_DIR=$(xcode-select -p)
```

Benefits:
- ✅ Automatically finds current Xcode
- ✅ Works with any SDK version
- ✅ Works with renamed Xcode installations

## Why Not Modify Upstream Files?

### Current Approach: Temporary Files

**Pros:**
- ✅ No modifications to submodule
- ✅ Easier to update thorvg (no merge conflicts)
- ✅ Dynamic SDK detection
- ✅ Full control over iOS version
- ✅ Clean git status in submodule

**Cons:**
- ⚠️ Upstream files are misleading (comment says simulator but targets device)
- ⚠️ Upstream files have hardcoded paths that won't work for everyone

### Alternative: Modify Upstream Files

If you wanted to modify the upstream files instead:

1. **Fix misleading comment**:
```diff
- # build for the ios simulator(Mac) & iphone devices
+ # build for iphone devices (arm64)
```

2. **Lower iOS minimum**:
```diff
- cpp_args = ['-miphoneos-version-min=13.0']
+ cpp_args = ['-miphoneos-version-min=11.0']
```

3. **Add missing simulator file**:
```bash
# Create thorvg/cross/ios_simulator_arm64.txt
# (Our build script creates this temporarily, but it's not in upstream)
```

4. **Propose dynamic SDK detection**:
This would require changes to how Meson processes cross-files, so it's more complex.

## For iOS-Only Distribution

If you want to create a smaller XCFramework for iOS-only apps:

```bash
# Edit build_frameworks.sh - comment out macOS builds:
# Build for all platforms
echo -e "${YELLOW}=== Building for macOS ===${NC}"
# build_for_platform "arm64" "macosx" ""      # COMMENT OUT
# build_for_platform "x86_64" "macosx" ""     # COMMENT OUT

# Then update the XCFramework creation to skip macOS slice
```

**Result**: XCFramework would be ~3 MB instead of ~6 MB

**But**: Xcode already strips unused platforms from final app, so this only helps with:
- Package download size
- Git repository size
- Distribution bandwidth

## Binary Size Breakdown

| Component | Size | Included in App |
|-----------|------|-----------------|
| macOS (arm64 + x86_64) | ~2.9 MB | ❌ Not on iOS |
| iOS Device (arm64) | ~1.5 MB | ✅ Device builds only |
| iOS Simulator (arm64) | ~1.5 MB | ✅ Simulator builds only |
| **XCFramework Total** | **~6 MB** | N/A |
| **Final iOS App** | **~1.5 MB** | ✅ Auto-selected |

When Xcode builds your iOS app, it automatically:
1. Detects the target platform (device or simulator)
2. Extracts only the relevant slice from the XCFramework
3. Links only that slice into your app binary
4. Discards the other platforms

## Summary

✅ **Current approach is good** - temporary files give us:
- iOS 11.0 minimum (vs upstream's 13.0)
- Dynamic Xcode detection (vs upstream's hardcoded paths)
- Apple Silicon simulator support (missing in upstream)
- No modifications to the submodule

❓ **Potential upstream contributions**:
- Fix misleading comment in `ios_aarch64.txt`
- Add `ios_simulator_arm64.txt` for Apple Silicon simulators
- Lower iOS minimum to 11.0 (if they agree it's useful)
- Document the dynamic SDK detection approach

📦 **Binary size**: Don't worry! iOS apps only include the relevant platform slice (~1.5 MB), not the full XCFramework (~6 MB).

