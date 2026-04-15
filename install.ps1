# Local SEO Skills installer for Windows (PowerShell).
#
# Installs the skills into $HOME\.claude\skills\localseoskills so Claude Code
# and any agent that reads the Agent Skills spec can discover them. If a
# previous install exists, fetches latest and resets cleanly, preserving any
# briefs/ directory (client data) by backing it up first.
#
# Compatible with PowerShell 5.1 (built in to Windows 10/11) and PowerShell 7+.
#
# Usage:
#   git clone https://github.com/garrettjsmith/localseoskills.git
#   powershell -ExecutionPolicy Bypass -File localseoskills\install.ps1
#
# Custom install location:
#   $env:LSS_INSTALL_DIR = "C:\custom\path"
#   powershell -ExecutionPolicy Bypass -File localseoskills\install.ps1
#
# We deliberately do not publish an "irm | iex" one-liner. Review the script
# locally before running it.

$ErrorActionPreference = "Stop"

# Ensure our own Write-Host output renders UTF-8 correctly on Windows PS 5.1.
try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new() } catch {}

$RepoUrl    = "https://github.com/garrettjsmith/localseoskills.git"
$InstallDir = if ($env:LSS_INSTALL_DIR) { $env:LSS_INSTALL_DIR } else { Join-Path $HOME ".claude\skills\localseoskills" }

function Say($msg)  { Write-Host "> $msg" -ForegroundColor Green }
function Fail($msg) { Write-Host "x $msg" -ForegroundColor Red; exit 1 }

function Invoke-Git {
    # $Args is a PowerShell reserved automatic variable. Using $GitArgs avoids
    # shadowing and the subtle misbehavior that causes in PS 5.1.
    param([string[]]$GitArgs)
    # Under $ErrorActionPreference=Stop, PS 5.1 can treat git's progress
    # output on stderr as a terminating error even when the command
    # succeeds. Localize EAP for the duration of the call and cast each
    # record to a plain string so Write-Host never sees an ErrorRecord.
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & git @GitArgs 2>&1 | ForEach-Object { Write-Host ([string]$_) }
    } finally {
        $ErrorActionPreference = $prev
    }
    if ($LASTEXITCODE -ne 0) {
        Fail ("git " + ($GitArgs -join ' ') + " failed with exit code $LASTEXITCODE")
    }
}

function Backup-Briefs {
    param([string]$Dir)
    $briefs = Join-Path $Dir "briefs"
    if (-not (Test-Path $briefs)) { return }

    $backupRoot = Join-Path $HOME ".claude"
    if (-not (Test-Path $backupRoot)) {
        New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    }
    $ts  = Get-Date -Format "yyyyMMdd-HHmmss"
    $dst = Join-Path $backupRoot "lss-briefs-backup-$ts"
    # Collision-safe: append a counter if the target already exists.
    $n = 1
    while (Test-Path $dst) {
        $dst = Join-Path $backupRoot "lss-briefs-backup-$ts-$n"
        $n++
    }
    Say "Backing up briefs to $dst"
    Copy-Item -Recurse -Force $briefs $dst
}

function Install-Fresh {
    # Build the staging directory next to $InstallDir (same volume) so
    # Move-Item doesn't hit cross-drive failures when %TEMP% is on C: and
    # $InstallDir is on D:.
    $parent = Split-Path $InstallDir -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $tmp = Join-Path $parent (".lss-install-" + [System.Guid]::NewGuid().ToString("N").Substring(0,8))
    New-Item -ItemType Directory -Path $tmp -Force | Out-Null
    try {
        Say "Cloning Local SEO Skills"
        # core.longpaths=true lets git clone succeed on Windows even when the
        # resolved path exceeds the legacy 260-character MAX_PATH limit.
        Invoke-Git @("-c", "core.longpaths=true", "clone", "--depth", "1", $RepoUrl, (Join-Path $tmp "localseoskills"))
        # Defense in depth: re-check before the move. The lock should already
        # prevent a concurrent process from creating $InstallDir, but verify.
        if (Test-Path $InstallDir) {
            Fail "$InstallDir appeared mid-install. Remove it and rerun."
        }
        Move-Item -Path (Join-Path $tmp "localseoskills") -Destination $InstallDir
    } finally {
        # Reset read-only bits on any .git objects that Windows would refuse
        # to delete, then clean up staging.
        if (Test-Path $tmp) {
            Get-ChildItem -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue |
                ForEach-Object {
                    try {
                        $_.Attributes = $_.Attributes -band (-bnot [System.IO.FileAttributes]::ReadOnly)
                    } catch {}
                }
            Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
        }
    }
}

function Update-Existing {
    Say "Existing install detected at $InstallDir, updating"
    Backup-Briefs $InstallDir
    $branch = (& git -C "$InstallDir" symbolic-ref --short HEAD 2>$null)
    if (-not $branch) { $branch = "main" }
    Invoke-Git @("-C", $InstallDir, "fetch", "--depth", "1", "origin", $branch)
    Invoke-Git @("-C", $InstallDir, "reset", "--hard", "origin/$branch")
}

function Main {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Fail "git is required but not found. Install git for Windows and try again."
    }

    # Pre-flight writability check. Catches custom LSS_INSTALL_DIR pointing
    # somewhere the user can't write before git or Move-Item give cryptic
    # errors.
    $parent = Split-Path $InstallDir -Parent
    try {
        if (-not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force -ErrorAction Stop | Out-Null
        }
        $probe = Join-Path $parent (".lss-writable-probe-" + [System.Guid]::NewGuid().ToString("N").Substring(0,8))
        New-Item -ItemType File -Path $probe -Force -ErrorAction Stop | Out-Null
        Remove-Item -Path $probe -Force -ErrorAction SilentlyContinue
    } catch {
        Fail "$parent is not writable by this user. Set `$env:LSS_INSTALL_DIR to a user-writable path, or rerun with appropriate permissions."
    }

    # Serialize concurrent installs. New-Item -ItemType Directory fails
    # atomically when the directory exists, which gives us a POSIX-style
    # lock. Set the lock after the writability check and before any work.
    $lockPath = "$InstallDir.lock"
    $lockOwned = $false
    try {
        New-Item -ItemType Directory -Path $lockPath -ErrorAction Stop | Out-Null
        $lockOwned = $true
    } catch {
        Fail "Another install is in progress (lock at $lockPath). If stale, remove it and retry."
    }

    try {
        $gitDir = Join-Path $InstallDir ".git"
        $isGitCheckout = $false
        if (Test-Path $gitDir) {
            # Wrap in try/catch because $ErrorActionPreference=Stop turns git's
            # stderr from a corrupt-repo check into a terminating error on
            # PS 5.1. Swallow it; $isGitCheckout stays false and the next
            # branch Fails cleanly with our intended message.
            try {
                & git -C "$InstallDir" rev-parse --git-dir *> $null
                if ($LASTEXITCODE -eq 0) { $isGitCheckout = $true }
            } catch {
                # intentional: keep $isGitCheckout = $false
            }
        }

        if ($isGitCheckout) {
            Update-Existing
        } elseif (Test-Path $InstallDir) {
            Fail "$InstallDir exists and is not a clean git checkout. Remove it and rerun."
        } else {
            Install-Fresh
        }

        Say "Local SEO Skills installed."
        Write-Host ""
        Write-Host "Next steps:"
        Write-Host "  1. Open Claude Code or your preferred AI agent."
        Write-Host "  2. Connect your data tools via MCP. At minimum, LocalSEOData"
        Write-Host "     (https://localseodata.com). Other supported tools: Local Falcon,"
        Write-Host "     LSA Spy, SerpAPI, Semrush, Ahrefs, BrightLocal, DataForSEO,"
        Write-Host "     Whitespark, Google Search Console, Google Analytics, Screaming Frog."
        Write-Host "  3. Mention any local business to get started. For example:"
        Write-Host "       'Audit Mike''s Plumbing in Buffalo'"
        Write-Host "     The agent will ask 5 questions, run an audit, and set up a"
        Write-Host "     persistent brief for ongoing work."
        Write-Host ""
        Write-Host "Docs:      https://github.com/garrettjsmith/localseoskills"
        Write-Host "Community: https://discord.com/invite/XxVjjuhn"
    } finally {
        # Only release the lock if THIS process acquired it.
        if ($lockOwned -and (Test-Path $lockPath)) {
            Remove-Item -Path $lockPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

Main
