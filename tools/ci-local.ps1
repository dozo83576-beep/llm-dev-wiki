param(
    [string]$Root = (Resolve-Path ".").Path,
    [switch]$SkipGeneratedDiffCheck,
    [switch]$IncludeUpdateCheck
)

$ErrorActionPreference = "Stop"

function Invoke-Step {
    param(
        [string]$Name,
        [scriptblock]$Command
    )

    Write-Host ""
    Write-Host "==> $Name"
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "Step failed: $Name"
    }
}

function Assert-CleanGeneratedFile {
    param(
        [string]$Path,
        [string]$FixCommand
    )

    git diff --exit-code -- $Path
    if ($LASTEXITCODE -ne 0) {
        throw "$Path is stale. Run '$FixCommand' locally and commit the result."
    }
}

$rootPath = Resolve-Path -LiteralPath $Root
Push-Location $rootPath
try {
    Invoke-Step "Wiki audit" {
        & powershell -NoProfile -ExecutionPolicy Bypass -File tools/wiki-audit.ps1
    }

    Invoke-Step "Wiki quality" {
        & powershell -NoProfile -ExecutionPolicy Bypass -File tools/wiki-quality.ps1
    }

    Invoke-Step "Build INDEX.md" {
        & powershell -NoProfile -ExecutionPolicy Bypass -File tools/build-index.ps1
    }

    if (-not $SkipGeneratedDiffCheck) {
        Assert-CleanGeneratedFile -Path "docs/INDEX.md" -FixCommand "pwsh tools/ci-local.ps1"
    }

    Invoke-Step "Build offline corpus snapshot" {
        & python tools/build_embeddings.py --mode offline-text
    }

    if (-not $SkipGeneratedDiffCheck) {
        Assert-CleanGeneratedFile -Path "embeddings/manifest.json" -FixCommand "python tools/build_embeddings.py --mode offline-text"
    }

    Invoke-Step "Offline retrieval evals" {
        & python tools/run_offline_retrieval_evals.py --min-precision 0.6 --top-k 5 --top-k-strict 10 --warn-rank 3
    }

    if ($IncludeUpdateCheck) {
        Write-Host ""
        Write-Host "==> Technology update report"
        try {
            & powershell -NoProfile -ExecutionPolicy Bypass -File tools/check-updates.ps1
        }
        catch {
            Write-Warning "Technology update check failed, but local CI remains non-blocking for freshness reports: $_"
        }
    }

    Write-Host ""
    Write-Host "Local CI passed."
}
finally {
    Pop-Location
}
