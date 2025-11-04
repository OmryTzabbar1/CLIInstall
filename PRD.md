# Product Requirements Document: AI CLI Tools Installation Suite

## 1. Executive Summary

This project delivers a complete installation and setup system for AI-powered command-line interface tools (Claude Code and Gemini CLI) across multiple Windows environments. The solution ensures developers can seamlessly access AI coding assistance from CMD, PowerShell, and WSL Ubuntu terminals.

## 2. Product Vision

Enable developers to rapidly install, configure, and use AI CLI tools across all Windows development environments with automated scripts, clear documentation, and built-in practice exercises.

## 3. Target Users

- **Primary**: Windows developers new to AI CLI tools
- **Secondary**: DevOps engineers setting up standardized development environments
- **Tertiary**: Educators teaching AI-assisted development workflows

## 4. Core Requirements

### 4.1 Multi-Platform Installation

**Priority**: P0 (Critical)

- Install Claude Code CLI (`npx @anthropic-ai/claude-code`) across all three environments
- Install Gemini CLI across all three environments
- Ensure both tools are globally accessible and runnable from any terminal type

**Success Criteria**:
- User can run `npx @anthropic-ai/claude-code --version` from CMD, PowerShell, and WSL
- User can run Gemini CLI commands from all three environments
- No environment-specific PATH configuration required after running setup scripts

### 4.2 Prerequisite Management

**Priority**: P0 (Critical)

- Automated installation of Node.js LTS version
- Automated installation of npm package manager
- WSL Ubuntu distribution setup
- Git installation for Windows and WSL
- UV (Python package manager) installation for WSL

**Success Criteria**:
- All prerequisites are checked before installation
- Missing prerequisites are automatically installed or user is prompted with instructions
- Version compatibility is verified

### 4.3 Security & Best Practices

**Priority**: P0 (Critical)

**API Key Management**:
- Dedicated `.credentials/` directory for API key storage
- Template files showing expected format (e.g., `.credentials/anthropic.key.example`)
- Comprehensive `.gitignore` preventing accidental key commits

**Success Criteria**:
- API key files are never committed to git
- Users receive clear warnings about key security
- Template files guide proper key format

### 4.4 Documentation Suite

**Priority**: P0 (Critical)

**README.md Sections**:
1. **Quick Start Guide**: 5-minute setup path
2. **Prerequisites Check**: How to verify existing installations
3. **Installation Instructions**: Platform-specific step-by-step guides
4. **API Key Setup**: 
   - Creating Anthropic API keys at console.anthropic.com
   - Creating Google AI API keys at aistudio.google.com
   - Storing keys securely in the project
5. **WSL Setup**: Enabling and accessing WSL Ubuntu
6. **Git Operations**: Init, clone, basic workflow in WSL
7. **Verification**: Testing each tool in each environment
8. **Troubleshooting**: Common issues and solutions

**Success Criteria**:
- Non-technical users can follow instructions successfully
- All external links are current and functional
- Examples include expected output

### 4.5 Practice Exercise: bugFix Challenge

**Priority**: P1 (High)

**Location**: `~/bugFix/` directory in WSL Ubuntu home

**Components**:
- Python environment managed by UV
- Python script with 3-5 intentional bugs of varying difficulty:
  - Syntax error (easy)
  - Logic error (medium)
  - Runtime exception (medium)
  - Off-by-one error (hard)
  - Type mismatch (easy)
- README explaining the exercise
- Solution guide (in separate file)

**Success Criteria**:
- Bugs are fixable using Claude Code or Gemini CLI assistance
- Exercise demonstrates practical AI debugging workflow
- Users learn to formulate effective prompts for AI tools

## 5. Technical Specifications

### 5.1 Installation Scripts

**Windows Script** (`install-windows.ps1`):
- PowerShell 5.1+ compatible
- Admin privilege detection
- Node.js LTS installation via winget or chocolatey
- Git for Windows installation
- npm global package installation
- Environment variable configuration

**WSL Script** (`install-wsl.sh`):
- Bash 4.0+ compatible
- apt package manager usage
- Node.js installation via NodeSource repository
- UV installation via pip
- Path configuration for .bashrc/.zshrc

### 5.2 Directory Structure

```
ai-cli-setup/
├── PRD.md                          # This document
├── CLAUDE.MD                       # AI assistant training guide
├── PLANNING.MD                     # Architecture decisions
├── TASKS.MD                        # Task tracking
├── README.md                       # User-facing documentation
├── .gitignore                      # Git ignore rules
├── install-windows.ps1             # Windows installation script
├── install-wsl.sh                  # WSL/Ubuntu installation script
├── .credentials/                   # API key storage
│   ├── .gitkeep
│   ├── anthropic.key.example
│   └── google.key.example
├── scripts/                        # Helper scripts
│   ├── verify-installation.ps1
│   ├── verify-installation.sh
│   └── test-all-environments.ps1
└── bugFix/                         # Practice exercise
    ├── README.md
    ├── pyproject.toml              # UV project configuration
    ├── buggy_script.py             # Script with intentional bugs
    └── SOLUTION.md                 # Bug explanations and fixes
```

## 6. User Workflows

### 6.1 First-Time Setup Workflow

1. User clones or downloads the repository
2. User reads README.md Quick Start section
3. User runs appropriate installation script:
   - Windows: `.\install-windows.ps1` in PowerShell (Admin)
   - WSL: `bash install-wsl.sh`
4. Scripts check prerequisites and install missing components
5. User creates API keys following README instructions
6. User stores keys in `.credentials/` directory
7. User runs verification script
8. User completes bugFix practice exercise

**Estimated Time**: 15-30 minutes

### 6.2 API Key Setup Workflow

1. User visits console.anthropic.com
2. User creates account or logs in
3. User navigates to API Keys section
4. User generates new key with descriptive name
5. User copies key to `.credentials/anthropic.key`
6. Repeat for Google AI Studio (aistudio.google.com)
7. User verifies keys are gitignored

### 6.3 bugFix Exercise Workflow

1. User navigates to `~/bugFix/` in WSL
2. User activates UV environment: `uv venv && source .venv/bin/activate`
3. User runs buggy script: `python buggy_script.py`
4. User identifies errors
5. User invokes Claude Code: `npx @anthropic-ai/claude-code`
6. User requests AI assistance with specific bugs
7. User applies fixes and re-tests
8. User compares with SOLUTION.md

## 7. Non-Functional Requirements

### 7.1 Performance

- Installation scripts complete in < 10 minutes on standard hardware
- No unnecessary dependencies or bloat
- Minimal disk space usage (< 500MB excluding Node.js)

### 7.2 Reliability

- Scripts handle interruptions gracefully
- Idempotent execution (safe to run multiple times)
- Clear error messages with remediation steps

### 7.3 Usability

- README written at 8th-grade reading level
- Visual aids (screenshots) for complex steps
- Copy-paste ready commands
- No assumed prior knowledge beyond basic terminal usage

### 7.4 Maintainability

- Modular script design
- Commented code explaining complex logic
- Version-pinned dependencies where critical
- Update instructions in CLAUDE.MD

## 8. Success Metrics

### 8.1 Installation Success Rate

- **Target**: 95% of users complete installation without support
- **Measurement**: Survey or automated telemetry (if implemented)

### 8.2 Time to First AI Command

- **Target**: < 30 minutes from download to running first AI CLI command
- **Measurement**: User feedback and testing

### 8.3 Cross-Environment Functionality

- **Target**: 100% of tools work in all three environments
- **Measurement**: Automated verification script results

### 8.4 Documentation Clarity

- **Target**: < 5% of users require additional documentation
- **Measurement**: GitHub issues, support requests

## 9. Future Enhancements (Out of Scope for v1.0)

- Automated updates for CLI tools
- Configuration profiles for different use cases
- Integration with VS Code and other IDEs
- Docker containerized environment option
- Linux native and macOS support
- Telemetry for usage patterns (with opt-in)
- Additional practice exercises (API integration, code refactoring)

## 10. Dependencies & Assumptions

### 10.1 External Dependencies

- Anthropic API service availability
- Google AI API service availability
- Node.js LTS support
- WSL availability in Windows 10/11
- Internet connectivity for downloads

### 10.2 Assumptions

- User has Windows 10 version 2004 or higher (for WSL2)
- User has at least 10GB free disk space
- User has administrator access for Windows installations
- User has valid email for API key registration

## 11. Risks & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| API breaking changes | High | Medium | Version pin CLIs; provide update docs |
| WSL compatibility issues | High | Low | Test on multiple Windows versions |
| API key exposure | Critical | Medium | Strong .gitignore; user education |
| Installation script failures | Medium | Medium | Comprehensive error handling |
| Documentation outdated | Medium | High | Regular review cycle; automated checks |

## 12. Acceptance Criteria

The project is complete when:

- ✅ All installation scripts execute successfully on clean Windows 10/11 systems
- ✅ Claude Code CLI works in CMD, PowerShell, and WSL Ubuntu
- ✅ Gemini CLI works in CMD, PowerShell, and WSL Ubuntu
- ✅ README.md covers all required topics with clear examples
- ✅ API keys are properly secured and gitignored
- ✅ bugFix exercise is completable using installed tools
- ✅ Verification scripts confirm all tools are functional
- ✅ Documentation is reviewed by at least one non-technical user
- ✅ All PRD requirements are met

## 13. Approval

**Document Version**: 1.0  
**Last Updated**: 2025-11-03  
**Status**: Draft → Ready for Implementation

---

**Next Steps**:
1. Review and approve PRD
2. Create CLAUDE.MD training document
3. Develop PLANNING.MD architecture
4. Populate TASKS.MD with implementation tasks
5. Begin development with highest priority tasks
