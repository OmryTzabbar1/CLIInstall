#!/bin/bash

################################################################################
# verify-installation.sh - Verify AI CLI Tools Installation (WSL/Ubuntu)
################################################################################
# This script checks that all components were installed correctly:
#   - Node.js and npm
#   - Git
#   - Python 3 and pip
#   - UV package manager
#   - Claude Code accessibility via npx
#   - API keys configuration
#   - Shell environment configuration
#
# Exit Codes:
#   0 - All checks passed
#   1 - One or more checks failed
#
# Author: AI CLI Setup Project
# Version: 1.0
# Last Updated: 2025-11-03
################################################################################

set -euo pipefail

################################################################################
# Configuration
################################################################################

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly GRAY='\033[0;90m'
readonly NC='\033[0m'

# Track results
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

################################################################################
# Helper Functions
################################################################################

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_result() {
    local status="$1"
    local component="$2"
    local message="$3"
    local details="${4:-}"

    case "$status" in
        PASS)
            echo -e "${GREEN}  ✓ $component${NC} ${GRAY}- $message${NC}"
            [[ -n "$details" ]] && echo -e "${GRAY}      $details${NC}"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
            ;;
        FAIL)
            echo -e "${RED}  ✗ $component${NC} ${GRAY}- $message${NC}"
            [[ -n "$details" ]] && echo -e "${GRAY}      $details${NC}"
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            ;;
        WARN)
            echo -e "${YELLOW}  ⚠ $component${NC} ${GRAY}- $message${NC}"
            [[ -n "$details" ]] && echo -e "${GRAY}      $details${NC}"
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
            ;;
    esac
}

################################################################################
# Verification Functions
################################################################################

verify_nodejs() {
    echo -e "\n${CYAN}[Node.js Verification]${NC}"

    if command_exists node; then
        local node_version
        node_version=$(node --version 2>&1)

        if [[ $? -eq 0 ]]; then
            print_result PASS "Node.js" "Installed and working" "Version: $node_version"
            return 0
        else
            print_result FAIL "Node.js" "Command exists but not responding correctly"
            return 1
        fi
    else
        print_result FAIL "Node.js" "Not found in PATH"
        return 1
    fi
}

verify_npm() {
    echo -e "\n${CYAN}[npm Verification]${NC}"

    if command_exists npm; then
        local npm_version
        npm_version=$(npm --version 2>&1)

        if [[ $? -eq 0 ]]; then
            print_result PASS "npm" "Installed and working" "Version: $npm_version"

            # Also check npx
            if command_exists npx; then
                local npx_version
                npx_version=$(npx --version 2>&1)
                print_result PASS "npx" "Available" "Version: $npx_version"
            else
                print_result WARN "npx" "Not found (usually comes with npm)"
            fi

            return 0
        else
            print_result FAIL "npm" "Command exists but not responding correctly"
            return 1
        fi
    else
        print_result FAIL "npm" "Not found in PATH"
        return 1
    fi
}

verify_git() {
    echo -e "\n${CYAN}[Git Verification]${NC}"

    if command_exists git; then
        local git_version
        git_version=$(git --version 2>&1)

        if [[ $? -eq 0 ]]; then
            print_result PASS "Git" "Installed and working" "$git_version"
            return 0
        else
            print_result FAIL "Git" "Command exists but not responding correctly"
            return 1
        fi
    else
        print_result FAIL "Git" "Not found in PATH"
        return 1
    fi
}

verify_python() {
    echo -e "\n${CYAN}[Python Verification]${NC}"

    if command_exists python3; then
        local python_version
        python_version=$(python3 --version 2>&1)

        if [[ $? -eq 0 ]]; then
            print_result PASS "Python 3" "Installed and working" "$python_version"

            # Check pip
            if command_exists pip3; then
                local pip_version
                pip_version=$(pip3 --version 2>&1 | head -n1)
                print_result PASS "pip" "Available" "$pip_version"
            else
                print_result WARN "pip" "Not found"
            fi

            return 0
        else
            print_result FAIL "Python 3" "Command exists but not responding correctly"
            return 1
        fi
    else
        print_result FAIL "Python 3" "Not found in PATH"
        return 1
    fi
}

verify_uv() {
    echo -e "\n${CYAN}[UV Package Manager Verification]${NC}"

    if command_exists uv; then
        local uv_version
        uv_version=$(uv --version 2>&1 || echo "installed")

        if [[ $? -eq 0 ]] || [[ "$uv_version" == "installed" ]]; then
            print_result PASS "UV" "Installed and accessible" "$uv_version"
            return 0
        else
            print_result FAIL "UV" "Command exists but not responding correctly"
            return 1
        fi
    else
        print_result WARN "UV" "Not found in PATH" "May need to restart shell or source ~/.bashrc"
        return 0  # Not critical
    fi
}

verify_claude_code() {
    echo -e "\n${CYAN}[Claude Code Verification]${NC}"

    if command_exists npx; then
        echo -e "${GRAY}  Testing Claude Code accessibility...${NC}"

        # Test with a timeout
        local output
        if output=$(timeout 15s npx @anthropic-ai/claude-code --help 2>&1); then
            if echo "$output" | grep -qi "claude\|anthropic\|usage"; then
                print_result PASS "Claude Code" "Accessible via npx" "Can be invoked with: npx @anthropic-ai/claude-code"
                return 0
            else
                print_result WARN "Claude Code" "npx command completed but output unexpected" "Try running: npx @anthropic-ai/claude-code --help"
                return 0
            fi
        else
            local exit_code=$?
            if [[ $exit_code -eq 124 ]]; then
                print_result WARN "Claude Code" "Test timed out (may need first-time setup)" "Try running: npx @anthropic-ai/claude-code --help"
            else
                print_result WARN "Claude Code" "Could not test automatically" "Try running: npx @anthropic-ai/claude-code --help"
            fi
            return 0
        fi
    else
        print_result FAIL "Claude Code" "npx not available (required to run Claude Code)"
        return 1
    fi
}

verify_api_keys() {
    echo -e "\n${CYAN}[API Keys Verification]${NC}"

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    local cred_dir="$script_dir/.credentials"

    if [[ -d "$cred_dir" ]]; then
        print_result PASS ".credentials directory" "Directory exists" "$cred_dir"

        # Check for actual API key files
        local anthropic_key="$cred_dir/anthropic.key"
        local google_key="$cred_dir/google.key"

        if [[ -f "$anthropic_key" ]]; then
            if [[ -s "$anthropic_key" ]]; then
                print_result PASS "Anthropic API Key" "Key file exists and not empty"
            else
                print_result WARN "Anthropic API Key" "Key file exists but appears empty"
            fi
        else
            print_result WARN "Anthropic API Key" "Key file not found" "Create: $anthropic_key"
        fi

        if [[ -f "$google_key" ]]; then
            if [[ -s "$google_key" ]]; then
                print_result PASS "Google API Key" "Key file exists and not empty"
            else
                print_result WARN "Google API Key" "Key file exists but appears empty"
            fi
        else
            print_result WARN "Google API Key" "Key file not found" "Create: $google_key"
        fi
    else
        print_result FAIL ".credentials directory" "Directory not found" "Expected at: $cred_dir"
    fi
}

verify_bugfix_exercise() {
    echo -e "\n${CYAN}[bugFix Exercise Verification]${NC}"

    local bugfix_dir="$HOME/bugFix"

    if [[ -d "$bugfix_dir" ]]; then
        print_result PASS "bugFix directory" "Directory exists" "$bugfix_dir"

        # Check for key files
        if [[ -f "$bugfix_dir/pyproject.toml" ]]; then
            print_result PASS "pyproject.toml" "Found"
        else
            print_result WARN "pyproject.toml" "Not found"
        fi

        if [[ -f "$bugfix_dir/buggy_script.py" ]]; then
            print_result PASS "buggy_script.py" "Found"
        else
            print_result WARN "buggy_script.py" "Not found"
        fi

        if [[ -f "$bugfix_dir/README.md" ]]; then
            print_result PASS "README.md" "Found"
        else
            print_result WARN "README.md" "Not found"
        fi
    else
        print_result WARN "bugFix directory" "Not found" "Expected at: $bugfix_dir"
    fi
}

verify_shell_config() {
    echo -e "\n${CYAN}[Shell Configuration Verification]${NC}"

    # Check PATH for common entries
    if echo "$PATH" | grep -q ".local/bin"; then
        print_result PASS "PATH Configuration" "~/.local/bin in PATH"
    else
        print_result WARN "PATH Configuration" "~/.local/bin not in PATH" "May need to restart shell"
    fi

    # Check for aliases
    if type claude &>/dev/null; then
        print_result PASS "Claude alias" "Configured"
    else
        print_result WARN "Claude alias" "Not found" "May need to source ~/.bashrc"
    fi

    # Check .bashrc exists
    if [[ -f "$HOME/.bashrc" ]]; then
        print_result PASS ".bashrc" "File exists"
    else
        print_result WARN ".bashrc" "File not found"
    fi
}

################################################################################
# Main Execution
################################################################################

show_banner() {
    clear
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                            ║${NC}"
    echo -e "${CYAN}║     AI CLI Tools Installation Verification (WSL)           ║${NC}"
    echo -e "${CYAN}║                                                            ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

main() {
    show_banner

    # Run all verification tests
    verify_nodejs
    verify_npm
    verify_git
    verify_python
    verify_uv
    verify_claude_code
    verify_api_keys
    verify_bugfix_exercise
    verify_shell_config

    # Print summary
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  Verification Summary${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""

    echo -e "${GRAY}Passed:   ${NC}${GREEN}${PASSED_CHECKS}${NC}"
    echo -e "${GRAY}Failed:   ${NC}${RED}${FAILED_CHECKS}${NC}"
    echo -e "${GRAY}Warnings: ${NC}${YELLOW}${WARNING_CHECKS}${NC}"
    echo ""

    # Determine overall status
    if [[ $FAILED_CHECKS -eq 0 ]]; then
        if [[ $WARNING_CHECKS -eq 0 ]]; then
            echo -e "${GREEN}✓ All checks passed! Installation is complete and verified.${NC}"
            echo ""
            echo -e "${NC}You can now use Claude Code with:${NC}"
            echo -e "${CYAN}  npx @anthropic-ai/claude-code${NC}"
            echo -e "${NC}Or use the alias:${NC}"
            echo -e "${CYAN}  claude${NC}"
            echo ""
            exit 0
        else
            echo -e "${YELLOW}⚠ Installation verified with warnings.${NC}"
            echo -e "${NC}  Review the warnings above and address if needed.${NC}"
            echo ""
            exit 0
        fi
    else
        echo -e "${RED}✗ Installation verification failed.${NC}"
        echo -e "${NC}  Please review the failed checks above and:${NC}"
        echo -e "${NC}  1. Re-run the installation script${NC}"
        echo -e "${NC}  2. Check the installation log for errors${NC}"
        echo -e "${NC}  3. See docs/TROUBLESHOOTING.md for help${NC}"
        echo ""
        exit 1
    fi
}

main "$@"
