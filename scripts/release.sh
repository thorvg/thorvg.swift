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
    echo -e "${YELLOW}Usage: ./scripts/release.sh <version>${NC}"
    echo -e "${YELLOW}Example: ./scripts/release.sh 0.1.0${NC}"
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
if [ ! -f "./scripts/build_frameworks.sh" ]; then
    echo -e "${RED}Error: scripts/build_frameworks.sh not found${NC}"
    exit 1
fi

./scripts/build_frameworks.sh

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

# Create tag message with link to release notes
TAG_MESSAGE="Release ${VERSION}

See the full release notes and changelog at:
https://github.com/thorvg/thorvg.swift/releases/tag/${TAG_NAME}

Installation:
Add to your Package.swift:
.package(url: \"https://github.com/thorvg/thorvg.swift\", from: \"${VERSION}\")
"

git tag -a "$TAG_NAME" -m "$TAG_MESSAGE"

echo -e "${GREEN}✓ Tag ${TAG_NAME} created${NC}"
echo ""

# Instructions for next steps
echo -e "${YELLOW}Step 4/4: Next steps${NC}"
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Release ${TAG_NAME} prepared successfully! 🎉                    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${RED}⚠️  IMPORTANT: You must push the tag to GitHub to complete the release!${NC}"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Step 1: Push the tag to GitHub${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${YELLOW}git push origin ${TAG_NAME}${NC}"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Step 2: Create GitHub release${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Open: ${YELLOW}https://github.com/thorvg/thorvg.swift/releases/new?tag=${TAG_NAME}${NC}"
echo ""
echo -e "  Title: ${YELLOW}ThorVGSwift ${TAG_NAME} - [Your Release Title]${NC}"
echo -e "  Description: Copy from ${YELLOW}RELEASE_NOTES_GITHUB_v${VERSION}.md${NC} (if it exists)"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Step 3: Clean up your local environment${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  After creating the GitHub release, remove the XCFramework from your working tree:"
echo ""
echo -e "  ${YELLOW}git reset --hard HEAD~1${NC}"
echo ""
echo -e "  This keeps your main branch lightweight (XCFramework only exists in the tag)."
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}To undo this release (before pushing):${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${YELLOW}git tag -d ${TAG_NAME}${NC}              # Delete local tag"
echo -e "  ${YELLOW}git reset --hard HEAD~1${NC}        # Remove release commit"
echo ""

