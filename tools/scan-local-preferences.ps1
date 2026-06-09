param(
    [string]$PreferenceFile = "D:\Work\AGENT-PREFERENCES.local.md",
    [switch]$AllowCustomPath,
    [switch]$OutputJson,
    [switch]$FailOnFinding
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

$defaultFullPath = [System.IO.Path]::GetFullPath($DefaultPreferenceFile)
$preferenceFullPath = [System.IO.Path]::GetFullPath($PreferenceFile)
if (-not $AllowCustomPath -and $preferenceFullPath -ne $defaultFullPath) {
    Fail "Custom PreferenceFile requires -AllowCustomPath. Default allowed path: $DefaultPreferenceFile"
}

if (-not (Test-Path -LiteralPath $PreferenceFile)) {
    $result = [pscustomobject]@{
        status = "missing"
        preferenceFile = $PreferenceFile
        findings = @()
        findingCount = 0
    }
    if ($OutputJson) {
        $result | ConvertTo-Json -Depth 5
    }
    else {
        Write-Host "Status: missing"
        Write-Host "Preference file: $PreferenceFile"
        Write-Host "Findings: 0"
    }
    exit 0
}

$content = Get-Content -LiteralPath $PreferenceFile -Raw -Encoding UTF8
$findings = @(Find-SecretLikeText -Text $content)
$status = if ($findings.Count -gt 0) { "findings" } else { "ok" }

$result = [pscustomobject]@{
    status = $status
    preferenceFile = $PreferenceFile
    findings = $findings
    findingCount = $findings.Count
}

if ($OutputJson) {
    $result | ConvertTo-Json -Depth 5
}
else {
    Write-Host "Status: $status"
    Write-Host "Preference file: $PreferenceFile"
    Write-Host "Findings: $($findings.Count)"
    foreach ($finding in $findings) {
        Write-Host "- $($finding.Rule) at line $($finding.Line), column $($finding.Column)"
    }
}

if ($FailOnFinding -and $findings.Count -gt 0) {
    exit 1
}
exit 0
