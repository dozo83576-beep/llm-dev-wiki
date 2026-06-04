param(
    [string]$Root = (Resolve-Path ".").Path,
    [switch]$SkipGeneratedDiffCheck,
    [switch]$IncludeUpdateCheck,
    [switch]$IncludeToolTests,
    [switch]$WriteGithubSummary
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

function Write-StepSummary {
    param(
        [string]$Title,
        [string]$FilePath,
        [string]$InputText
    )

    if (-not $WriteGithubSummary) {
        return
    }

    if (-not [string]::IsNullOrWhiteSpace($FilePath)) {
        & ./tools/write-ci-summary.ps1 -Title $Title -FilePath $FilePath -InputText ""
        return
    }
    if (-not [string]::IsNullOrEmpty($InputText)) {
        & ./tools/write-ci-summary.ps1 -Title $Title -FilePath "" -InputText $InputText
        return
    }

    & ./tools/write-ci-summary.ps1 -Title $Title -FilePath "" -InputText ""
}

function Invoke-ToolTests {
    Write-Host ""
    Write-Host "==> Offline retrieval unit tests"
    $global:LASTEXITCODE = 0
    if ($WriteGithubSummary) {
        & python -m pytest tests/tools *>&1 | Tee-Object -FilePath pytest-report.txt
    }
    else {
        & python -m pytest tests/tools
    }
    $status = $LASTEXITCODE
    Write-StepSummary -Title "Offline retrieval unit tests" -FilePath "pytest-report.txt"
    if ($status -ne 0) {
        throw "Step failed: Offline retrieval unit tests"
    }
}

function Invoke-WikiQuality {
    Write-Host ""
    Write-Host "==> Wiki quality"
    $global:LASTEXITCODE = 0
    if ($WriteGithubSummary) {
        $report = & ./tools/wiki-quality.ps1
    }
    else {
        & ./tools/wiki-quality.ps1
        $status = $LASTEXITCODE
        if ($status -ne 0) {
            throw "Step failed: Wiki quality"
        }
        return
    }
    $status = $LASTEXITCODE
    $report | Tee-Object -FilePath wiki-quality-report.md
    Write-StepSummary -FilePath "wiki-quality-report.md"
    if ($status -ne 0) {
        throw "Step failed: Wiki quality"
    }
}

function Invoke-OfflineRetrievalEvals {
    Write-Host ""
    Write-Host "==> Offline retrieval evals"
    $global:LASTEXITCODE = 0
    & python tools/run_offline_retrieval_evals.py --min-precision 0.6 --top-k 5 --top-k-strict 10 --warn-rank 3
    $status = $LASTEXITCODE
    if (Test-Path -LiteralPath "evals-report.md") {
        Write-StepSummary -Title "Offline retrieval evals" -FilePath "evals-report.md"
    }
    else {
        Write-StepSummary -Title "Offline retrieval evals" -InputText "evals-report.md was not generated."
    }
    if ($status -ne 0) {
        throw "Step failed: Offline retrieval evals"
    }
}

$rootPath = Resolve-Path -LiteralPath $Root
Push-Location $rootPath
try {
    Invoke-Step "Wiki audit" {
        & ./tools/wiki-audit.ps1
    }

    Invoke-WikiQuality

    if ($IncludeToolTests) {
        Invoke-ToolTests
    }

    Invoke-Step "Build INDEX.md" {
        & ./tools/build-index.ps1
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

    Invoke-OfflineRetrievalEvals

    if ($IncludeUpdateCheck) {
        Write-Host ""
        Write-Host "==> Technology update report"
        try {
            & ./tools/check-updates.ps1
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
