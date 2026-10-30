#!/usr/bin/env bash
# ==============================================================================
# Job Hunterr iOS - Automated Build & Archive Script (macOS / Xcode CLI)
# ==============================================================================

set -e

# Configuration
WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="JobHunterriOS.xcodeproj"
SCHEME_NAME="JobHunterr"
CONFIGURATION="Release"
BUILD_DIR="${WORKSPACE_DIR}/build"
ARCHIVE_PATH="${BUILD_DIR}/Jobhunterr.xcarchive"
EXPORT_PATH="${BUILD_DIR}/Export"
EXPORT_OPTIONS_PLIST="${WORKSPACE_DIR}/ExportOptions.plist"

# Color formatting
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================================================${NC}"
echo -e "${BLUE}           JOB HUNTERR - iOS BUILD & ARCHIVE AUTOMATION           ${NC}"
echo -e "${BLUE}==================================================================${NC}"

# Check for macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}[ERROR] This build script must be run on macOS with Xcode installed.${NC}"
    echo -e "${YELLOW}Windows environment detected. Source code and Xcode configuration are ready.${NC}"
    echo -e "${YELLOW}Please transfer this directory to your Mac or CI/CD runner to compile.${NC}"
    exit 1
fi

# Check for Xcode command line tools
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}[ERROR] xcodebuild command not found. Please install Xcode and Command Line Tools.${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Select an action:${NC}"
echo "1) Build and run on iOS Simulator"
echo "2) Build Release Archive (.xcarchive)"
echo "3) Build and Export IPA for TestFlight / App Store"
echo "4) Clean build folder"
echo "5) Exit"
read -p "Enter choice [1-5]: " choice

case $choice in
    1)
        SIM_DEST=$(xcrun simctl list devices available 2>/dev/null | grep -E "iPhone (16|15|14)" | head -n 1 | sed -E 's/.*\(([-0-9A-F]+)\).*/id=\1/' || echo "generic/platform=iOS Simulator")
        echo -e "\n${BLUE}--> Building for iOS Simulator (${SIM_DEST})...${NC}"
        xcodebuild -project "${WORKSPACE_DIR}/${PROJECT_NAME}" \
                   -scheme "${SCHEME_NAME}" \
                   -configuration Debug \
                   -destination "${SIM_DEST}" \
                   clean build
        echo -e "${GREEN}✓ Simulator build succeeded!${NC}"
        ;;
    2)
        echo -e "\n${BLUE}--> Creating Release Archive...${NC}"
        mkdir -p "${BUILD_DIR}"
        xcodebuild -project "${WORKSPACE_DIR}/${PROJECT_NAME}" \
                   -scheme "${SCHEME_NAME}" \
                   -configuration "${CONFIGURATION}" \
                   -archivePath "${ARCHIVE_PATH}" \
                   archive
        echo -e "${GREEN}✓ Release archive created at: ${ARCHIVE_PATH}${NC}"
        ;;
    3)
        echo -e "\n${BLUE}--> Creating Release Archive...${NC}"
        mkdir -p "${BUILD_DIR}"
        xcodebuild -project "${WORKSPACE_DIR}/${PROJECT_NAME}" \
                   -scheme "${SCHEME_NAME}" \
                   -configuration "${CONFIGURATION}" \
                   -archivePath "${ARCHIVE_PATH}" \
                   archive

        echo -e "\n${BLUE}--> Exporting IPA package...${NC}"
        xcodebuild -exportArchive \
                   -archivePath "${ARCHIVE_PATH}" \
                   -exportPath "${EXPORT_PATH}" \
                   -exportOptionsPlist "${EXPORT_OPTIONS_PLIST}"
        
        echo -e "${GREEN}✓ IPA successfully generated at: ${EXPORT_PATH}/Jobhunterr.ipa${NC}"
        ;;
    4)
        echo -e "\n${BLUE}--> Cleaning build directory...${NC}"
        rm -rf "${BUILD_DIR}"
        xcodebuild -project "${WORKSPACE_DIR}/${PROJECT_NAME}" \
                   -scheme "${SCHEME_NAME}" \
                   clean
        echo -e "${GREEN}✓ Clean complete.${NC}"
        ;;
    5)
        echo "Exiting."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice.${NC}"
        exit 1
        ;;
esac
