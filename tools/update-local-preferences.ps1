param(
    [string]$PreferenceFile = "D:\Work\AGENT-PREFERENCES.local.md",
    [string]$Title,
    [string]$Scope,
    [string]$Preference,
    [string]$Avoid = "",
    [string]$Evidence,
    [string]$ReviewAfter,
    [string[]]$Links = @(),
    [switch]$AllowCustomPath,
    [switch]$DryRun,
    [switch]$Apply
)

$ErrorActionPreference = "Stop"
$DefaultPreferenceFile = "D:\Work\AGENT-PREFERENCES.local.md"
. (Join-Path $PSScriptRoot "lib\secret-scan.ps1")

function Fail {
    param([string]$Message)
    Write-Host "Status: blocked"
    Write-Host "Reason: $Message"
    exit 1
}

function Assert-Required {
    param(
        [string]$Name,
        [string]$Value
    )
    if ([string]::IsNullOrWhiteSpace($Value)) {
        Fail "Missing required field: $Name"
    }
}

Assert-Required -Name "Title" -Value $Title
Assert-Required -Name "Scope" -Value $Scope
Assert-Required -Name "Preference" -Value $Preference
Assert-Required -Name "Evidence" -Value $Evidence
Assert-Required -Name "ReviewAfter" -Value $ReviewAfter

$defaultFullPath = [System.IO.Path]::GetFullPath($DefaultPreferenceFile)
$preferenceFullPath = [System.IO.Path]::GetFullPath($PreferenceFile)
if (-not $AllowCustomPath -and $preferenceFullPath -ne $defaultFullPath) {
    Fail "Custom PreferenceFile requires -AllowCustomPath. Default allowed path: $DefaultPreferenceFile"
}

if ($Apply -and $DryRun) {
    Fail "Use either -DryRun or -Apply, not both."
}

$mode = "dry-run"
if ($Apply) {
    $mode = "apply"
}

$combinedText = @($Title, $Scope, $Preference, $Avoid, $Evidence, $ReviewAfter) + $Links
$unsafeMatch = Test-UnsafePreferenceText -Text ($combinedText -join "`n")
if ($unsafeMatch) {
    Fail "Unsafe preference content detected: $unsafeMatch"
}

$linkText = "_Нет ссылок._"
if ($Links.Count -gt 0) {
    $linkText = ($Links | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }) -join "; "
    if ([string]::IsNullOrWhiteSpace($linkText)) {
        $linkText = "_Нет ссылок._"
    }
}

$entry = @"
### $Title
- Scope: $Scope
- Preference: $Preference
- Avoid: $Avoid
- Evidence: $Evidence
- Review after: $ReviewAfter
- Links: $linkText
"@

Write-Host "Status: ok"
Write-Host "Mode: $mode"
Write-Host "Preference file: $PreferenceFile"
Write-Host ""
Write-Host "Proposed local entry:"
Write-Host $entry

if (-not $Apply) {
    Write-Host ""
    Write-Host "Dry run only. Re-run with -Apply to append this entry."
    exit 0
}

$parent = Split-Path -Parent $PreferenceFile
if (-not [string]::IsNullOrWhiteSpace($parent) -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent | Out-Null
}

if (-not (Test-Path -LiteralPath $PreferenceFile)) {
    $header = @"
# Локальная память предпочтений пользователя

Этот файл локальный и не должен коммититься в проекты или wiki.

"@
    Set-Content -LiteralPath $PreferenceFile -Value $header -Encoding UTF8
}

Add-Content -LiteralPath $PreferenceFile -Value ("`n" + $entry) -Encoding UTF8
Write-Host ""
Write-Host "Applied: appended preference entry."
exit 0
