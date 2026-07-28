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
    param(
        [string]$Repository,
        [switch]$AllowPrerelease,
        $FixturePayload = $null
    )

    if ($null -ne $FixturePayload) {
        if ($FixturePayload -is [string]) {
            return [string]$FixturePayload
        }
        $response = $FixturePayload
    }
    else {
        $headers = @{
            "Accept" = "application/vnd.github+json"
            "User-Agent" = "llm-dev-wiki-update-check"
        }
        if (-not [string]::IsNullOrWhiteSpace($env:GITHUB_TOKEN)) {
            $headers["Authorization"] = "Bearer $env:GITHUB_TOKEN"
        }
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repository/tags?per_page=100" -Headers $headers
    }

    foreach ($tag in @($response)) {
        $name = if ($tag -is [string]) { [string]$tag } else { [string]$tag.name }
        if ([string]::IsNullOrWhiteSpace($name)) {
            continue
        }
        if ($AllowPrerelease -or -not (Test-PrereleaseVersion -Version $name)) {
            return $name
        }
    }
    return ""
}

function Get-NodeLtsVersion {
    param($FixturePayload = $null)

    $releases = if ($null -ne $FixturePayload) {
        $FixturePayload
    }
    else {
        Invoke-RestMethod -Uri "https://nodejs.org/dist/index.json" -Headers @{ "User-Agent" = "llm-dev-wiki-update-check" }
    }
    $lts = @($releases) | Where-Object { $_.lts -and $_.lts -ne $false } | Select-Object -First 1
    if ($null -eq $lts) {
        throw "Node.js release feed did not contain an LTS release"
    }
    return ([string]$lts.version).TrimStart('v')
}

function Get-StableSemverTag {
    param($Tags)

    $candidates = foreach ($tag in @($Tags)) {
        $name = if ($tag -is [string]) { [string]$tag } else { [string]$tag.name }
        if ($name -match '^v?(\d+\.\d+\.\d+)$') {
            [pscustomobject]@{ Raw = $name; Parsed = [version]$Matches[1] }
        }
    }
    $latest = $candidates | Sort-Object Parsed -Descending | Select-Object -First 1
    if ($null -eq $latest) {
        throw "Release feed did not contain a stable semantic version"
    }
    return [string]$latest.Raw
}

function Get-PythonStableVersion {
    param($FixturePayload = $null)

    $headers = @{
        "Accept" = "application/vnd.github+json"
        "User-Agent" = "llm-dev-wiki-update-check"
    }
    if (-not [string]::IsNullOrWhiteSpace($env:GITHUB_TOKEN)) {
        $headers["Authorization"] = "Bearer $env:GITHUB_TOKEN"
    }
    $tags = if ($null -ne $FixturePayload) {
        $FixturePayload
    }
    else {
        Invoke-RestMethod -Uri "https://api.github.com/repos/python/cpython/tags?per_page=100" -Headers $headers
    }
    return (Get-StableSemverTag -Tags $tags).TrimStart('v')
}

function Get-PhpStableVersion {
    param($FixturePayload = $null)

    $releases = if ($null -ne $FixturePayload) {
        $FixturePayload
    }
    else {
        Invoke-RestMethod -Uri "https://www.php.net/releases/index.php?json&version=8&max=20" -Headers @{ "User-Agent" = "llm-dev-wiki-update-check" }
    }
    $versions = if ($releases -is [System.Collections.IDictionary]) {
        @($releases.Keys)
    }
    elseif ($releases.PSObject.Properties.Count -gt 0 -and -not ($releases -is [array])) {
        @($releases.PSObject.Properties.Name)
    }
    else {
        @($releases)
    }
    return (Get-StableSemverTag -Tags $versions).TrimStart('v')
}

function Get-WordPressCoreVersion {
    param($FixturePayload = $null)

    $response = if ($null -ne $FixturePayload) {
        $FixturePayload
    }
    else {
        Invoke-RestMethod -Uri "https://api.wordpress.org/core/version-check/1.7/" -Headers @{ "User-Agent" = "llm-dev-wiki-update-check" }
    }
    $offer = @($response.offers) | Where-Object { -not (Test-PrereleaseVersion -Version ([string]$_.version)) } | Select-Object -First 1
    if ($null -eq $offer) {
        throw "WordPress version feed did not contain a stable offer"
    }
    return [string]$offer.version
}

function Get-PostgreSqlStableVersion {
    param($FixturePayload = $null)

    $versions = if ($null -ne $FixturePayload) {
        $FixturePayload
    }
    else {
        Invoke-RestMethod -Uri "https://www.postgresql.org/versions.json" -Headers @{ "User-Agent" = "llm-dev-wiki-update-check" }
    }
    $latest = @($versions) |
        Where-Object { $_.supported -eq $true } |
        Sort-Object { [int]$_.major } -Descending |
        Select-Object -First 1
    if ($null -eq $latest) {
        throw "PostgreSQL version feed did not contain a supported release"
    }
    return "$($latest.major).$($latest.latestMinor)"
}

function Get-EntryVersion {
    param($Entry)

    $fixture = Get-FixtureValue -Entry $Entry
    if ($fixture.Found -and $fixture.Value -is [string] -and $fixture.Value -eq "__ERROR__") {
                throw "Fixture forced update check failure for $($Entry.name)"
    }

    $payload = if ($fixture.Found) { $fixture.Value } else { $null }
    if ($fixture.Found -and $Entry.ecosystem -in @("npm", "pypi", "github-releases", "manual")) {
        return [string]$payload
    }

    $allowPrerelease = (Get-VersionPolicy -Entry $Entry) -eq "allow-prerelease"

    switch ($Entry.ecosystem) {
        "npm" { return Get-NpmVersion -PackageName $Entry.package }
        "pypi" { return Get-PyPiVersion -PackageName $Entry.package }
        "github-releases" { return Get-GitHubLatestRelease -Repository $Entry.repository }
        "github-tags" { return Get-GitHubLatestTag -Repository $Entry.repository -AllowPrerelease:$allowPrerelease -FixturePayload $payload }
        "nodejs-lts" { return Get-NodeLtsVersion -FixturePayload $payload }
        "python-stable" { return Get-PythonStableVersion -FixturePayload $payload }
        "php-stable" { return Get-PhpStableVersion -FixturePayload $payload }
        "wordpress-core" { return Get-WordPressCoreVersion -FixturePayload $payload }
        "postgresql-stable" { return Get-PostgreSqlStableVersion -FixturePayload $payload }
        "manual" { return "manual-check" }
        default { throw "Unsupported ecosystem: $($Entry.ecosystem)" }
    }
}

function Get-FixtureValue {
    param($Entry)

    if (-not $UseFixtureVersions -or [string]::IsNullOrWhiteSpace($env:LLM_DEV_WIKI_UPDATE_FIXTURES_JSON)) {
        return [pscustomobject]@{ Found = $false; Value = $null }
    }

    $fixtures = $env:LLM_DEV_WIKI_UPDATE_FIXTURES_JSON | ConvertFrom-Json
    $packageOrRepo = if ($Entry.package) { [string]$Entry.package } elseif ($Entry.repository) { [string]$Entry.repository } else { [string]$Entry.name }
    $key = "$($Entry.ecosystem):$packageOrRepo"
    if ($fixtures.PSObject.Properties.Name.Contains($key)) {
        return [pscustomobject]@{ Found = $true; Value = $fixtures.PSObject.Properties[$key].Value }
    }

    return [pscustomobject]@{ Found = $false; Value = $null }
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
$baselineHolds = 0
$errorCount = 0
$rows = [System.Collections.Generic.List[string]]::new()

foreach ($entry in $entries) {
    $currentVersion = if ($entry.currentVersion) { [string]$entry.currentVersion } else { "" }
    $latestVersion = ""
    $recommendedBaseline = if ($entry.recommendedBaseline) { [string]$entry.recommendedBaseline } else { "" }
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
        elseif (-not [string]::IsNullOrWhiteSpace($recommendedBaseline) -and $recommendedBaseline -ne $currentVersion) {
            $status = "baseline-hold"
            $baselineHolds++
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

    $packageOrRepo = if ($entry.package) {
        $entry.package
    } elseif ($entry.repository) {
        $entry.repository
    } else {
        switch ([string]$entry.ecosystem) {
            "nodejs-lts" { "nodejs.org/dist/index.json" }
            "python-stable" { "python/cpython" }
            "php-stable" { "php.net/releases" }
            "wordpress-core" { "api.wordpress.org/core/version-check" }
            "postgresql-stable" { "postgresql.org/versions.json" }
            default { "manual" }
        }
    }
    $docsLink = if ($entry.docsUrl) { "[docs]($($entry.docsUrl))" } else { "" }
    $rows.Add("| $($entry.name) | $($entry.ecosystem) | $packageOrRepo | $currentVersion | $latestVersion | $recommendedBaseline | $status | $docsLink |") | Out-Null
}

$report = [System.Collections.Generic.List[string]]::new()
$report.Add("# Technology update report") | Out-Null
$report.Add("") | Out-Null
$report.Add("- Checked at: $checkedAt") | Out-Null
$report.Add("- Entries: $($entries.Count)") | Out-Null
$report.Add("- Updates found: $updatesFound") | Out-Null
$report.Add("- Baseline holds: $baselineHolds") | Out-Null
$report.Add("- Check failures: $errorCount") | Out-Null
$report.Add("") | Out-Null
$report.Add("| Name | Ecosystem | Package/Repository | Current | Latest | Recommended baseline | Status | Source |") | Out-Null
$report.Add("|---|---|---|---|---|---|---|---|") | Out-Null
foreach ($row in $rows) {
    $report.Add($row) | Out-Null
}
$report.Add("") | Out-Null
$report.Add("Manual entries require human review of the linked official documentation.") | Out-Null

# Retro freshness (WS4, 2026-07-04): предупреждаем, если поле "Last retro:" в
# retro-process.md старше 30 дней — процесс без триггера мёртв.
$retroDoc = Join-Path $PSScriptRoot "..\docs\15-maintenance\retro-process.md"
if (Test-Path -LiteralPath $retroDoc) {
    $retroLine = (Get-Content -LiteralPath $retroDoc -Encoding UTF8 | Where-Object { $_ -match '^Last retro:\s*(\d{4}-\d{2}-\d{2})' } | Select-Object -First 1)
    $report.Add("") | Out-Null
    if ($retroLine -and $retroLine -match '(\d{4}-\d{2}-\d{2})') {
        $lastRetro = $Matches[1]
        $threshold = (Get-Date).AddDays(-30).ToString('yyyy-MM-dd')
        if ($lastRetro -lt $threshold) {
            $report.Add("WARNING: last retro is older than 30 days ($lastRetro) - review docs/15-maintenance/retro-process.md and run a retro or confirm none was needed.") | Out-Null
        }
        else {
            $report.Add("Retro freshness: OK (last retro $lastRetro).") | Out-Null
        }
    }
    else {
        $report.Add("WARNING: 'Last retro:' field not found in docs/15-maintenance/retro-process.md - add it (YYYY-MM-DD).") | Out-Null
    }
}

$report | ForEach-Object { Write-Output $_ }

if ($FailOnUpdates -and $updatesFound -gt 0) {
    exit 1
}

exit 0
