param(
    [string]$Root = (Resolve-Path ".").Path,
    [switch]$SkipGeneratedDiffCheck,
    [switch]$IncludeUpdateCheck,
    [switch]$IncludeToolTests,
    [switch]$WriteGithubSummary,
    [switch]$UpdateCheckOnly
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
    Write-Host "==> Tool unit tests"
    $global:LASTEXITCODE = 0
    if ($WriteGithubSummary) {
        $report = [System.Collections.Generic.List[string]]::new()
        $report.Add("## Python tool tests") | Out-Null
        $pythonOutput = & python -m pytest tests/tools *>&1
        $pythonStatus = $LASTEXITCODE
        $pythonOutput | ForEach-Object { $report.Add([string]$_) | Out-Null }
        $report.Add("") | Out-Null
        $report.Add("## Node tool tests") | Out-Null
        $nodeOutput = & node --test tests/tools/test_technology_update_issue.js *>&1
        $nodeStatus = $LASTEXITCODE
        $nodeOutput | ForEach-Object { $report.Add([string]$_) | Out-Null }
        $report | Tee-Object -FilePath tool-tests-report.txt
        Write-StepSummary -Title "Tool unit tests" -FilePath "tool-tests-report.txt"
        if ($pythonStatus -ne 0) {
            throw "Step failed: Python tool unit tests"
        }
        if ($nodeStatus -ne 0) {
            throw "Step failed: Node tool unit tests"
        }
    }
    else {
        & python -m pytest tests/tools
        if ($LASTEXITCODE -ne 0) {
            throw "Step failed: Python tool unit tests"
        }
        & node --test tests/tools/test_technology_update_issue.js
        if ($LASTEXITCODE -ne 0) {
            throw "Step failed: Node tool unit tests"
        }
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

function Invoke-TechnologyUpdateCheck {
    Write-Host ""
    Write-Host "==> Technology update report"
    $global:LASTEXITCODE = 0
    try {
        & ./tools/check-updates.ps1 *>&1 | Tee-Object -FilePath technology-update-report.md
        Write-StepSummary -Title "Technology update report" -FilePath "technology-update-report.md"
    }
    catch {
        $message = "Technology update check failed, but freshness reports are non-blocking: $_"
        $fallbackReport = @(
            "# Technology update report",
            "",
            "- Checked at: $((Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss 'UTC'"))",
            "- Entries: 0",
            "- Updates found: 0",
            "- Check failures: 1",
            "",
            $message
        )
        $fallbackReport | Tee-Object -FilePath technology-update-report.md
        Write-StepSummary -Title "Technology update report" -FilePath "technology-update-report.md"
        Write-Warning $message
    }
}

$rootPath = Resolve-Path -LiteralPath $Root
Push-Location $rootPath
try {
    if ($UpdateCheckOnly) {
        if (-not $IncludeUpdateCheck) {
            throw "-UpdateCheckOnly requires -IncludeUpdateCheck."
        }

        Invoke-TechnologyUpdateCheck
        Write-Host ""
        Write-Host "Technology freshness check completed."
        exit 0
    }

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
        Invoke-TechnologyUpdateCheck
    }

    Write-Host ""
    Write-Host "Local CI passed."
}
finally {
    Pop-Location
}
