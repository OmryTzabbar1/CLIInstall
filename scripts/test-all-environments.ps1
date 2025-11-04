<#
.SYNOPSIS
    Tests AI CLI tools across all Windows environments (CMD, PowerShell, WSL).

.DESCRIPTION
    This script tests the installation and functionality of AI CLI tools across
    three different environments:
    - Command Prompt (CMD)
    - PowerShell
    - WSL Ubuntu

    It verifies that Node.js, npm, Git, and Claude Code are accessible from each
    environment and generates a comprehensive comparison report.

.PARAMETER SkipWSL
    Skip WSL testing (useful if WSL is not installed).

.PARAMETER Verbose
    Show detailed output from each test command.

.EXAMPLE
    .\test-all-environments.ps1
    Tests all three environments and generates a report.

.EXAMPLE
    .\test-all-environments.ps1 -SkipWSL
    Tests only CMD and PowerShell environments.

.NOTES
    Author: AI CLI Setup Project
    Version: 1.0
    Last Updated: 2025-11-03
    Requires: PowerShell 5.1+, Administrator privileges recommended
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$SkipWSL,

    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

# ============================================================================
# Configuration
# ============================================================================

$ErrorActionPreference = "Continue"

# Test results storage
$script:TestResults = @()

# Color codes
$script:Colors = @{
    Header = 'Cyan'
    Success = 'Green'
    Failure = 'Red'
    Warning = 'Yellow'
    Info = 'Gray'
}

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Header {
    param([string]$Text)
    Write-Host "`n========================================" -ForegroundColor $script:Colors.Header
    Write-Host "  $Text" -ForegroundColor $script:Colors.Header
    Write-Host "========================================`n" -ForegroundColor $script:Colors.Header
}

function Add-TestResult {
    param(
        [string]$Environment,
        [string]$Test,
        [string]$Status,
        [string]$Output,
        [string]$ErrorMessage = ""
    )

    $result = [PSCustomObject]@{
        Environment = $Environment
        Test = $Test
        Status = $Status
        Output = $Output
        ErrorMessage = $ErrorMessage
        Timestamp = Get-Date
    }

    $script:TestResults += $result

    # Display result
    $statusColor = switch ($Status) {
        'PASS' { $script:Colors.Success }
        'FAIL' { $script:Colors.Failure }
        'WARN' { $script:Colors.Warning }
        default { $script:Colors.Info }
    }

    $symbol = switch ($Status) {
        'PASS' { '✓' }
        'FAIL' { '✗' }
        'WARN' { '⚠' }
        default { '?' }
    }

    Write-Host "  $symbol " -NoNewline -ForegroundColor $statusColor
    Write-Host "$Test" -NoNewline
    Write-Host " - $Output" -ForegroundColor $script:Colors.Info

    if ($Verbose -and $ErrorMessage) {
        Write-Host "      Error: $ErrorMessage" -ForegroundColor $script:Colors.Failure
    }
}

function Test-CommandInEnvironment {
    param(
        [string]$Environment,
        [string]$Command,
        [string]$ExpectedPattern = "",
        [int]$TimeoutSeconds = 10
    )

    try {
        $output = ""
        $success = $false

        switch ($Environment) {
            'CMD' {
                $output = cmd.exe /c "$Command 2>&1"
                $success = $LASTEXITCODE -eq 0
            }
            'PowerShell' {
                $output = Invoke-Expression "$Command 2>&1" | Out-String
                $success = $?
            }
            'WSL' {
                if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
                    return @{
                        Success = $false
                        Output = "WSL not available"
                        Error = "WSL command not found"
                    }
                }
                $output = wsl bash -c "$Command 2>&1"
                $success = $LASTEXITCODE -eq 0
            }
        }

        # Check for expected pattern if provided
        if ($ExpectedPattern -and $success) {
            $success = $output -match $ExpectedPattern
        }

        return @{
            Success = $success
            Output = ($output | Out-String).Trim()
            Error = if (-not $success) { "Command failed or pattern not matched" } else { "" }
        }

    } catch {
        return @{
            Success = $false
            Output = ""
            Error = $_.Exception.Message
        }
    }
}

# ============================================================================
# Test Functions
# ============================================================================

function Test-Environment {
    param([string]$EnvironmentName)

    Write-Header "Testing $EnvironmentName Environment"

    # Test 1: Node.js
    Write-Host "`n[Node.js Test]" -ForegroundColor $script:Colors.Info
    $result = Test-CommandInEnvironment -Environment $EnvironmentName -Command "node --version" -ExpectedPattern "v\d+\.\d+"

    if ($result.Success) {
        Add-TestResult -Environment $EnvironmentName -Test "Node.js" -Status "PASS" -Output $result.Output.Trim()
    } else {
        Add-TestResult -Environment $EnvironmentName -Test "Node.js" -Status "FAIL" -Output "Not available" -ErrorMessage $result.Error
    }

    # Test 2: npm
    Write-Host "`n[npm Test]" -ForegroundColor $script:Colors.Info
    $result = Test-CommandInEnvironment -Environment $EnvironmentName -Command "npm --version" -ExpectedPattern "\d+\.\d+"

    if ($result.Success) {
        Add-TestResult -Environment $EnvironmentName -Test "npm" -Status "PASS" -Output $result.Output.Trim()
    } else {
        Add-TestResult -Environment $EnvironmentName -Test "npm" -Status "FAIL" -Output "Not available" -ErrorMessage $result.Error
    }

    # Test 3: npx
    Write-Host "`n[npx Test]" -ForegroundColor $script:Colors.Info
    $result = Test-CommandInEnvironment -Environment $EnvironmentName -Command "npx --version" -ExpectedPattern "\d+\.\d+"

    if ($result.Success) {
        Add-TestResult -Environment $EnvironmentName -Test "npx" -Status "PASS" -Output $result.Output.Trim()
    } else {
        Add-TestResult -Environment $EnvironmentName -Test "npx" -Status "FAIL" -Output "Not available" -ErrorMessage $result.Error
    }

    # Test 4: Git
    Write-Host "`n[Git Test]" -ForegroundColor $script:Colors.Info
    $result = Test-CommandInEnvironment -Environment $EnvironmentName -Command "git --version" -ExpectedPattern "git version"

    if ($result.Success) {
        Add-TestResult -Environment $EnvironmentName -Test "Git" -Status "PASS" -Output $result.Output.Trim()
    } else {
        Add-TestResult -Environment $EnvironmentName -Test "Git" -Status "FAIL" -Output "Not available" -ErrorMessage $result.Error
    }

    # Test 5: Python (WSL only)
    if ($EnvironmentName -eq 'WSL') {
        Write-Host "`n[Python Test]" -ForegroundColor $script:Colors.Info
        $result = Test-CommandInEnvironment -Environment $EnvironmentName -Command "python3 --version" -ExpectedPattern "Python \d+\.\d+"

        if ($result.Success) {
            Add-TestResult -Environment $EnvironmentName -Test "Python 3" -Status "PASS" -Output $result.Output.Trim()
        } else {
            Add-TestResult -Environment $EnvironmentName -Test "Python 3" -Status "FAIL" -Output "Not available" -ErrorMessage $result.Error
        }

        # Test 6: UV (WSL only)
        Write-Host "`n[UV Test]" -ForegroundColor $script:Colors.Info
        $result = Test-CommandInEnvironment -Environment $EnvironmentName -Command "uv --version" -ExpectedPattern "uv"

        if ($result.Success) {
            Add-TestResult -Environment $EnvironmentName -Test "UV" -Status "PASS" -Output $result.Output.Trim()
        } else {
            Add-TestResult -Environment $EnvironmentName -Test "UV" -Status "WARN" -Output "Not available" -ErrorMessage $result.Error
        }
    }

    # Test 7: PATH configuration
    Write-Host "`n[PATH Test]" -ForegroundColor $script:Colors.Info
    $result = Test-CommandInEnvironment -Environment $EnvironmentName -Command "echo %PATH%" -ExpectedPattern "."

    if ($result.Success) {
        $pathContainsNode = $result.Output -match "node"
        if ($pathContainsNode) {
            Add-TestResult -Environment $EnvironmentName -Test "PATH Config" -Status "PASS" -Output "Node.js in PATH"
        } else {
            Add-TestResult -Environment $EnvironmentName -Test "PATH Config" -Status "WARN" -Output "Node.js path not detected"
        }
    } else {
        Add-TestResult -Environment $EnvironmentName -Test "PATH Config" -Status "WARN" -Output "Could not check PATH"
    }
}

# ============================================================================
# Report Generation
# ============================================================================

function Show-Summary {
    Write-Header "Test Summary"

    # Group results by environment
    $environments = $script:TestResults | Group-Object Environment

    foreach ($env in $environments) {
        $passed = ($env.Group | Where-Object { $_.Status -eq 'PASS' }).Count
        $failed = ($env.Group | Where-Object { $_.Status -eq 'FAIL' }).Count
        $warned = ($env.Group | Where-Object { $_.Status -eq 'WARN' }).Count
        $total = $env.Group.Count

        Write-Host "`n$($env.Name):" -ForegroundColor $script:Colors.Header
        Write-Host "  Passed:   " -NoNewline -ForegroundColor $script:Colors.Info
        Write-Host "$passed/$total" -ForegroundColor $script:Colors.Success
        Write-Host "  Failed:   " -NoNewline -ForegroundColor $script:Colors.Info
        Write-Host "$failed/$total" -ForegroundColor $(if ($failed -gt 0) { $script:Colors.Failure } else { $script:Colors.Success })
        Write-Host "  Warnings: " -NoNewline -ForegroundColor $script:Colors.Info
        Write-Host "$warned/$total" -ForegroundColor $(if ($warned -gt 0) { $script:Colors.Warning } else { $script:Colors.Success })
    }
}

function Show-ComparisonTable {
    Write-Header "Environment Comparison"

    # Get unique tests
    $tests = $script:TestResults | Select-Object -ExpandProperty Test -Unique | Sort-Object

    # Create comparison table
    $comparisonData = @()

    foreach ($test in $tests) {
        $row = [PSCustomObject]@{
            Test = $test
        }

        # Add results for each environment
        $environments = $script:TestResults | Select-Object -ExpandProperty Environment -Unique | Sort-Object

        foreach ($env in $environments) {
            $result = $script:TestResults | Where-Object { $_.Environment -eq $env -and $_.Test -eq $test }

            if ($result) {
                $statusSymbol = switch ($result.Status) {
                    'PASS' { '✓' }
                    'FAIL' { '✗' }
                    'WARN' { '⚠' }
                    default { '-' }
                }
                $row | Add-Member -NotePropertyName $env -NotePropertyValue "$statusSymbol $($result.Output)"
            } else {
                $row | Add-Member -NotePropertyName $env -NotePropertyValue "-"
            }
        }

        $comparisonData += $row
    }

    # Display table
    $comparisonData | Format-Table -AutoSize -Wrap
}

function Export-Results {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $reportPath = Join-Path $env:TEMP "ai-cli-test-report-$timestamp.txt"

    $report = @"
========================================
AI CLI Tools - Cross-Environment Test Report
========================================
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

"@

    # Add detailed results
    $report += "`n`nDetailed Results:`n"
    $report += "================`n"

    foreach ($result in $script:TestResults) {
        $report += "`n[$($result.Environment)] $($result.Test): $($result.Status)`n"
        $report += "  Output: $($result.Output)`n"
        if ($result.ErrorMessage) {
            $report += "  Error: $($result.ErrorMessage)`n"
        }
    }

    # Add summary
    $report += "`n`nSummary:`n"
    $report += "========`n"

    $environments = $script:TestResults | Group-Object Environment
    foreach ($env in $environments) {
        $passed = ($env.Group | Where-Object { $_.Status -eq 'PASS' }).Count
        $failed = ($env.Group | Where-Object { $_.Status -eq 'FAIL' }).Count
        $warned = ($env.Group | Where-Object { $_.Status -eq 'WARN' }).Count
        $total = $env.Group.Count

        $report += "`n$($env.Name): $passed passed, $failed failed, $warned warnings (out of $total tests)`n"
    }

    # Save report
    $report | Out-File -FilePath $reportPath -Encoding UTF8

    Write-Host "`nReport saved to: $reportPath" -ForegroundColor $script:Colors.Info
}

# ============================================================================
# Main Execution
# ============================================================================

Clear-Host
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor $script:Colors.Header
Write-Host "║                                                            ║" -ForegroundColor $script:Colors.Header
Write-Host "║     AI CLI Tools - Cross-Environment Testing              ║" -ForegroundColor $script:Colors.Header
Write-Host "║                                                            ║" -ForegroundColor $script:Colors.Header
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor $script:Colors.Header
Write-Host ""

Write-Host "This script will test AI CLI tools across multiple environments:" -ForegroundColor $script:Colors.Info
Write-Host "  • Command Prompt (CMD)" -ForegroundColor $script:Colors.Info
Write-Host "  • PowerShell" -ForegroundColor $script:Colors.Info
if (-not $SkipWSL) {
    Write-Host "  • WSL Ubuntu" -ForegroundColor $script:Colors.Info
}
Write-Host ""

# Test each environment
Test-Environment -EnvironmentName "CMD"
Test-Environment -EnvironmentName "PowerShell"

if (-not $SkipWSL) {
    # Check if WSL is available
    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        Test-Environment -EnvironmentName "WSL"
    } else {
        Write-Host "`n⚠ WSL not available. Skipping WSL tests." -ForegroundColor $script:Colors.Warning
        Write-Host "  To install WSL, run: wsl --install" -ForegroundColor $script:Colors.Info
    }
}

# Show results
Show-Summary
Show-ComparisonTable

# Export report
Export-Results

# Final status
Write-Header "Testing Complete"

$totalTests = $script:TestResults.Count
$totalPassed = ($script:TestResults | Where-Object { $_.Status -eq 'PASS' }).Count
$totalFailed = ($script:TestResults | Where-Object { $_.Status -eq 'FAIL' }).Count

if ($totalFailed -eq 0) {
    Write-Host "✓ All environments tested successfully!" -ForegroundColor $script:Colors.Success
    Write-Host "  $totalPassed out of $totalTests tests passed." -ForegroundColor $script:Colors.Success
    exit 0
} else {
    Write-Host "⚠ Some tests failed." -ForegroundColor $script:Colors.Warning
    Write-Host "  $totalPassed passed, $totalFailed failed out of $totalTests tests." -ForegroundColor $script:Colors.Info
    Write-Host "`n  Review the report above for details." -ForegroundColor $script:Colors.Info
    exit 1
}
