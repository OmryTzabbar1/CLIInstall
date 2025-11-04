# AI CLI Tools Installation Suite

> **Automated installation and setup for Claude Code and Gemini CLI on Windows**

A comprehensive, production-ready installation system that sets up AI-powered command-line tools across Windows environments (CMD, PowerShell, and WSL Ubuntu).

## Quick Start

**Windows Installation (5 minutes):**
```powershell
# Open PowerShell as Administrator
.\install-windows.ps1
```

**WSL Installation (10 minutes):**
```bash
# In WSL Ubuntu terminal
bash install-wsl.sh
```

**Verify Installation:**
```powershell
# Windows
.\scripts\verify-installation.ps1

# WSL
bash scripts/verify-installation.sh
```

---

## Table of Contents

- [What This Installs](#what-this-installs)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Windows Installation](#windows-installation)
  - [WSL Installation](#wsl-installation)
- [API Key Setup](#api-key-setup)
- [Verification](#verification)
- [Usage Examples](#usage-examples)
- [bugFix Practice Exercise](#bugfix-practice-exercise)
- [Troubleshooting](#troubleshooting)
- [Project Structure](#project-structure)
- [Contributing](#contributing)

---

## What This Installs

### For Windows (CMD & PowerShell):
- **Node.js LTS** - JavaScript runtime (v16+)
- **npm & npx** - Package managers for Node.js
- **Git for Windows** - Version control system
- **Claude Code** - Anthropic's AI coding assistant (via npx)
- **Gemini CLI** - Google's AI assistant (via npm)

### For WSL Ubuntu:
- Everything from Windows, plus:
- **Python 3.9+** - Programming language
- **pip** - Python package manager
- **UV** - Modern Python package manager
- **bugFix Exercise** - Hands-on debugging practice

### Configuration:
- `.credentials/` directory for API key storage
- Environment PATH configuration
- Shell aliases and shortcuts
- Comprehensive logging and error handling

---

## Prerequisites

### Windows Requirements

| Requirement | Minimum | Recommended | Check |
|-------------|---------|-------------|-------|
| **OS** | Windows 10 build 1809 | Windows 11 | `winver` |
| **PowerShell** | 5.1 | 7.0+ | `$PSVersionTable.PSVersion` |
| **Privileges** | Administrator | Administrator | Required for winget |
| **Internet** | Required | High-speed | For downloads |
| **Disk Space** | 1 GB | 2 GB | For all tools |
| **winget** | Required | Latest | `winget --version` |

### WSL Requirements

| Requirement | Minimum | Recommended | Check |
|-------------|---------|-------------|-------|
| **WSL** | WSL 2 | WSL 2 | `wsl --status` |
| **Ubuntu** | 20.04 LTS | 22.04 LTS | `lsb_release -a` |
| **sudo** | Required | Required | User must have sudo access |
| **Internet** | Required | High-speed | For apt packages |
| **Disk Space** | 2 GB | 4 GB | For Python + Node.js |

### Enable WSL (if not already enabled)

```powershell
# In PowerShell as Administrator
wsl --install

# Or install specific distro
wsl --install -d Ubuntu-22.04

# Restart your computer
```

---

## Installation

### Windows Installation

#### Step 1: Open PowerShell as Administrator

1. Press `Win + X`
2. Select "Windows PowerShell (Admin)" or "Terminal (Admin)"
3. Navigate to the project directory

#### Step 2: Run Installation Script

```powershell
# Navigate to project
cd path\to\ClaudeGeminiCLI

# Run installer
.\install-windows.ps1
```

#### Step 3: Follow On-Screen Instructions

The installer will:
- Check prerequisites automatically
- Install Node.js LTS via winget
- Install Git for Windows via winget
- Setup npm and npx
- Configure .credentials directory
- Display next steps

**Expected Duration:** 5-10 minutes (depending on internet speed)

#### Installation Options

```powershell
# Skip prerequisite checks (not recommended)
.\install-windows.ps1 -SkipPrerequisites

# Custom log path
.\install-windows.ps1 -LogPath "C:\MyLogs\install.log"

# View help
Get-Help .\install-windows.ps1 -Full
```

---

### WSL Installation

#### Step 1: Open WSL Terminal

1. Press `Win + R`, type `wsl`, press Enter
2. Or open Ubuntu from Start Menu
3. Navigate to the project directory

```bash
# If project is in Windows
cd /mnt/c/Users/YourUsername/path/to/ClaudeGeminiCLI

# Or clone the repository in WSL
git clone <repository-url>
cd ClaudeGeminiCLI
```

#### Step 2: Run Installation Script

```bash
# Make script executable
chmod +x install-wsl.sh

# Run installer
bash install-wsl.sh
```

#### Step 3: Follow On-Screen Instructions

The installer will:
- Check prerequisites
- Update apt packages
- Install build essentials (curl, wget, git)
- Install Node.js 20 LTS via NodeSource
- Install Python 3 and pip
- Install UV package manager
- Setup bugFix practice exercise in `~/bugFix`
- Configure .bashrc with aliases
- Display next steps

**Expected Duration:** 10-15 minutes (first-time setup)

#### Installation Options

```bash
# Skip prerequisite checks (not recommended)
bash install-wsl.sh --skip-prereqs

# View help
bash install-wsl.sh --help
```

#### Step 4: Apply Shell Configuration

```bash
# Apply .bashrc changes
source ~/.bashrc

# Or restart your terminal
```

---

## API Key Setup

Both Claude Code and Gemini CLI require API keys to function.

### Step 1: Get Your API Keys

#### Anthropic (Claude) API Key

1. Visit **https://console.anthropic.com**
2. Sign up or log in
3. Navigate to "API Keys"
4. Click "Create Key"
5. Copy your API key (starts with `sk-ant-api03-...`)

#### Google AI (Gemini) API Key

1. Visit **https://aistudio.google.com**
2. Sign up or log in
3. Click "Get API Key"
4. Create an API key
5. Copy your API key (starts with `AIza...`)

### Step 2: Store Your API Keys

Create files in the `.credentials` directory:

#### Windows (PowerShell):
```powershell
# Navigate to project
cd path\to\ClaudeGeminiCLI

# Create Anthropic key file
"your-anthropic-api-key-here" | Out-File -FilePath ".credentials\anthropic.key" -NoNewline

# Create Google key file
"your-google-api-key-here" | Out-File -FilePath ".credentials\google.key" -NoNewline
```

#### WSL (Bash):
```bash
# Navigate to project
cd /path/to/ClaudeGeminiCLI

# Create Anthropic key file
echo "your-anthropic-api-key-here" > .credentials/anthropic.key

# Create Google key file
echo "your-google-api-key-here" > .credentials/google.key
```

### Step 3: Verify Keys Are Not Tracked by Git

```bash
# Should show NO credential files
git status

# Verify gitignore is working
git check-ignore -v .credentials/anthropic.key
```

**Expected Output:** The key files should be ignored by git.

For more detailed instructions, see [docs/API_KEY_SETUP.md](docs/API_KEY_SETUP.md).

---

## Verification

### Verify Windows Installation

```powershell
# Run verification script
.\scripts\verify-installation.ps1
```

**Expected Output:**
```
[Node.js Verification]
  ✓ Node.js - Installed and working
      Version: v20.x.x

[npm Verification]
  ✓ npm - Installed and working
      Version: 10.x.x
  ✓ npx - Available
      Version: 10.x.x

[Git Verification]
  ✓ Git - Installed and working
      git version 2.x.x

All checks passed! Installation is complete and verified.
```

### Verify WSL Installation

```bash
# Run verification script
bash scripts/verify-installation.sh
```

**Expected Output:**
```
[Node.js Verification]
  ✓ Node.js - Installed and working
      Version: v20.x.x

[Python Verification]
  ✓ Python 3 - Installed and working
      Python 3.10.x

[UV Package Manager Verification]
  ✓ UV - Installed and accessible
      uv 0.x.x

All checks passed! Installation is complete and verified.
```

### Test All Environments (Windows)

```powershell
# Test CMD, PowerShell, and WSL from one script
.\scripts\test-all-environments.ps1
```

This generates a comprehensive report comparing all three environments.

---

## Usage Examples

### Using Claude Code

#### Windows:
```powershell
# Start Claude Code
npx @anthropic-ai/claude-code

# Or with project path
npx @anthropic-ai/claude-code --project "C:\Projects\MyApp"
```

#### WSL:
```bash
# Start Claude Code
npx @anthropic-ai/claude-code

# Or use the alias
claude

# With project path
claude --project ~/projects/myapp
```

### Example Prompts

```
"Analyze this codebase and suggest improvements"
"Fix the bug in src/main.py causing TypeError"
"Add comprehensive error handling to the API endpoints"
"Write unit tests for the UserService class"
"Refactor this function to be more efficient"
```

### Using Gemini CLI

```bash
# Ask a question
gemini "How do I implement a binary search tree in Python?"

# Code generation
gemini "Write a FastAPI endpoint for user authentication"

# Debugging help
gemini "Why does this code throw a NullPointerException?"
```

---

## bugFix Practice Exercise

**Location:** `bugFix/` directory (or `~/bugFix` in WSL)

A hands-on exercise to practice using AI CLI tools for debugging.

### Quick Start

```bash
# Navigate to bugFix directory
cd bugFix   # Or: cd ~/bugFix

# Try running the buggy script
python3 buggy_script.py

# Use AI tools to find and fix bugs
npx @anthropic-ai/claude-code
```

### The Challenge

Find and fix **5 intentional bugs** in `buggy_script.py`:
- 🟢 2 Easy bugs (syntax errors)
- 🟡 2 Medium bugs (logic errors)
- 🔴 1 Hard bug (algorithm flaw)

### Learning Objectives

- Practice effective AI prompting for debugging
- Understand common Python bug patterns
- Learn systematic debugging approaches
- Master AI-assisted problem solving

### Resources

- **README.md** - Complete instructions and tips
- **SOLUTION.md** - Detailed solutions (try on your own first!)
- **tests/** - Pytest test suite to verify fixes

### Success Criteria

When all bugs are fixed:
```bash
python3 buggy_script.py
# Output: All tests passed! ✓
```

---

## Troubleshooting

### Common Issues

#### "Execution Policy" Error (Windows)

**Error:**
```
cannot be loaded because running scripts is disabled
```

**Solution:**
```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### "winget not found" (Windows)

**Solution:**
1. Install App Installer from Microsoft Store
2. Or update Windows to latest version
3. Or download from: https://github.com/microsoft/winget-cli/releases

#### "npm command not found" After Installation

**Solution:**
```powershell
# Restart PowerShell/Terminal
# Or refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

#### WSL Not Starting

**Solution:**
```powershell
# Enable WSL feature
wsl --install

# Update WSL
wsl --update

# Set WSL 2 as default
wsl --set-default-version 2
```

#### "Permission Denied" in WSL

**Solution:**
```bash
# Make scripts executable
chmod +x install-wsl.sh
chmod +x scripts/verify-installation.sh
```

### Getting Help

1. **Check logs:**
   - Windows: `%TEMP%\ai-cli-setup-*.log`
   - WSL: `/tmp/ai-cli-setup-*.log`

2. **Run verification scripts** to identify specific issues

3. **See full troubleshooting guide:** [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

4. **Report issues:** [GitHub Issues](https://github.com/anthropics/claude-code/issues)

---

## Project Structure

```
ClaudeGeminiCLI/
├── install-windows.ps1              # Windows installation script
├── install-wsl.sh                   # WSL installation script
├── README.md                        # This file
├── PRD.md                           # Product requirements
├── CLAUDE.MD                        # AI assistant guide
├── PLANNING.MD                      # Architecture documentation
├── TASKS.MD                         # Task tracking
│
├── .credentials/                    # API key storage (gitignored)
│   ├── .gitkeep
│   ├── README.md                    # Key setup instructions
│   ├── anthropic.key.example        # Template file
│   └── google.key.example           # Template file
│
├── scripts/                         # Helper scripts
│   ├── verify-installation.ps1      # Windows verification
│   ├── verify-installation.sh       # WSL verification
│   ├── test-all-environments.ps1    # Cross-environment testing
│   └── helpers/
│       ├── check-prerequisites.ps1  # Windows prereqs
│       └── check-prerequisites.sh   # WSL prereqs
│
├── bugFix/                          # Practice exercise
│   ├── README.md                    # Exercise instructions
│   ├── buggy_script.py              # Script with 5 bugs
│   ├── SOLUTION.md                  # Detailed solutions
│   ├── pyproject.toml               # UV configuration
│   ├── .python-version              # Python 3.10
│   └── tests/
│       └── test_fixed_script.py     # Pytest test suite
│
├── docs/                            # Extended documentation
│   ├── API_KEY_SETUP.md            # Detailed key setup
│   ├── WSL_SETUP.md                # WSL installation guide
│   └── TROUBLESHOOTING.md          # Common issues
│
└── examples/                        # Usage examples
    ├── claude-code-examples.md
    └── gemini-cli-examples.md
```

---

## Features

### Installation System

- ✅ **Automated Setup** - One-command installation
- ✅ **Prerequisite Checking** - Validates requirements before installation
- ✅ **Idempotent** - Safe to run multiple times
- ✅ **Error Handling** - Comprehensive error detection and reporting
- ✅ **Logging** - Detailed timestamped logs for debugging
- ✅ **Progress Indicators** - Color-coded status updates
- ✅ **Cross-Platform** - Works on Windows, CMD, PowerShell, WSL

### Security

- ✅ **API Key Protection** - Comprehensive .gitignore patterns
- ✅ **Template System** - Example files without real keys
- ✅ **Documentation** - Clear security best practices
- ✅ **Verification** - Test that keys are properly ignored

### Developer Experience

- ✅ **Practice Exercise** - Hands-on bugFix challenge
- ✅ **Comprehensive Docs** - Detailed guides and examples
- ✅ **Verification Tools** - Automated installation testing
- ✅ **Troubleshooting** - Common issues and solutions

---

## Requirements for Development

If you want to contribute to this project:

- **PowerShell** 5.1+ (for Windows scripts)
- **Bash** 4.0+ (for WSL scripts)
- **Git** (for version control)
- **Text Editor** (VS Code recommended)

### Running Tests

```powershell
# Test Windows installation
.\install-windows.ps1

# Verify Windows
.\scripts\verify-installation.ps1

# Test cross-environment
.\scripts\test-all-environments.ps1
```

```bash
# Test WSL installation
bash install-wsl.sh

# Verify WSL
bash scripts/verify-installation.sh
```

---

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Development Workflow

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes**
4. **Test thoroughly** on all platforms
5. **Commit** (`git commit -m 'Add amazing feature'`)
6. **Push** (`git push origin feature/amazing-feature`)
7. **Open a Pull Request**

### Code Style

- **PowerShell**: Follow PSScriptAnalyzer guidelines
- **Bash**: Follow ShellCheck recommendations
- **Markdown**: Follow markdownlint rules
- **Documentation**: Clear, concise, user-focused

---

## Version History

### v1.0.0 (2025-11-03)
- Initial release
- Windows installation support
- WSL Ubuntu installation support
- bugFix practice exercise
- Comprehensive documentation
- Cross-environment testing

---

## License

This project is part of the AI CLI Tools setup suite.

---

## Acknowledgments

- **Anthropic** - For Claude Code
- **Google** - For Gemini API
- **Node.js Foundation** - For Node.js
- **Python Software Foundation** - For Python
- **Microsoft** - For WSL and winget

---

## Resources

### Official Documentation
- **Claude Code**: https://docs.claude.com/en/docs/claude-code
- **Gemini API**: https://ai.google.dev/
- **Node.js**: https://nodejs.org/
- **UV**: https://github.com/astral-sh/uv
- **WSL**: https://learn.microsoft.com/windows/wsl/

### Community
- **Issues**: Report bugs and request features
- **Discussions**: Ask questions and share tips
- **Discord**: Join the community (if available)

---

## Quick Reference Card

```bash
# Installation
.\install-windows.ps1              # Windows
bash install-wsl.sh                # WSL

# Verification
.\scripts\verify-installation.ps1  # Windows
bash scripts/verify-installation.sh # WSL

# Cross-Environment Test
.\scripts\test-all-environments.ps1

# Claude Code
npx @anthropic-ai/claude-code      # All platforms
claude                             # WSL alias

# bugFix Exercise
cd bugFix                          # Or ~/bugFix in WSL
python3 buggy_script.py
```

---

**Happy Coding with AI!** 🤖✨

Need help? Check the [Troubleshooting Guide](docs/TROUBLESHOOTING.md) or open an issue.
