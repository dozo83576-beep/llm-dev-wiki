param(
    [string]$Root = (Resolve-Path ".").Path
)

$ErrorActionPreference = "Stop"

function Add-Failure {
    param(
        [System.Collections.Generic.List[string]]$Failures,
        [string]$Message
    )

    $Failures.Add($Message) | Out-Null
}

function Test-Contains {
    param(
        [string]$Content,
        [string]$Needle
    )

    return $Content.Contains($Needle)
}

function Test-DoesNotContainAny {
    param(
        [string]$Content,
        [string[]]$Needles
    )

    foreach ($needle in $Needles) {
        if ($Content.Contains($needle)) {
            return $false
        }
    }
    return $true
}

$rootPath = Resolve-Path -LiteralPath $Root
$failures = [System.Collections.Generic.List[string]]::new()

$requiredFiles = @(
    ".github/workflows/wiki-audit.yml",
    ".github/workflows/technology-updates.yml",
    "tools/ci-local.ps1",
    "tools/technology-update-issue.js"
)

foreach ($relativePath in $requiredFiles) {
    $path = Join-Path $rootPath ($relativePath -replace "/", [IO.Path]::DirectorySeparatorChar)
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Add-Failure $failures "Missing required file: $relativePath"
    }
}

$wikiAuditPath = Join-Path $rootPath ".github/workflows/wiki-audit.yml"
$technologyUpdatesPath = Join-Path $rootPath ".github/workflows/technology-updates.yml"
$wikiAudit = ""
$technologyUpdates = ""

if (Test-Path -LiteralPath $wikiAuditPath -PathType Leaf) {
    $wikiAudit = Get-Content -LiteralPath $wikiAuditPath -Raw
}
if (Test-Path -LiteralPath $technologyUpdatesPath -PathType Leaf) {
    $technologyUpdates = Get-Content -LiteralPath $technologyUpdatesPath -Raw
}

if ($wikiAudit) {
    if (-not (Test-Contains $wikiAudit "./tools/ci-local.ps1 -IncludeToolTests -WriteGithubSummary")) {
        Add-Failure $failures "wiki-audit.yml must call ./tools/ci-local.ps1 -IncludeToolTests -WriteGithubSummary"
    }

    $directWikiCiCommands = @(
        "build_embeddings.py",
        "run_offline_retrieval_evals.py"
    )
    if (-not (Test-DoesNotContainAny $wikiAudit $directWikiCiCommands)) {
        Add-Failure $failures "wiki-audit.yml must not call embeddings/evals directly; ci-local.ps1 owns that order"
    }
}

if ($technologyUpdates) {
    if (-not (Test-Contains $technologyUpdates "./tools/ci-local.ps1 -UpdateCheckOnly -IncludeUpdateCheck -WriteGithubSummary")) {
        Add-Failure $failures "technology-updates.yml must call ./tools/ci-local.ps1 -UpdateCheckOnly -IncludeUpdateCheck -WriteGithubSummary"
    }
    if (-not (Test-Contains $technologyUpdates "./tools/technology-update-issue.js")) {
        Add-Failure $failures "technology-updates.yml must use ./tools/technology-update-issue.js"
    }

    $inlineIssueMutations = @(
        "github.rest.issues.create",
        "github.rest.issues.update",
        "github.rest.issues.createComment"
    )
    if (-not (Test-DoesNotContainAny $technologyUpdates $inlineIssueMutations)) {
        Add-Failure $failures "technology-updates.yml must not contain inline GitHub issue mutation calls"
    }

    $blockingWikiCiCommands = @(
        "wiki-audit.ps1",
        "wiki-quality.ps1",
        "build_embeddings.py",
        "run_offline_retrieval_evals.py"
    )
    if (-not (Test-DoesNotContainAny $technologyUpdates $blockingWikiCiCommands)) {
        Add-Failure $failures "technology-updates.yml must not run the full blocking wiki CI"
    }
}

Write-Host "Workflow verification"
foreach ($relativePath in $requiredFiles) {
    Write-Host "- required file: $relativePath"
}
Write-Host "Failures: $($failures.Count)"

foreach ($failure in $failures) {
    Write-Host "- $failure"
}

if ($failures.Count -gt 0) {
    exit 1
}
