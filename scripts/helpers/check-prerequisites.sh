#!/bin/bash

################################################################################
# check-prerequisites.sh - WSL Prerequisites Checker
################################################################################
# This script verifies that the system meets all prerequisites for installing
# AI CLI tools in WSL/Ubuntu. It checks:
#   - WSL environment detection
#   - Ubuntu version compatibility
#   - Internet connection
#   - sudo privileges
#   - Essential tools availability
#
# Exit Codes:
#   0 - All prerequisites met
#   1 - One or more prerequisites failed
#
# Author: AI CLI Setup Project
# Version: 1.0
# Last Updated: 2025-11-03
################################################################################

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly GRAY='\033[0;90m'
readonly NC='\033[0m' # No Color

# Track check results
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}========================================${NC}\n"
}

print_check() {
    echo -e "${CYAN}[$1] $2${NC}"
}

print_pass() {
    echo -e "${GREEN}  ✓ $1${NC}"
    ((PASSED_CHECKS++))
}

print_fail() {
    echo -e "${RED}  ✗ $1${NC}"
    ((FAILED_CHECKS++))
}

print_warn() {
    echo -e "${YELLOW}  ⚠ $1${NC}"
    ((WARNINGS++))
}

print_detail() {
    echo -e "${GRAY}      $1${NC}"
}

################################################################################
# Check Functions
################################################################################

check_wsl_environment() {
    print_check "1/6" "Checking WSL environment..."

    # Check if running in WSL
    if grep -qi microsoft /proc/version 2>/dev/null; then
        print_pass "Running in WSL"

        # Try to get WSL version
        if grep -qi "WSL2" /proc/version 2>/dev/null; then
            print_detail "WSL 2 detected"
        else
            print_detail "WSL detected (version could be WSL 1 or 2)"
        fi
        return 0
    else
        # Check if it's a Linux system
        if [[ -f /etc/os-release ]]; then
            print_warn "Not running in WSL, but Linux detected"
            print_detail "This script is designed for WSL but may work on native Linux"
            return 0
        else
            print_fail "Not running in WSL or Linux environment"
            return 1
        fi
    fi
}

check_ubuntu_version() {
    print_check "2/6" "Checking Ubuntu version..."

    if [[ -f /etc/os-release ]]; then
        # Source the os-release file to get distribution info
        . /etc/os-release

        if [[ "$ID" == "ubuntu" ]]; then
            # Extract version number
            VERSION_NUM=$(echo "$VERSION_ID" | cut -d. -f1)

            # Require Ubuntu 20.04 or higher
            if [[ "$VERSION_NUM" -ge 20 ]]; then
                print_pass "Ubuntu version compatible"
                print_detail "$PRETTY_NAME"
                return 0
            else
                print_fail "Ubuntu version too old (requires 20.04+)"
                print_detail "Current: $PRETTY_NAME"
                return 1
            fi
        else
            print_warn "Not Ubuntu, detected: $PRETTY_NAME"
            print_detail "Script designed for Ubuntu but may work on other Debian-based distros"
            return 0
        fi
    else
        print_fail "Cannot determine OS version"
        return 1
    fi
}

check_internet_connection() {
    print_check "3/6" "Checking internet connection..."

    # Try to ping a reliable DNS server
    if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        print_pass "Internet connected"
        return 0
    else
        # Try alternate method - DNS resolution
        if getent hosts google.com >/dev/null 2>&1; then
            print_pass "Internet connected"
            return 0
        else
            print_fail "No internet connection detected"
            print_detail "Installation requires internet access"
            return 1
        fi
    fi
}

check_sudo_privileges() {
    print_check "4/6" "Checking sudo privileges..."

    # Check if user can run sudo
    if sudo -n true 2>/dev/null; then
        print_pass "sudo available without password"
        return 0
    elif sudo -v 2>/dev/null; then
        print_pass "sudo available (may require password)"
        return 0
    else
        print_fail "sudo not available or user lacks privileges"
        print_detail "Installation requires sudo access"
        return 1
    fi
}

check_disk_space() {
    print_check "5/6" "Checking disk space..."

    # Get available space in MB
    AVAILABLE_MB=$(df -BM / | awk 'NR==2 {print $4}' | sed 's/M//')

    # Require at least 2GB free space
    if [[ "$AVAILABLE_MB" -ge 2048 ]]; then
        print_pass "Sufficient disk space available"
        print_detail "Available: ${AVAILABLE_MB} MB"
        return 0
    elif [[ "$AVAILABLE_MB" -ge 1024 ]]; then
        print_warn "Low disk space"
        print_detail "Available: ${AVAILABLE_MB} MB (2GB+ recommended)"
        return 0
    else
        print_fail "Insufficient disk space"
        print_detail "Available: ${AVAILABLE_MB} MB (requires 2GB+)"
        return 1
    fi
}

check_essential_tools() {
    print_check "6/6" "Checking essential tools..."

    local ALL_FOUND=true

    # Check for curl
    if command -v curl >/dev/null 2>&1; then
        print_detail "curl: found"
    else
        print_detail "curl: missing (will be installed)"
        ALL_FOUND=false
    fi

    # Check for wget
    if command -v wget >/dev/null 2>&1; then
        print_detail "wget: found"
    else
        print_detail "wget: missing (will be installed)"
        ALL_FOUND=false
    fi

    # Check for git
    if command -v git >/dev/null 2>&1; then
        GIT_VERSION=$(git --version)
        print_detail "git: $GIT_VERSION"
    else
        print_detail "git: missing (will be installed)"
        ALL_FOUND=false
    fi

    if $ALL_FOUND; then
        print_pass "All essential tools found"
    else
        print_warn "Some tools missing (will be installed during setup)"
    fi

    return 0
}

################################################################################
# Main Execution
################################################################################

main() {
    print_header "Prerequisites Check for WSL/Ubuntu"

    # Run all checks
    check_wsl_environment || true
    check_ubuntu_version || true
    check_internet_connection || true
    check_sudo_privileges || true
    check_disk_space || true
    check_essential_tools || true

    # Print summary
    print_header "Summary"

    echo -e "${GRAY}Passed:  ${NC}${GREEN}${PASSED_CHECKS}${NC}"
    echo -e "${GRAY}Failed:  ${NC}${RED}${FAILED_CHECKS}${NC}"
    echo -e "${GRAY}Warnings: ${NC}${YELLOW}${WARNINGS}${NC}"
    echo ""

    # Determine exit status
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        echo -e "${GREEN}✓ All prerequisites met!${NC}"
        echo -e "${GREEN}  You can proceed with installation.${NC}\n"
        return 0
    else
        echo -e "${RED}✗ Some prerequisites are not met.${NC}"
        echo -e "${YELLOW}  Please resolve these issues before continuing.${NC}\n"
        return 1
    fi
}

# Run main function
main
exit $?
