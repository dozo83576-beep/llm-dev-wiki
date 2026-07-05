param(
    [string]$Root = (Resolve-Path ".").Path
)

$ErrorActionPreference = "Stop"

function Invoke-Step {
    param(
        [string]$Name,
        [scriptblock]$Command
    )

    Write-Host ""
    Write-Host "==> $Name"
    $global:LASTEXITCODE = 0
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "Step failed: $Name"
    }
}

function Get-ChangedPath {
    $paths = @()
    $paths += git diff --name-only
    $paths += git diff --cached --name-only
    $paths += git diff --name-only HEAD
    $paths += git ls-files --others --exclude-standard
    return $paths | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique
}

function Test-PipelineOrSkillChange {
    param([string[]]$Paths)

    foreach ($path in $Paths) {
        if (
            $path -like "agent-skills/*" -or
            $path -eq "tools/verify-site-pipeline.ps1" -or
            $path -eq "docs/10-templates/pipeline-status.md" -or
            $path -eq "docs/01-development-process/site-pipeline-map.md"
        ) {
            return $true
        }
    }
    return $false
}

$rootPath = Resolve-Path -LiteralPath $Root
Push-Location $rootPath
try {
    Invoke-Step "Verify site pipeline" {
        & ./tools/verify-site-pipeline.ps1
    }

    Invoke-Step "Targeted pipeline and hook tests" {
        & python -m pytest tests/tools/test_verify_site_pipeline.py tests/tools/test_sync_skills.py tests/tools/test_site_intent_hook.py -q
    }

    $changedPaths = @(Get-ChangedPath)
    if (Test-PipelineOrSkillChange -Paths $changedPaths) {
        Invoke-Step "Sync skills dry-run" {
            & ./agent-skills/sync-skills.ps1 -DryRun
        }

        Invoke-Step "Verify user skill runtimes" {
            & ./tools/verify-agent-skills.ps1 -VerifyUserRuntimes
        }
    }
    else {
        Write-Host ""
        Write-Host "No pipeline or agent-skills changes detected; skipped runtime skill checks."
    }

    Write-Host ""
    Write-Host "Pre-release local gate passed."
}
finally {
    Pop-Location
}
