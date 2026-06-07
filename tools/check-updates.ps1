param(
    [string]$Root = (Resolve-Path ".").Path,
    [switch]$FailOnUpdates,
    [switch]$UseFixtureVersions
)

$ErrorActionPreference = "Stop"

function Get-NpmVersion {
    param([string]$PackageName)
    $encodedPackage = [System.Uri]::EscapeDataString($PackageName)
    $response = Invoke-RestMethod -Uri "https://registry.npmjs.org/$encodedPackage/latest" -Headers @{ "User-Agent" = "llm-dev-wiki-update-check" }
    return $response.version
}

function Get-PyPiVersion {
    param([string]$PackageName)
    $response = Invoke-RestMethod -Uri "https://pypi.org/pypi/$PackageName/json" -Headers @{ "User-Agent" = "llm-dev-wiki-update-check" }
    return $response.info.version
}

function Get-GitHubLatestRelease {
    param([string]$Repository)
    $headers = @{
        "Accept" = "application/vnd.github+json"
        "User-Agent" = "llm-dev-wiki-update-check"
    }
    if (-not [string]::IsNullOrWhiteSpace($env:GITHUB_TOKEN)) {
        $headers["Authorization"] = "Bearer $env:GITHUB_TOKEN"
    }
    try {
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repository/releases/latest" -Headers $headers
        return $response.tag_name
    }
    catch {
        return Get-GitHubLatestTag -Repository $Repository
    }
}

function Get-GitHubLatestTag {
    param([string]$Repository)
    $headers = @{
        "Accept" = "application/vnd.github+json"
        "User-Agent" = "llm-dev-wiki-update-check"
    }
    if (-not [string]::IsNullOrWhiteSpace($env:GITHUB_TOKEN)) {
        $headers["Authorization"] = "Bearer $env:GITHUB_TOKEN"
    }
    $response = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repository/tags?per_page=1" -Headers $headers
    if ($response.Count -eq 0) {
        return ""
    }
    return $response[0].name
}

function Get-EntryVersion {
    param($Entry)

    if ($UseFixtureVersions) {
        $fixtureVersion = Get-FixtureVersion -Entry $Entry
        if ($null -ne $fixtureVersion) {
            if ($fixtureVersion -eq "__ERROR__") {
                throw "Fixture forced update check failure for $($Entry.name)"
            }
            return $fixtureVersion
        }
    }

    switch ($Entry.ecosystem) {
        "npm" { return Get-NpmVersion -PackageName $Entry.package }
        "pypi" { return Get-PyPiVersion -PackageName $Entry.package }
        "github-releases" { return Get-GitHubLatestRelease -Repository $Entry.repository }
        "github-tags" { return Get-GitHubLatestTag -Repository $Entry.repository }
        "manual" { return "manual-check" }
        default { throw "Unsupported ecosystem: $($Entry.ecosystem)" }
    }
}

function Get-FixtureVersion {
    param($Entry)

    if ([string]::IsNullOrWhiteSpace($env:LLM_DEV_WIKI_UPDATE_FIXTURES_JSON)) {
        return $null
    }

    $fixtures = $env:LLM_DEV_WIKI_UPDATE_FIXTURES_JSON | ConvertFrom-Json
    $packageOrRepo = if ($Entry.package) { [string]$Entry.package } elseif ($Entry.repository) { [string]$Entry.repository } else { "" }
    $key = "$($Entry.ecosystem):$packageOrRepo"
    if ($fixtures.PSObject.Properties.Name.Contains($key)) {
        return [string]$fixtures.$key
    }

    return $null
}

function Test-PrereleaseVersion {
    param([string]$Version)

    if ([string]::IsNullOrWhiteSpace($Version)) {
        return $false
    }

    return $Version -match '(?i)(^|[.\-+_])(?:rc|alpha|beta|preview|pre|canary|dev|nightly|snapshot)(?:[.\-+_0-9]|$)'
}

function Get-VersionPolicy {
    param($Entry)

    if (-not $Entry.PSObject.Properties.Name.Contains("versionPolicy") -or [string]::IsNullOrWhiteSpace([string]$Entry.versionPolicy)) {
        return "stable"
    }

    return ([string]$Entry.versionPolicy).Trim()
}

$rootPath = Resolve-Path -LiteralPath $Root
$watchlistPath = Join-Path $rootPath "resources/technology-watchlist.json"

if (-not (Test-Path -LiteralPath $watchlistPath)) {
    throw "Missing watchlist: $watchlistPath"
}

$entries = Get-Content -Raw -LiteralPath $watchlistPath | ConvertFrom-Json
$checkedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss 'UTC'")
$updatesFound = 0
$errorCount = 0
$rows = [System.Collections.Generic.List[string]]::new()

foreach ($entry in $entries) {
    $currentVersion = if ($entry.currentVersion) { [string]$entry.currentVersion } else { "" }
    $latestVersion = ""
    $status = "ok"

    try {
        $latestVersion = Get-EntryVersion -Entry $entry
        $versionPolicy = Get-VersionPolicy -Entry $entry
        if ($entry.ecosystem -eq "manual") {
            $status = "manual"
        }
        elseif ($versionPolicy -ne "allow-prerelease" -and (Test-PrereleaseVersion -Version $latestVersion)) {
            $status = "prerelease-ignored"
        }
        elseif (-not [string]::IsNullOrWhiteSpace($currentVersion) -and $currentVersion -ne $latestVersion) {
            $status = "update-available"
            $updatesFound++
        }
    }
    catch {
        if (-not [string]::IsNullOrWhiteSpace($currentVersion)) {
            $latestVersion = $currentVersion
            $status = "check-unavailable"
            $errorCount++
        }
        else {
            $latestVersion = "error"
            $status = "check-failed"
            $errorCount++
        }
    }

    $packageOrRepo = if ($entry.package) { $entry.package } elseif ($entry.repository) { $entry.repository } else { "manual" }
    $docsLink = if ($entry.docsUrl) { "[docs]($($entry.docsUrl))" } else { "" }
    $rows.Add("| $($entry.name) | $($entry.ecosystem) | $packageOrRepo | $currentVersion | $latestVersion | $status | $docsLink |") | Out-Null
}

$report = [System.Collections.Generic.List[string]]::new()
$report.Add("# Technology update report") | Out-Null
$report.Add("") | Out-Null
$report.Add("- Checked at: $checkedAt") | Out-Null
$report.Add("- Entries: $($entries.Count)") | Out-Null
$report.Add("- Updates found: $updatesFound") | Out-Null
$report.Add("- Check failures: $errorCount") | Out-Null
$report.Add("") | Out-Null
$report.Add("| Name | Ecosystem | Package/Repository | Current | Latest | Status | Source |") | Out-Null
$report.Add("|---|---|---|---|---|---|---|") | Out-Null
foreach ($row in $rows) {
    $report.Add($row) | Out-Null
}
$report.Add("") | Out-Null
$report.Add("Manual entries require human review of the linked official documentation.") | Out-Null

$report | ForEach-Object { Write-Output $_ }

if ($FailOnUpdates -and $updatesFound -gt 0) {
    exit 1
}

exit 0
