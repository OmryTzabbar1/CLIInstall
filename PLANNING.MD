# PLANNING.MD - Architecture & Technical Design

## Table of Contents
1. [System Architecture](#system-architecture)
2. [Technology Choices](#technology-choices)
3. [Directory Structure](#directory-structure)
4. [Installation Flow](#installation-flow)
5. [Security Architecture](#security-architecture)
6. [Cross-Platform Strategy](#cross-platform-strategy)
7. [Error Handling Strategy](#error-handling-strategy)
8. [Testing Strategy](#testing-strategy)

---

## System Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        User's Machine                        │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │              │  │              │  │              │     │
│  │     CMD      │  │  PowerShell  │  │  WSL Ubuntu  │     │
│  │              │  │              │  │              │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                 │                 │              │
│         └─────────────────┴─────────────────┘              │
│                           │                                │
│                           ▼                                │
│              ┌─────────────────────────┐                   │
│              │   Node.js Runtime       │                   │
│              │   (Global Install)      │                   │
│              └──────────┬──────────────┘                   │
│                         │                                  │
│         ┌───────────────┴───────────────┐                 │
│         │                               │                 │
│         ▼                               ▼                 │
│  ┌──────────────┐              ┌──────────────┐          │
│  │  Claude Code │              │  Gemini CLI  │          │
│  │  (npx exec)  │              │  (npm global)│          │
│  └──────┬───────┘              └──────┬───────┘          │
│         │                             │                   │
│         └─────────────┬───────────────┘                   │
│                       │                                   │
│                       ▼                                   │
│              ┌─────────────────┐                         │
│              │  API Keys       │                         │
│              │  (.credentials/) │                         │
│              └─────────────────┘                         │
└─────────────────────────────────────────────────────────────┘
```

### Component Interaction

1. **Installation Scripts** → Install prerequisites → Configure environment
2. **CLI Tools** → Read API keys → Connect to cloud services
3. **Verification Scripts** → Test each component → Report status
4. **bugFix Exercise** → Demonstrate workflow → Validate installation

---

## Technology Choices

### Decision Matrix

| Component | Technology | Rationale | Alternatives Considered |
|-----------|------------|-----------|------------------------|
| Windows Installer | PowerShell | Native to Windows, powerful scripting | Batch files (limited), Python (extra dependency) |
| WSL Installer | Bash | Native to Ubuntu, standard shell | Python (extra dep), zsh (not default) |
| Package Manager (Windows) | winget | Built into Windows 10/11, no extra install | chocolatey (requires install), scoop (less common) |
| Package Manager (WSL) | apt | Default for Ubuntu | snap (less reliable), manual downloads |
| Node.js Version | LTS (via official repos) | Stability, long-term support | Latest (unstable), nvm (extra complexity) |
| Python Environment | UV | Fast, modern, simple | venv (manual), conda (heavy), poetry (overkill) |
| Documentation Format | Markdown | Universal, GitHub-native | RST (less common), HTML (not git-friendly) |

### Dependency Tree

```
ai-cli-setup/
│
├── Windows Environment
│   ├── PowerShell 5.1+ (pre-installed on Windows 10+)
│   ├── winget (pre-installed on Windows 10 1809+)
│   │   └── Node.js LTS
│   │       └── npm
│   │           ├── @anthropic-ai/claude-code (via npx)
│   │           └── @google/generative-ai (if npm package exists)
│   └── Git for Windows
│
├── WSL Environment
│   ├── WSL 2 (requires Windows 10 2004+)
│   │   └── Ubuntu 20.04 or 22.04
│   ├── apt package manager
│   │   ├── Node.js LTS (via NodeSource PPA)
│   │   │   └── npm
│   │   │       ├── @anthropic-ai/claude-code
│   │   │       └── Gemini CLI
│   │   ├── Git
│   │   └── Python 3.9+
│   │       └── pip
│   │           └── uv
│   └── curl (for downloading NodeSource setup script)
│
└── API Credentials (platform-agnostic)
    ├── Anthropic API Key
    └── Google AI API Key
```

---

## Directory Structure

### Complete File Tree

```
ai-cli-setup/
│
├── README.md                           # User-facing documentation (main entry point)
├── PRD.md                              # Product requirements (this defines what to build)
├── CLAUDE.MD                           # AI assistant training guide
├── PLANNING.MD                         # This file - architecture and design
├── TASKS.MD                            # Task tracking and progress
├── .gitignore                          # Git ignore rules (critical for security)
│
├── install-windows.ps1                 # Main Windows installation script
├── install-wsl.sh                      # Main WSL installation script
│
├── .credentials/                       # API key storage (gitignored)
│   ├── .gitkeep                        # Keeps directory in git
│   ├── README.md                       # Instructions for this directory
│   ├── anthropic.key.example           # Template for Claude API key
│   └── google.key.example              # Template for Gemini API key
│
├── scripts/                            # Helper and verification scripts
│   ├── verify-installation.ps1         # Windows verification
│   ├── verify-installation.sh          # WSL verification
│   ├── test-all-environments.ps1       # Cross-environment test (Windows only)
│   └── helpers/
│       ├── check-prerequisites.ps1     # Prereq checker for Windows
│       └── check-prerequisites.sh      # Prereq checker for WSL
│
├── bugFix/                             # Practice exercise directory
│   ├── README.md                       # Exercise instructions
│   ├── pyproject.toml                  # UV project configuration
│   ├── .python-version                 # Python version for UV
│   ├── buggy_script.py                 # Script with intentional bugs
│   ├── SOLUTION.md                     # Solutions and explanations
│   └── tests/
│       └── test_fixed_script.py        # Tests to verify fixes
│
├── docs/                               # Additional documentation
│   ├── API_KEY_SETUP.md                # Detailed API key instructions
│   ├── WSL_SETUP.md                    # WSL installation guide
│   ├── TROUBLESHOOTING.md              # Common issues and solutions
│   └── images/                         # Screenshots and diagrams
│       ├── anthropic-console.png
│       ├── google-ai-studio.png
│       └── wsl-terminal.png
│
└── examples/                           # Usage examples
    ├── claude-code-examples.md
    └── gemini-cli-examples.md
```

### Directory Responsibilities

#### Root Level
- **Configuration files**: README, .gitignore, documentation
- **Main executables**: Installation scripts
- **Project management**: PRD, CLAUDE.MD, PLANNING.MD, TASKS.MD

#### `.credentials/`
- **Purpose**: Secure storage for API keys
- **Git Strategy**: Directory tracked, contents ignored (except .gitkeep and .example files)
- **Security**: Most critical directory for .gitignore

#### `scripts/`
- **Purpose**: Modular helper scripts
- **Design**: Reusable functions that main installers can call
- **Testing**: Each script should be testable independently

#### `bugFix/`
- **Purpose**: Hands-on learning exercise
- **Design**: Self-contained Python project
- **Location**: Also copied to `~/bugFix/` in WSL for user convenience

#### `docs/`
- **Purpose**: Extended documentation beyond README
- **Design**: Topic-specific guides with screenshots
- **Maintenance**: Update when APIs or processes change

#### `examples/`
- **Purpose**: Copy-paste ready usage examples
- **Design**: Real-world scenarios users will encounter
- **Format**: Markdown with code blocks and expected outputs

---

## Installation Flow

### Windows Installation Flow (install-windows.ps1)

```
START
  │
  ▼
┌─────────────────────────────────────┐
│ Check Execution Policy              │
│ (Needs RemoteSigned or Unrestricted)│
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Detect Administrator Privileges     │
│ (Required for winget installs)      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Check Prerequisites                 │
│ - winget installed?                 │
│ - Internet connection?              │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Install/Update Node.js              │
│ - Check current version             │
│ - Install LTS if missing            │
│ - Add to PATH                       │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Install Git for Windows             │
│ - Check if installed                │
│ - Install via winget                │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Configure npm for CLI Tools         │
│ - Test npx functionality            │
│ - Install global packages if needed │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Setup .credentials Directory        │
│ - Create if not exists              │
│ - Copy template files               │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Verify Installation                 │
│ - Run verification script           │
│ - Report results                    │
└──────────────┬──────────────────────┘
               │
               ▼
             END
         (Success!)
```

### WSL Installation Flow (install-wsl.sh)

```
START
  │
  ▼
┌─────────────────────────────────────┐
│ Check WSL Environment               │
│ - Is this running in WSL?           │
│ - Ubuntu distribution?              │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Update Package Lists                │
│ - sudo apt update                   │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Install Build Essentials            │
│ - build-essential                   │
│ - curl, wget, git                   │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Install Node.js via NodeSource      │
│ - Download setup script             │
│ - Add PPA repository                │
│ - Install nodejs package            │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Install Python and pip              │
│ - python3, python3-pip              │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Install UV Package Manager          │
│ - pip install uv                    │
│ - Add to PATH in .bashrc            │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Setup bugFix Exercise               │
│ - Create ~/bugFix directory         │
│ - Copy exercise files               │
│ - Initialize UV project             │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Configure Shell Environment         │
│ - Update .bashrc with PATH changes  │
│ - Source .bashrc                    │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Setup .credentials Directory        │
│ - Create symlink to Windows side    │
│   OR copy template files            │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Verify Installation                 │
│ - Run verification script           │
│ - Report results                    │
└──────────────┬──────────────────────┘
               │
               ▼
             END
         (Success!)
```

### Cross-Environment Verification Flow

```
START (test-all-environments.ps1 on Windows)
  │
  ▼
┌─────────────────────────────────────┐
│ Test CMD Environment                │
│ - Launch cmd.exe                    │
│ - Run: npx @anthropic-ai/claude-code│
│ - Run: gemini-cli (if applicable)   │
│ - Capture output                    │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Test PowerShell Environment         │
│ - Already in PowerShell             │
│ - Run: npx @anthropic-ai/claude-code│
│ - Run: gemini-cli                   │
│ - Capture output                    │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Test WSL Environment                │
│ - Launch: wsl bash -c "command"     │
│ - Run: npx @anthropic-ai/claude-code│
│ - Run: gemini-cli                   │
│ - Capture output                    │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│ Generate Report                     │
│ - Environment: ✅ or ❌              │
│ - Command: ✅ or ❌                  │
│ - Error details if any              │
└──────────────┬──────────────────────┘
               │
               ▼
             END
    (Display Results)
```

---

## Security Architecture

### Threat Model

| Threat | Risk Level | Mitigation |
|--------|-----------|------------|
| API key committed to git | Critical | .gitignore patterns, education, template system |
| API key in script output | High | Sanitize all script output, use placeholders |
| Key storage in plaintext | Medium | Document encryption recommendations, OS keychain integration (future) |
| Malicious script execution | Medium | Code review, official sources only, script signing (future) |
| Path traversal in scripts | Low | Validate all paths, use absolute paths |

### Defense in Depth

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: Prevention (Before Keys Are Created)               │
│ - Documentation warns about key security                    │
│ - Templates show structure without real keys                │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 2: Technical Controls (.gitignore)                    │
│ - Comprehensive patterns                                    │
│ - Tested against common mistakes                           │
│ - Comments explaining each pattern                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 3: Detection (Git Hooks - Future)                     │
│ - Pre-commit hook scans for key patterns                   │
│ - Warns user if suspicious content found                   │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 4: Response (CLAUDE.MD Emergency Protocol)            │
│ - Clear instructions if keys are exposed                   │
│ - Immediate revocation steps                               │
│ - Key rotation procedure                                   │
└─────────────────────────────────────────────────────────────┘
```

### API Key Management Strategy

**Storage Options Evaluated**:

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| Environment Variables | Standard, works everywhere | Complex setup for users | No (too difficult) |
| Config Files (.credentials/) | Simple, git-ignorable | Plaintext on disk | **YES** (best UX) |
| OS Keychain | Secure encryption | Platform-specific, complex setup | Future enhancement |
| Encrypted Files | Secure | Requires password management | Too complex for v1.0 |

**Chosen Approach**: `.credentials/` directory with plaintext files
- **Rationale**: Simplicity for target users (beginners)
- **Mitigations**: Strong .gitignore, user education, template system
- **Future**: Add keychain integration as opt-in advanced feature

### .gitignore Strategy

**Philosophy**: Fail-safe defaults

```gitignore
# Priority 1: Exact matches (highest specificity)
.credentials/anthropic.key
.credentials/google.key
.env

# Priority 2: Pattern matches (catch variations)
*.key
*_key.txt
*-key.json
api_key*

# Priority 3: Directory exclusions (broad protection)
.credentials/*
!.credentials/.gitkeep
!.credentials/*.example
!.credentials/README.md

# Explanation comments for each section
# Testing: Verify with `git check-ignore -v <file>`
```

**Testing Protocol**:
1. Create test files matching each pattern
2. Run `git status` - they should NOT appear
3. Run `git check-ignore -v <file>` - should show match
4. Test negation patterns (`.example` files SHOULD be tracked)

---

## Cross-Platform Strategy

### Challenges

| Challenge | Windows (CMD/PS) | WSL Ubuntu | Solution |
|-----------|-----------------|------------|----------|
| Path Separators | Backslash `\` | Forward slash `/` | Use platform-agnostic commands |
| Line Endings | CRLF (`\r\n`) | LF (`\n`) | Git autocrlf, .gitattributes |
| Command Availability | `dir`, `type` | `ls`, `cat` | Use Node.js scripts where possible |
| Package Managers | winget, chocolatey | apt | Environment-specific installers |
| PATH Syntax | `;` separator | `:` separator | Modify per environment |
| Case Sensitivity | Case-insensitive | Case-sensitive | Consistent lowercase naming |

### Abstraction Layers

**Principle**: Use cross-platform tools when possible

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: Node.js & npm (Works Everywhere)                   │
│ - npx @anthropic-ai/claude-code                             │
│ - npm install -g <package>                                  │
│ - node scripts/helper.js                                    │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 2: Git (Cross-Platform)                               │
│ - git init, clone, add, commit                              │
│ - git config (same syntax everywhere)                       │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 3: Platform-Specific (When Necessary)                 │
│ - PowerShell: Get-Command, Test-Path                        │
│ - Bash: command -v, [ -f ... ]                              │
└─────────────────────────────────────────────────────────────┘
```

### Testing Strategy

**Matrix Testing**:

```
          │  CMD  │  PowerShell  │  WSL Ubuntu  │
──────────┼───────┼──────────────┼──────────────┤
Node.js   │   ✓   │      ✓       │      ✓       │
npm       │   ✓   │      ✓       │      ✓       │
Claude    │   ✓   │      ✓       │      ✓       │
Gemini    │   ✓   │      ✓       │      ✓       │
Git       │   ✓   │      ✓       │      ✓       │
UV        │   ✗   │      ✗       │      ✓       │
bugFix    │   ✗   │      ✗       │      ✓       │
```

**Test Environments**:
- Windows 10 21H2 (minimum supported)
- Windows 11 22H2 (latest)
- WSL Ubuntu 20.04 LTS
- WSL Ubuntu 22.04 LTS

---

## Error Handling Strategy

### Error Categories

1. **Recoverable Errors** (Script continues with warning)
   - Tool already installed
   - Non-critical features unavailable
   - Optional dependencies missing

2. **Fatal Errors** (Script stops with clear message)
   - No internet connection
   - Missing critical prerequisites
   - Insufficient permissions

3. **User Errors** (Script provides guidance)
   - Invalid API key format
   - Incorrect command syntax
   - Missing required files

### Error Message Format

**Template**:
```
❌ [ERROR_CODE] Error Type
────────────────────────────────────────
Problem:  <What went wrong>
Cause:    <Why it happened>
Solution: <How to fix it>
────────────────────────────────────────
Details: <Technical details if helpful>
```

**Example**:
```
❌ [NODE_001] Node.js Installation Failed
────────────────────────────────────────
Problem:  Node.js could not be installed via winget
Cause:    Either winget is not available or network connection failed
Solution: 
  1. Check internet connection
  2. Try manual install: https://nodejs.org/
  3. Or install winget: ms-appinstaller:?source=...
────────────────────────────────────────
Details: winget exit code: 0x80070490
```

### Logging Strategy

**Levels**:
- `INFO`: General progress updates
- `WARN`: Non-critical issues
- `ERROR`: Fatal problems
- `DEBUG`: Detailed technical info (optional flag)

**Log File Location**:
- Windows: `%TEMP%\ai-cli-setup-YYYYMMDD-HHMMSS.log`
- WSL: `/tmp/ai-cli-setup-YYYYMMDD-HHMMSS.log`

**Retention**: Auto-delete logs older than 7 days

---

## Testing Strategy

### Test Pyramid

```
                    ┌─────────────┐
                    │   Manual    │  Manual verification by humans
                    │  Testing    │  (Final check before release)
                    └─────────────┘
                 ┌───────────────────┐
                 │   Integration     │  Cross-environment testing
                 │     Testing       │  (Verify components work together)
                 └───────────────────┘
            ┌─────────────────────────────┐
            │       Unit Testing          │  Individual functions/modules
            │   (PowerShell Pester,       │  (Fast, automated)
            │    Bash assert commands)    │
            └─────────────────────────────┘
```

### Test Scenarios

#### Unit Tests (Fast, Frequent)
```powershell
# Example: test-prerequisites.ps1
Describe "Prerequisite Checks" {
    It "Should detect Node.js if installed" {
        Mock Get-Command { return @{Name="node"} }
        Test-NodeJsInstalled | Should -Be $true
    }
    
    It "Should return false if Node.js not installed" {
        Mock Get-Command { throw }
        Test-NodeJsInstalled | Should -Be $false
    }
}
```

#### Integration Tests (Moderate Speed)
- Install on fresh Windows Sandbox
- Install on fresh WSL instance
- Verify all tools accessible from all environments
- Test with real API keys (in secure test environment)

#### Manual Tests (Slow, Pre-Release)
- Follow README from scratch
- Have non-technical person attempt installation
- Test on different Windows versions
- Test with various starting configurations (some tools pre-installed)

### Continuous Validation

**Pre-Commit Checks**:
- [ ] All shell scripts pass ShellCheck
- [ ] All PowerShell scripts pass PSScriptAnalyzer
- [ ] All Markdown passes markdownlint
- [ ] .gitignore tested with sample files
- [ ] No API keys in commit

**Pre-Release Checks**:
- [ ] README instructions tested step-by-step
- [ ] All scripts tested on clean VM
- [ ] All three environments verified working
- [ ] API key instructions tested with fresh accounts
- [ ] bugFix exercise completable

---

## Performance Considerations

### Installation Time Targets

| Component | Target Time | Acceptable Max |
|-----------|-------------|----------------|
| Prerequisite checks | < 5 seconds | 10 seconds |
| Node.js installation | < 3 minutes | 5 minutes |
| CLI tool setup | < 1 minute | 2 minutes |
| Full installation | < 10 minutes | 15 minutes |

### Optimization Strategies

1. **Parallel Downloads**: Where possible, download packages simultaneously
2. **Skip Redundant Checks**: Cache results of expensive checks
3. **Minimal Dependencies**: Only install what's necessary
4. **Progress Indicators**: Show user that work is happening

### Resource Usage

**Disk Space**:
- Node.js: ~200 MB
- Git: ~300 MB
- CLI tools: ~50 MB
- Total: ~550 MB

**Network**:
- Initial download: ~500 MB
- Ongoing usage: Minimal (API calls only)

---

## Future Architecture Considerations

### Scalability

**Adding New CLI Tools**:
1. Update PRD.md requirements
2. Add installation logic to scripts
3. Update verification scripts
4. Add to test matrix
5. Document in README

**Design Principle**: Keep installation modular so new tools don't break existing ones

### Extensibility Points

```
┌─────────────────────────────────────────────────────────────┐
│ Plugin System (Future)                                       │
│ - scripts/plugins/                                          │
│ - Each plugin: install.ps1, install.sh, verify.ps1, etc.   │
│ - Main installer discovers and runs plugins                 │
└─────────────────────────────────────────────────────────────┘
```

### Maintainability

**Version Management**:
- Pin Node.js to LTS version (update annually)
- Document CLI tool version requirements
- Test against multiple versions

**Deprecation Strategy**:
- Mark deprecated features in README
- Provide migration path
- Keep deprecated code for 2 release cycles minimum

---

## Architectural Decisions Record (ADR)

### ADR-001: Use PowerShell instead of Batch for Windows

**Context**: Need reliable Windows installer

**Decision**: Use PowerShell

**Rationale**:
- More powerful error handling
- Better support for modern Windows features
- Easier to maintain
- Native Windows 10/11 support

**Consequences**:
- Requires execution policy change (documented in README)
- Some users may be unfamiliar with PowerShell

**Status**: Accepted

---

### ADR-002: Store API Keys in Plaintext Files

**Context**: Need simple but secure key storage

**Decision**: Use `.credentials/` directory with plaintext files

**Rationale**:
- Simplest UX for target users (beginners)
- Works across all platforms identically
- Easy to gitignore
- No dependencies on OS-specific features

**Consequences**:
- Keys stored unencrypted on disk
- Relies on user following best practices
- Requires strong .gitignore rules

**Status**: Accepted (with future keychain integration planned)

---

### ADR-003: Separate Installation Scripts per Environment

**Context**: Need cross-platform installation

**Decision**: Create separate `install-windows.ps1` and `install-wsl.sh`

**Rationale**:
- Different package managers require different logic
- Easier to maintain and test
- Users run script for their current environment
- Clear separation of concerns

**Consequences**:
- Some code duplication (mitigated by modular helpers)
- Must keep both scripts in sync for shared logic

**Status**: Accepted

---

### ADR-004: Use UV for Python Environment Management

**Context**: Need Python environment management for bugFix exercise

**Decision**: Use UV instead of venv/conda/poetry

**Rationale**:
- Fast (Rust-based)
- Simple CLI
- Modern tooling
- Good documentation

**Consequences**:
- Relatively new tool (less community support)
- May need to update if UV makes breaking changes

**Status**: Accepted (monitoring UV development)

---

## Conclusion

This architecture prioritizes:
1. **User Experience**: Simple, clear, forgiving
2. **Security**: Strong defaults, clear warnings
3. **Maintainability**: Modular, documented, testable
4. **Cross-Platform**: Works identically across environments

**Next Steps**: Proceed to TASKS.MD for implementation breakdown

---

**Document Version**: 1.0  
**Last Updated**: 2025-11-03  
**Status**: Active
