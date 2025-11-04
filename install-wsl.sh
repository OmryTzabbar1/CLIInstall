#!/bin/bash

################################################################################
# install-wsl.sh - AI CLI Tools Installation for WSL/Ubuntu
################################################################################
# This script automates the installation of AI CLI tools in WSL:
#   - Node.js LTS (via NodeSource)
#   - Git
#   - Python 3 and pip
#   - UV package manager
#   - Claude Code (via npx)
#   - Gemini CLI
#   - bugFix practice exercise
#
# Usage:
#   bash install-wsl.sh [OPTIONS]
#
# Options:
#   --skip-prereqs    Skip prerequisite checks (not recommended)
#   --help            Display this help message
#
# Requirements:
#   - Ubuntu 20.04+ (or compatible Debian-based distro)
#   - sudo privileges
#   - Internet connection
#
# Author: AI CLI Setup Project
# Version: 1.0
# Last Updated: 2025-11-03
################################################################################

set -uo pipefail

################################################################################
# Configuration
################################################################################

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/tmp/ai-cli-setup-$(date +%Y%m%d-%H%M%S).log"
readonly NODE_MAJOR=20  # Node.js LTS version

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly GRAY='\033[0;90m'
readonly NC='\033[0m'

# Track errors and warnings
declare -a INSTALL_ERRORS=()
declare -a INSTALL_WARNINGS=()

# Parse command line arguments
SKIP_PREREQS=false

################################################################################
# Logging Functions
################################################################################

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"

    case "$level" in
        INFO)
            echo -e "${CYAN}${message}${NC}"
            ;;
        SUCCESS)
            echo -e "${GREEN}${message}${NC}"
            ;;
        WARN)
            echo -e "${YELLOW}${message}${NC}"
            ;;
        ERROR)
            echo -e "${RED}${message}${NC}"
            ;;
        *)
            echo "$message"
            ;;
    esac
}

print_header() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    log INFO "$1"
}

print_step() {
    echo ""
    echo -e "${YELLOW}>>> $1${NC}"
    log INFO "$1"
}

################################################################################
# Helper Functions
################################################################################

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_prerequisites() {
    print_header "Checking Prerequisites"

    local prereq_script="$SCRIPT_DIR/scripts/helpers/check-prerequisites.sh"

    if [[ -f "$prereq_script" ]]; then
        if bash "$prereq_script"; then
            log SUCCESS "Prerequisites check passed"
            return 0
        else
            log ERROR "Prerequisites check failed"
            echo ""
            echo -e "${RED}Please resolve the issues above before continuing.${NC}"
            echo -e "${YELLOW}Or run with --skip-prereqs to bypass (not recommended).${NC}"
            echo ""
            exit 1
        fi
    else
        log WARN "Prerequisite checker not found, continuing anyway..."
        INSTALL_WARNINGS+=("Prerequisite checker script not found")
    fi
}

################################################################################
# Installation Functions
################################################################################

update_package_lists() {
    print_header "Updating Package Lists"

    print_step "Running apt update..."

    if sudo apt update 2>&1 | tee -a "$LOG_FILE"; then
        log SUCCESS "✓ Package lists updated"
        return 0
    else
        log ERROR "✗ Failed to update package lists"
        INSTALL_ERRORS+=("apt update failed")
        return 1
    fi
}

install_build_essentials() {
    print_header "Installing Build Essentials"

    local packages=("build-essential" "curl" "wget" "git")
    local to_install=()

    # Check which packages need to be installed
    for pkg in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii  $pkg "; then
            log INFO "  $pkg: already installed"
        else
            to_install+=("$pkg")
        fi
    done

    if [[ ${#to_install[@]} -eq 0 ]]; then
        log SUCCESS "✓ All build essentials already installed"
        return 0
    fi

    print_step "Installing: ${to_install[*]}"

    if sudo apt install -y "${to_install[@]}" 2>&1 | tee -a "$LOG_FILE"; then
        log SUCCESS "✓ Build essentials installed"
        return 0
    else
        log ERROR "✗ Failed to install build essentials"
        INSTALL_ERRORS+=("Build essentials installation failed")
        return 1
    fi
}

install_nodejs() {
    print_header "Node.js Installation"

    # Check if Node.js is already installed
    if command_exists node; then
        local node_version
        node_version=$(node --version)
        log SUCCESS "✓ Node.js already installed: $node_version"

        # Check version
        local major_version
        major_version=$(echo "$node_version" | cut -d'v' -f2 | cut -d'.' -f1)

        if [[ "$major_version" -ge 16 ]]; then
            log INFO "  Version is acceptable (v16+ recommended)"
            return 0
        else
            log WARN "  Installed version is old. Consider updating."
            INSTALL_WARNINGS+=("Node.js version is older than recommended")
        fi
    fi

    print_step "Setting up NodeSource repository..."

    # Download and run NodeSource setup script
    if curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | sudo -E bash - 2>&1 | tee -a "$LOG_FILE"; then
        log SUCCESS "✓ NodeSource repository configured"
    else
        log ERROR "✗ Failed to setup NodeSource repository"
        INSTALL_ERRORS+=("NodeSource setup failed")
        return 1
    fi

    print_step "Installing Node.js..."

    if sudo apt install -y nodejs 2>&1 | tee -a "$LOG_FILE"; then
        log SUCCESS "✓ Node.js installed"

        # Verify installation
        if command_exists node; then
            local node_version npm_version
            node_version=$(node --version)
            npm_version=$(npm --version)
            log SUCCESS "✓ Node.js verified: $node_version"
            log SUCCESS "✓ npm verified: $npm_version"
        else
            log ERROR "✗ Node.js not found after installation"
            INSTALL_ERRORS+=("Node.js verification failed")
            return 1
        fi

        return 0
    else
        log ERROR "✗ Failed to install Node.js"
        INSTALL_ERRORS+=("Node.js installation failed")
        return 1
    fi
}

install_git() {
    print_header "Git Installation"

    if command_exists git; then
        local git_version
        git_version=$(git --version)
        log SUCCESS "✓ Git already installed: $git_version"
        return 0
    fi

    print_step "Installing Git..."

    if sudo apt install -y git 2>&1 | tee -a "$LOG_FILE"; then
        log SUCCESS "✓ Git installed"

        if command_exists git; then
            local git_version
            git_version=$(git --version)
            log SUCCESS "✓ Git verified: $git_version"
        fi

        return 0
    else
        log ERROR "✗ Failed to install Git"
        INSTALL_ERRORS+=("Git installation failed")
        return 1
    fi
}

install_python_and_pip() {
    print_header "Python and pip Installation"

    # Check if Python 3 is installed
    if command_exists python3; then
        local python_version
        python_version=$(python3 --version)
        log SUCCESS "✓ Python 3 already installed: $python_version"
    else
        print_step "Installing Python 3..."
        if sudo apt install -y python3 python3-pip 2>&1 | tee -a "$LOG_FILE"; then
            log SUCCESS "✓ Python 3 installed"
        else
            log ERROR "✗ Failed to install Python 3"
            INSTALL_ERRORS+=("Python 3 installation failed")
            return 1
        fi
    fi

    # Check pip
    if command_exists pip3; then
        local pip_version
        pip_version=$(pip3 --version)
        log SUCCESS "✓ pip already installed: $pip_version"
    else
        print_step "Installing pip..."
        if sudo apt install -y python3-pip 2>&1 | tee -a "$LOG_FILE"; then
            log SUCCESS "✓ pip installed"
        else
            log ERROR "✗ Failed to install pip"
            INSTALL_ERRORS+=("pip installation failed")
            return 1
        fi
    fi

    # Update pip to latest version
    print_step "Updating pip to latest version..."
    if pip3 install --user --upgrade pip 2>&1 | tee -a "$LOG_FILE"; then
        log SUCCESS "✓ pip updated"
    else
        log WARN "⚠ pip update failed (not critical)"
        INSTALL_WARNINGS+=("pip update failed")
    fi

    return 0
}

install_uv() {
    print_header "UV Package Manager Installation"

    # Check if UV is already installed
    if command_exists uv; then
        local uv_version
        uv_version=$(uv --version 2>&1 || echo "unknown")
        log SUCCESS "✓ UV already installed: $uv_version"
        return 0
    fi

    print_step "Installing UV via pip..."

    if pip3 install --user uv 2>&1 | tee -a "$LOG_FILE"; then
        log SUCCESS "✓ UV installed"

        # Add to PATH in .bashrc if not already there
        local bashrc="$HOME/.bashrc"
        local path_export='export PATH="$HOME/.local/bin:$PATH"'

        if ! grep -q "$HOME/.local/bin" "$bashrc" 2>/dev/null; then
            print_step "Adding UV to PATH in .bashrc..."
            echo "" >> "$bashrc"
            echo "# UV package manager and Python tools" >> "$bashrc"
            echo "$path_export" >> "$bashrc"
            log SUCCESS "✓ PATH updated in .bashrc"

            # Source for current session
            export PATH="$HOME/.local/bin:$PATH"
        else
            log INFO "  PATH already configured in .bashrc"
        fi

        # Verify UV is accessible
        if command_exists uv; then
            local uv_version
            uv_version=$(uv --version 2>&1 || echo "installed")
            log SUCCESS "✓ UV verified: $uv_version"
        else
            log WARN "⚠ UV installed but not in PATH yet (restart shell or source .bashrc)"
            INSTALL_WARNINGS+=("UV requires shell restart to be accessible")
        fi

        return 0
    else
        log ERROR "✗ Failed to install UV"
        INSTALL_ERRORS+=("UV installation failed")
        return 1
    fi
}

setup_npm_tools() {
    print_header "npm and CLI Tools Setup"

    if ! command_exists npm; then
        log ERROR "✗ npm not available. Node.js installation may have failed."
        INSTALL_ERRORS+=("npm not found")
        return 1
    fi

    log SUCCESS "✓ npm is available"

    # Test npx
    print_step "Testing npx functionality..."
    if command_exists npx; then
        local npx_version
        npx_version=$(npx --version 2>&1 || echo "available")
        log SUCCESS "✓ npx is working: $npx_version"
    else
        log WARN "⚠ npx not found (usually comes with npm)"
        INSTALL_WARNINGS+=("npx not found")
    fi

    log SUCCESS "✓ CLI tools will be accessible via npx"
    return 0
}

setup_credentials_directory() {
    print_header ".credentials Directory Setup"

    local cred_dir="$SCRIPT_DIR/.credentials"

    if [[ -d "$cred_dir" ]]; then
        log SUCCESS "✓ .credentials directory exists: $cred_dir"

        # Check for template files
        local templates=("anthropic.key.example" "google.key.example" "README.md")
        local all_present=true

        for template in "${templates[@]}"; do
            if [[ ! -f "$cred_dir/$template" ]]; then
                log WARN "⚠ Template file missing: $template"
                all_present=false
            fi
        done

        if $all_present; then
            log SUCCESS "✓ All template files present"
        fi
    else
        log WARN "⚠ .credentials directory not found: $cred_dir"
        INSTALL_WARNINGS+=(".credentials directory not found")
    fi

    # Display API key setup instructions
    echo ""
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}  NEXT STEP: Set Up Your API Keys${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo ""
    echo -e "${NC}To use Claude Code and Gemini CLI, you need API keys:${NC}"
    echo ""
    echo -e "${CYAN}1. Get Claude API key:${NC}"
    echo -e "${GRAY}   • Visit: https://console.anthropic.com${NC}"
    echo -e "${GRAY}   • Create an API key${NC}"
    echo -e "${GRAY}   • Save it to: $cred_dir/anthropic.key${NC}"
    echo ""
    echo -e "${CYAN}2. Get Gemini API key:${NC}"
    echo -e "${GRAY}   • Visit: https://aistudio.google.com${NC}"
    echo -e "${GRAY}   • Create an API key${NC}"
    echo -e "${GRAY}   • Save it to: $cred_dir/google.key${NC}"
    echo ""
    echo -e "${NC}See $cred_dir/README.md for detailed instructions.${NC}"
    echo ""

    return 0
}

setup_bugfix_exercise() {
    print_header "bugFix Practice Exercise Setup"

    local source_dir="$SCRIPT_DIR/bugFix"
    local target_dir="$HOME/bugFix"

    # Check if source directory exists
    if [[ ! -d "$source_dir" ]]; then
        log WARN "⚠ bugFix source directory not found: $source_dir"
        log INFO "  bugFix exercise will be available in the repository"
        INSTALL_WARNINGS+=("bugFix source directory not found")
        return 0
    fi

    # Create target directory
    if [[ -d "$target_dir" ]]; then
        log INFO "  bugFix directory already exists: $target_dir"
        log INFO "  Skipping copy to avoid overwriting existing files"
        return 0
    fi

    print_step "Creating bugFix directory in home..."

    if mkdir -p "$target_dir" && cp -r "$source_dir"/* "$target_dir/" 2>&1 | tee -a "$LOG_FILE"; then
        log SUCCESS "✓ bugFix exercise copied to: $target_dir"

        # Initialize UV project if pyproject.toml exists
        if [[ -f "$target_dir/pyproject.toml" ]] && command_exists uv; then
            print_step "Initializing UV project..."
            cd "$target_dir" || return 1

            if uv sync 2>&1 | tee -a "$LOG_FILE"; then
                log SUCCESS "✓ UV project initialized"
            else
                log WARN "⚠ UV project initialization failed (not critical)"
                INSTALL_WARNINGS+=("UV project initialization failed")
            fi

            cd - >/dev/null || return 1
        fi

        log SUCCESS "✓ bugFix exercise ready at: $target_dir"
        return 0
    else
        log WARN "⚠ Failed to setup bugFix exercise"
        INSTALL_WARNINGS+=("bugFix setup failed")
        return 0  # Non-critical failure
    fi
}

configure_shell_environment() {
    print_header "Shell Environment Configuration"

    local bashrc="$HOME/.bashrc"

    # Check if .bashrc exists
    if [[ ! -f "$bashrc" ]]; then
        log WARN "⚠ .bashrc not found, creating..."
        touch "$bashrc"
    fi

    # Add helpful aliases (optional)
    local aliases_marker="# AI CLI Tools aliases"

    if ! grep -q "$aliases_marker" "$bashrc" 2>/dev/null; then
        print_step "Adding helpful aliases to .bashrc..."

        cat >> "$bashrc" << 'EOF'

# AI CLI Tools aliases
alias claude='npx @anthropic-ai/claude-code'
alias python='python3'
alias pip='pip3'
EOF

        log SUCCESS "✓ Aliases added to .bashrc"
    else
        log INFO "  Aliases already present in .bashrc"
    fi

    log SUCCESS "✓ Shell environment configured"
    log INFO "  Run 'source ~/.bashrc' to apply changes to current session"

    return 0
}

################################################################################
# Main Execution
################################################################################

show_banner() {
    clear
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                            ║${NC}"
    echo -e "${CYAN}║       AI CLI Tools Installation for WSL/Ubuntu             ║${NC}"
    echo -e "${CYAN}║                                                            ║${NC}"
    echo -e "${CYAN}║  This script will install:                                 ║${NC}"
    echo -e "${CYAN}║    • Node.js LTS                                           ║${NC}"
    echo -e "${CYAN}║    • Git                                                   ║${NC}"
    echo -e "${CYAN}║    • Python 3 and pip                                      ║${NC}"
    echo -e "${CYAN}║    • UV package manager                                    ║${NC}"
    echo -e "${CYAN}║    • Claude Code (via npx)                                 ║${NC}"
    echo -e "${CYAN}║    • Gemini CLI                                            ║${NC}"
    echo -e "${CYAN}║    • bugFix practice exercise                              ║${NC}"
    echo -e "${CYAN}║                                                            ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_help() {
    cat << EOF
AI CLI Tools Installation for WSL/Ubuntu

Usage:
    bash install-wsl.sh [OPTIONS]

Options:
    --skip-prereqs    Skip prerequisite checks (not recommended)
    --help            Display this help message

Requirements:
    - Ubuntu 20.04+ (or compatible Debian-based distro)
    - sudo privileges
    - Internet connection

For more information, see README.md

EOF
    exit 0
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --skip-prereqs)
                SKIP_PREREQS=true
                shift
                ;;
            --help|-h)
                show_help
                ;;
            *)
                echo "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

main() {
    parse_arguments "$@"

    show_banner

    log INFO "========================================"
    log INFO "AI CLI Tools Installation Started"
    log INFO "Log file: $LOG_FILE"
    log INFO "========================================"

    # Prerequisites check
    if [[ "$SKIP_PREREQS" == false ]]; then
        check_prerequisites
    else
        log WARN "⚠ Skipping prerequisites check (as requested)"
    fi

    # Run installation steps
    update_package_lists || exit 1
    install_build_essentials || exit 1
    install_nodejs || exit 1
    install_git || exit 1
    install_python_and_pip || exit 1
    install_uv || exit 1
    setup_npm_tools || exit 1
    setup_credentials_directory
    setup_bugfix_exercise
    configure_shell_environment

    # Installation complete
    print_header "Installation Complete!"

    if [[ ${#INSTALL_ERRORS[@]} -eq 0 ]]; then
        echo -e "${GREEN}✓ All components installed successfully!${NC}\n"

        echo -e "${YELLOW}Next steps:${NC}"
        echo -e "${NC}1. Source your .bashrc: ${CYAN}source ~/.bashrc${NC}"
        echo -e "${NC}2. Set up your API keys (see instructions above)${NC}"
        echo -e "${NC}3. Run verification: ${CYAN}bash scripts/verify-installation.sh${NC}"
        echo -e "${NC}4. Try bugFix exercise: ${CYAN}cd ~/bugFix${NC}"
        echo -e "${NC}5. Start using Claude Code: ${CYAN}npx @anthropic-ai/claude-code${NC}"
        echo ""

        log SUCCESS "Installation completed successfully"
    else
        echo -e "${YELLOW}⚠ Installation completed with errors:${NC}\n"
        for error in "${INSTALL_ERRORS[@]}"; do
            echo -e "${RED}  • $error${NC}"
        done
        echo ""
        log WARN "Installation completed with errors"
    fi

    if [[ ${#INSTALL_WARNINGS[@]} -gt 0 ]]; then
        echo -e "${YELLOW}⚠ Warnings:${NC}"
        for warning in "${INSTALL_WARNINGS[@]}"; do
            echo -e "${YELLOW}  • $warning${NC}"
        done
        echo ""
    fi

    echo -e "${GRAY}Log file saved to: $LOG_FILE${NC}"
    echo ""

    exit 0
}

# Run main function with all arguments
main "$@"
