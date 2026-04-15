# Local SEO Skills uninstaller for Windows (PowerShell).
#
# Removes $HOME\.claude\skills\localseoskills. By default, any briefs\ directory
# (client data) is backed up to $HOME\.claude\lss-briefs-backup-<timestamp>
# before removal. Pass -NoBackup to skip the backup step.
#
# Compatible with PowerShell 5.1 and PowerShell 7+.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File uninstall.ps1
#   powershell -ExecutionPolicy Bypass -File uninstall.ps1 -Force
#   powershell -ExecutionPolicy Bypass -File uninstall.ps1 -NoBackup

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$NoBackup
)

$ErrorActionPreference = "Stop"

try { [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new() } catch {}

$InstallDir = if ($env:LSS_INSTALL_DIR) { $env:LSS_INSTALL_DIR } else { Join-Path $HOME ".claude\skills\localseoskills" }

function Say($msg)  { Write-Host "> $msg" -ForegroundColor Green }
function Fail($msg) { Write-Host "x $msg" -ForegroundColor Red; exit 1 }

function Remove-Path {
    param([string]$Path)
    # Strip only the ReadOnly bit on anything inside .git that Windows won't
    # let Remove-Item delete. Setting Attributes = 'Normal' would also clear
    # the Directory bit, which throws on directories.
    Get-ChildItem -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue |
        ForEach-Object {
            try {
                $_.Attributes = $_.Attributes -band (-bnot [System.IO.FileAttributes]::ReadOnly)
            } catch {}
        }
    # PS 5.1 Remove-Item doesn't auto-opt into Windows long-path APIs, so paths
    # over MAX_PATH (260 chars) fail on files inside .git/objects/pack/.
    # Prefix local drive-letter paths with \\?\ so the Unicode long-path
    # entrypoints are used. The uninstall safety guards already refuse
    # non-drive-letter targets on Windows, so scoping to drive letters is safe.
    $nativePath = if ($Path -match '^[A-Za-z]:\\' -and -not $Path.StartsWith('\\?\')) {
        "\\?\$Path"
    } else {
        $Path
    }
    Remove-Item -LiteralPath $nativePath -Recurse -Force
}

function Backup-Briefs {
    param([string]$Dir)
    $briefs = Join-Path $Dir "briefs"
    if (-not (Test-Path $briefs)) { return }
    $parent = Join-Path $HOME ".claude"
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $ts  = Get-Date -Format "yyyyMMdd-HHmmss"
    $dst = Join-Path $parent "lss-briefs-backup-$ts"
    $n = 1
    while (Test-Path $dst) {
        $dst = Join-Path $parent "lss-briefs-backup-$ts-$n"
        $n++
    }
    Say "Backing up briefs to $dst"
    Copy-Item -Recurse -Force $briefs $dst
}

function Test-SafePath {
    param([string]$Path)
    # Refuse catastrophic targets: empty, too short, root drives, $HOME,
    # or common system roots. Protects against LSS_INSTALL_DIR=/ or =$HOME
    # followed by -Force, plus traversal attacks like $HOME\..\..\Windows
    # that normalize to a system root.
    if ([string]::IsNullOrWhiteSpace($Path)) {
        Fail "Refusing to operate on empty path."
    }
    if ($Path.Length -lt 10) {
        Fail "Refusing to operate on suspiciously short path: $Path"
    }
    $dangerous = @(
        $HOME,
        (Join-Path $HOME ""),
        "C:\", "D:\", "E:\", "F:\",
        "/", "/root", "/home", "/Users",
        "/usr", "/etc", "/var", "/tmp",
        "/bin", "/sbin", "/opt", "/boot",
        "/dev", "/proc", "/sys", "/lib",
        "/mnt", "/srv",
        $env:USERPROFILE,
        $env:SystemDrive,
        $env:SystemRoot,
        "C:\Windows",
        "C:\Users",
        "C:\Program Files",
        "C:\Program Files (x86)",
        "C:\ProgramData"
    ) | Where-Object { $_ }

    # Check both the raw input and the Resolve-Path result. Resolve-Path
    # canonicalizes .. segments and symlinks; without this, an attacker can
    # bypass the blocklist with input like $HOME\..\..\Windows.
    $candidates = @($Path)
    try {
        $canonical = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path
        if ($canonical -and $canonical -ne $Path) { $candidates += $canonical }
    } catch {
        # Path doesn't exist yet; raw check is enough.
    }

    foreach ($candidate in $candidates) {
        $normalized = $candidate.TrimEnd('\','/')
        foreach ($d in $dangerous) {
            if ($normalized -eq $d.TrimEnd('\','/')) {
                Fail "Refusing to operate on dangerous path: $Path (resolves to $candidate)"
            }
        }
    }
}

function Main {
    Test-SafePath $InstallDir

    if (-not (Test-Path $InstallDir)) {
        Say "Nothing to uninstall at $InstallDir"
        exit 0
    }

    if (-not $Force) {
        $answer = Read-Host "This will delete $InstallDir. Type 'yes' to continue"
        if ($answer -ne "yes") {
            Fail "Aborted."
        }
    }

    if (-not $NoBackup) {
        Backup-Briefs $InstallDir
    }

    Remove-Path $InstallDir
    Say "Removed $InstallDir"
}

Main
