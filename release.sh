#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   ThorVG Swift Release Build Script   ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo ""

# Check if version argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Version number required${NC}"
    echo -e "${YELLOW}Usage: ./release.sh <version>${NC}"
    echo -e "${YELLOW}Example: ./release.sh 0.1.0${NC}"
    exit 1
fi

VERSION=$1
TAG_NAME="v${VERSION}"

# Validate version format (basic check for semantic versioning)
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Error: Invalid version format. Please use semantic versioning (e.g., 0.1.0)${NC}"
    exit 1
fi

echo -e "${GREEN}Preparing release ${TAG_NAME}${NC}"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Check for uncommitted changes (excluding the XCFramework)
if ! git diff --quiet --exit-code -- . ':!ThorVG.xcframework'; then
    echo -e "${RED}Error: You have uncommitted changes. Please commit or stash them first.${NC}"
    git status --short
    exit 1
fi

# Check if tag already exists
if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
    echo -e "${RED}Error: Tag ${TAG_NAME} already exists${NC}"
    exit 1
fi

# Build the XCFramework
echo -e "${YELLOW}Step 1/4: Building XCFramework...${NC}"
if [ ! -f "./build_frameworks.sh" ]; then
    echo -e "${RED}Error: build_frameworks.sh not found${NC}"
    exit 1
fi

./build_frameworks.sh

# Verify XCFramework was created
if [ ! -d "ThorVG.xcframework" ]; then
    echo -e "${RED}Error: XCFramework build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ XCFramework built successfully${NC}"
echo ""

# Calculate XCFramework size
XCFRAMEWORK_SIZE=$(du -sh ThorVG.xcframework | cut -f1)
echo -e "${BLUE}XCFramework size: ${XCFRAMEWORK_SIZE}${NC}"
echo ""

# Create release commit
echo -e "${YELLOW}Step 2/4: Creating release commit...${NC}"

# Temporarily force-add the XCFramework (it's in .gitignore)
git add -f ThorVG.xcframework/

# Create release commit
git commit -m "Release ${TAG_NAME}

- Built XCFramework for distribution
- Version: ${VERSION}"

echo -e "${GREEN}✓ Release commit created${NC}"
echo ""

# Create annotated tag
echo -e "${YELLOW}Step 3/4: Creating git tag...${NC}"
git tag -a "$TAG_NAME" -m "Release ${VERSION}

This release includes:
- Pre-built ThorVG XCFramework
- Swift wrapper for ThorVG
- Support for iOS 13.0+ and macOS 10.15+

To use this release, add to your Package.swift:
.package(url: \"https://github.com/thorvg/thorvg.swift\", from: \"${VERSION}\")
"

echo -e "${GREEN}✓ Tag ${TAG_NAME} created${NC}"
echo ""

# Instructions for pushing
echo -e "${YELLOW}Step 4/4: Next steps${NC}"
echo ""
echo -e "${GREEN}Release prepared successfully! 🎉${NC}"
echo ""
echo -e "${BLUE}To publish this release:${NC}"
echo -e "  1. Push the tag to GitHub:"
echo -e "     ${YELLOW}git push origin ${TAG_NAME}${NC}"
echo ""
echo -e "  2. Create a GitHub release from the tag:"
echo -e "     ${YELLOW}https://github.com/thorvg/thorvg.swift/releases/new?tag=${TAG_NAME}${NC}"
echo ""
echo -e "  3. In the release notes, describe the changes and features"
echo ""
echo -e "${BLUE}To undo this release (if needed):${NC}"
echo -e "  ${YELLOW}git tag -d ${TAG_NAME}${NC}"
echo -e "  ${YELLOW}git reset --hard HEAD~1${NC}"
echo ""
echo -e "${BLUE}Note:${NC} The XCFramework will only exist in the tagged commit."
echo -e "After pushing the tag, you can clean it from your working directory:"
echo -e "  ${YELLOW}git reset --hard HEAD~1${NC} (moves back before the release commit)"
echo ""

