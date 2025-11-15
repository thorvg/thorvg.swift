#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting ThorVG Framework build...${NC}"

# Configuration
THORVG_DIR="thorvg"
BUILD_DIR="build"
OUTPUT_DIR="ThorVG.xcframework"
TEMP_DIR="temp_frameworks"
LIB_DIR="lib"

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR"
rm -rf "$OUTPUT_DIR"
rm -rf "$TEMP_DIR"
rm -rf "$LIB_DIR"
mkdir -p "$TEMP_DIR"
mkdir -p "$LIB_DIR"

# Check if meson is installed
if ! command -v meson &> /dev/null; then
    echo -e "${RED}Error: meson is not installed. Please install it with: brew install meson${NC}"
    exit 1
fi

# Check if ninja is installed
if ! command -v ninja &> /dev/null; then
    echo -e "${RED}Error: ninja is not installed. Please install it with: brew install ninja${NC}"
    exit 1
fi

# Dynamically detect SDK paths
echo -e "${YELLOW}Detecting Xcode SDK paths...${NC}"
IPHONEOS_SDK=$(xcrun --show-sdk-path --sdk iphoneos 2>/dev/null || echo "")
IPHONESIMULATOR_SDK=$(xcrun --show-sdk-path --sdk iphonesimulator 2>/dev/null || echo "")

if [ -z "$IPHONEOS_SDK" ] || [ -z "$IPHONESIMULATOR_SDK" ]; then
    echo -e "${RED}Error: Could not find iOS SDKs. Please check your Xcode installation.${NC}"
    exit 1
fi

echo -e "${GREEN}Found iOS SDK: $IPHONEOS_SDK${NC}"
echo -e "${GREEN}Found iOS Simulator SDK: $IPHONESIMULATOR_SDK${NC}"

# Extract Xcode developer directory
XCODE_DEVELOPER_DIR=$(xcode-select -p)
echo -e "${GREEN}Using Xcode at: $XCODE_DEVELOPER_DIR${NC}"

# Meson options for thorvg
MESON_OPTIONS_BASE=(
    -Ddefault_library=static
    -Dloaders=svg,lottie,ttf
    -Dsavers=
    -Dengines=sw
    -Dbindings=capi
    -Dexamples=false
    -Dtests=false
    -Dtools=
    -Dlog=false
    -Dextra=lottie_expressions
    -Dbuildtype=release
    -Dstrip=true
)

# Platform-specific options
# Note: Threads disabled for macOS to avoid OpenMP linking issues with Swift Package Manager
MESON_OPTIONS_MACOS=("${MESON_OPTIONS_BASE[@]}" -Dthreads=false -Dsimd=true)
MESON_OPTIONS_MACOS_X86=("${MESON_OPTIONS_BASE[@]}" -Dthreads=false -Dsimd=false)
MESON_OPTIONS_IOS=("${MESON_OPTIONS_BASE[@]}" -Dthreads=false -Dsimd=false)

# Function to create a temporary cross-compilation file
create_cross_file() {
    local ARCH=$1
    local SDK_PATH=$2
    local PLATFORM=$3
    local OUTPUT_FILE=$4
    local MIN_VERSION="13.0"
    
    # Determine target triple based on platform
    local TARGET_TRIPLE=""
    if [[ "$PLATFORM" == "iphonesimulator" ]]; then
        TARGET_TRIPLE="${ARCH}-apple-ios${MIN_VERSION}-simulator"
    else
        TARGET_TRIPLE="${ARCH}-apple-ios${MIN_VERSION}"
    fi
    
    cat > "$OUTPUT_FILE" << EOF
[binaries]
cpp = ['clang++', '-target', '$TARGET_TRIPLE', '-isysroot', '$SDK_PATH']
ar = 'ar'
strip = 'strip'

[properties]
root = '$XCODE_DEVELOPER_DIR'
has_function_printf = true

[built-in options]
cpp_args = []
cpp_link_args = []

[host_machine]
system = 'darwin'
subsystem = 'ios'
kernel = 'xnu'
cpu_family = '$ARCH'
cpu = '$ARCH'
endian = 'little'
EOF
}

# Function to build for a specific architecture
build_for_platform() {
    local ARCH=$1
    local PLATFORM=$2
    local SDK_PATH=$3
    local BUILD_PATH="${BUILD_DIR}/${PLATFORM}-${ARCH}"
    
    echo -e "${GREEN}Building for ${PLATFORM} ${ARCH}...${NC}"
    
    if [[ "$PLATFORM" == "macosx" ]]; then
        # Native macOS build
        # Disable SIMD for x86_64 to avoid cross-compilation issues
        if [[ "$ARCH" == "x86_64" ]]; then
            meson setup "$BUILD_PATH" "$THORVG_DIR" \
                "${MESON_OPTIONS_MACOS_X86[@]}" \
                -Dcpp_args="-arch $ARCH" \
                -Dcpp_link_args="-arch $ARCH"
        else
            meson setup "$BUILD_PATH" "$THORVG_DIR" \
                "${MESON_OPTIONS_MACOS[@]}" \
                -Dcpp_args="-arch $ARCH" \
                -Dcpp_link_args="-arch $ARCH"
        fi
    else
        # iOS cross-compilation
        local CROSS_FILE="$BUILD_DIR/cross-${PLATFORM}-${ARCH}.txt"
        create_cross_file "$ARCH" "$SDK_PATH" "$PLATFORM" "$CROSS_FILE"
        
        meson setup "$BUILD_PATH" "$THORVG_DIR" \
            "${MESON_OPTIONS_IOS[@]}" \
            --cross-file="$CROSS_FILE"
    fi
    
    meson compile -C "$BUILD_PATH"
    
    echo -e "${GREEN}Successfully built for ${PLATFORM} ${ARCH}${NC}"
}

# Function to create framework structure
create_framework() {
    local PLATFORM=$1
    shift
    local ARCHS=("$@")
    local FRAMEWORK_PATH="${TEMP_DIR}/${PLATFORM}/ThorVG.framework"
    
    # Map platform names to Apple's official platform names
    local PLATFORM_NAME
    case "$PLATFORM" in
        "macosx")
            PLATFORM_NAME="MacOSX"
            ;;
        "iphoneos")
            PLATFORM_NAME="iPhoneOS"
            ;;
        "iphonesimulator")
            PLATFORM_NAME="iPhoneSimulator"
            ;;
    esac
    
    echo -e "${GREEN}Creating framework for ${PLATFORM}...${NC}"
    
    mkdir -p "$FRAMEWORK_PATH/Headers"
    mkdir -p "$FRAMEWORK_PATH/Modules"
    
    # Create fat binary if multiple architectures
    if [ ${#ARCHS[@]} -gt 1 ]; then
        local LIB_PATHS=()
        for ARCH in "${ARCHS[@]}"; do
            LIB_PATHS+=("${BUILD_DIR}/${PLATFORM}-${ARCH}/src/libthorvg.a")
        done
        lipo -create "${LIB_PATHS[@]}" -output "$FRAMEWORK_PATH/ThorVG"
    else
        cp "${BUILD_DIR}/${PLATFORM}-${ARCHS[0]}/src/libthorvg.a" "$FRAMEWORK_PATH/ThorVG"
    fi
    
    # Copy headers
    cp "$THORVG_DIR/src/bindings/capi/thorvg_capi.h" "$FRAMEWORK_PATH/Headers/"
    
    # Create module.modulemap
    cat > "$FRAMEWORK_PATH/Modules/module.modulemap" << EOF
framework module ThorVG {
    umbrella header "thorvg_capi.h"
    export *
    module * { export * }
}
EOF
    
    # Create Info.plist
    cat > "$FRAMEWORK_PATH/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>ThorVG</string>
    <key>CFBundleIdentifier</key>
    <string>org.thorvg.ThorVG</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>ThorVG</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>0.15.16</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>${PLATFORM_NAME}</string>
    </array>
    <key>DTPlatformName</key>
    <string>${PLATFORM}</string>
    <key>MinimumOSVersion</key>
    <string>11.0</string>
</dict>
</plist>
EOF
    
    echo -e "${GREEN}Framework created for ${PLATFORM}${NC}"
}

# Build for all platforms
echo -e "${YELLOW}=== Building for macOS ===${NC}"
build_for_platform "arm64" "macosx" ""
build_for_platform "x86_64" "macosx" ""

echo -e "${YELLOW}=== Building for iOS Device ===${NC}"
build_for_platform "arm64" "iphoneos" "$IPHONEOS_SDK"

echo -e "${YELLOW}=== Building for iOS Simulator ===${NC}"
# Only build arm64 for simulator (Apple Silicon)
# Intel Macs can run arm64 simulator builds via Rosetta 2
build_for_platform "arm64" "iphonesimulator" "$IPHONESIMULATOR_SDK"

# Create frameworks
echo -e "${YELLOW}=== Creating Frameworks ===${NC}"
create_framework "macosx" "arm64" "x86_64"
create_framework "iphoneos" "arm64"
create_framework "iphonesimulator" "arm64"

# Create fat libraries for each platform
echo -e "${YELLOW}=== Creating fat libraries ===${NC}"
mkdir -p "$TEMP_DIR/libs"

# macOS fat library (arm64 + x86_64)
lipo -create \
    "${BUILD_DIR}/macosx-arm64/src/libthorvg.a" \
    "${BUILD_DIR}/macosx-x86_64/src/libthorvg.a" \
    -output "$TEMP_DIR/libs/libthorvg-macos.a"

# iOS device library (arm64 only)
cp "${BUILD_DIR}/iphoneos-arm64/src/libthorvg.a" "$TEMP_DIR/libs/libthorvg-ios.a"

# iOS simulator library (arm64 only)
cp "${BUILD_DIR}/iphonesimulator-arm64/src/libthorvg.a" "$TEMP_DIR/libs/libthorvg-iossimulator.a"

# Create XCFramework manually due to xcodebuild limitations
echo -e "${YELLOW}=== Creating XCFramework manually ===${NC}"
mkdir -p "$OUTPUT_DIR"

# Helper function to create platform-specific directory with modulemap
create_xcframework_slice() {
    local PLATFORM_DIR=$1
    local LIB_PATH=$2
    
    mkdir -p "$PLATFORM_DIR/Headers"
    cp "$LIB_PATH" "$PLATFORM_DIR/libthorvg.a"
    cp "$THORVG_DIR/src/bindings/capi/thorvg_capi.h" "$PLATFORM_DIR/Headers/"
    
    # Create module.modulemap
    cat > "$PLATFORM_DIR/Headers/module.modulemap" << 'MODMAP'
module ThorVG {
    header "thorvg_capi.h"
    export *
}
MODMAP
}

# Create structure for each platform
# macOS
create_xcframework_slice "$OUTPUT_DIR/macos-arm64_x86_64" "$TEMP_DIR/libs/libthorvg-macos.a"

# iOS
create_xcframework_slice "$OUTPUT_DIR/ios-arm64" "$TEMP_DIR/libs/libthorvg-ios.a"

# iOS Simulator
create_xcframework_slice "$OUTPUT_DIR/ios-arm64_x86_64-simulator" "$TEMP_DIR/libs/libthorvg-iossimulator.a"

# Create Info.plist for XCFramework
cat > "$OUTPUT_DIR/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>AvailableLibraries</key>
    <array>
        <dict>
            <key>LibraryIdentifier</key>
            <string>macos-arm64_x86_64</string>
            <key>LibraryPath</key>
            <string>libthorvg.a</string>
            <key>HeadersPath</key>
            <string>Headers</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>arm64</string>
                <string>x86_64</string>
            </array>
            <key>SupportedPlatform</key>
            <string>macos</string>
        </dict>
        <dict>
            <key>LibraryIdentifier</key>
            <string>ios-arm64</string>
            <key>LibraryPath</key>
            <string>libthorvg.a</string>
            <key>HeadersPath</key>
            <string>Headers</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>arm64</string>
            </array>
            <key>SupportedPlatform</key>
            <string>ios</string>
        </dict>
        <dict>
            <key>LibraryIdentifier</key>
            <string>ios-arm64_x86_64-simulator</string>
            <key>LibraryPath</key>
            <string>libthorvg.a</string>
            <key>HeadersPath</key>
            <string>Headers</string>
            <key>SupportedArchitectures</key>
            <array>
                <string>arm64</string>
            </array>
            <key>SupportedPlatform</key>
            <string>ios</string>
            <key>SupportedPlatformVariant</key>
            <string>simulator</string>
        </dict>
    </array>
    <key>CFBundlePackageType</key>
    <string>XFWK</string>
    <key>XCFrameworkFormatVersion</key>
    <string>1.0</string>
</dict>
</plist>
EOF

echo -e "${GREEN}XCFramework created manually at $OUTPUT_DIR${NC}"

# Also create standalone lib directory for macOS-only development
echo -e "${YELLOW}=== Creating standalone library for macOS ===${NC}"
mkdir -p "${LIB_DIR}/include"
lipo -create \
    "${BUILD_DIR}/macosx-arm64/src/libthorvg.a" \
    "${BUILD_DIR}/macosx-x86_64/src/libthorvg.a" \
    -output "${LIB_DIR}/libthorvg.a"
cp "$THORVG_DIR/src/bindings/capi/thorvg_capi.h" "${LIB_DIR}/include/"
cat > "${LIB_DIR}/include/module.modulemap" << EOF
module CThorVG {
    header "thorvg_capi.h"
    export *
}
EOF

# Clean up temporary files
echo -e "${YELLOW}Cleaning up temporary files...${NC}"
rm -rf "$TEMP_DIR"

echo -e "${GREEN}Build complete! 🎉${NC}"
echo -e "${GREEN}XCFramework: ${OUTPUT_DIR}${NC}"
echo -e "${GREEN}Standalone macOS lib: ${LIB_DIR}/libthorvg.a${NC}"

