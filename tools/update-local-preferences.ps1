param(
    [string]$PreferenceFile = "D:\Work\AGENT-PREFERENCES.local.md",
    [string]$Title,
    [string]$Scope,
    [string]$Preference,
    [string]$Avoid = "",
    [string]$Evidence,
    [string]$ReviewAfter,
    [string[]]$Links = @(),
    [switch]$DryRun,
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

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

function Test-UnsafePreferenceText {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $null
    }

    $patterns = @(
        @{ Name = "token"; Pattern = '(?i)\b(access[_-]?token|refresh[_-]?token|api[_-]?key|secret[_-]?key|bearer\s+[a-z0-9._~+\/=-]{12,})\b' },
        @{ Name = "private-key"; Pattern = '-----BEGIN (RSA |OPENSSH |EC |DSA |)?PRIVATE KEY-----' },
        @{ Name = "cookie"; Pattern = '(?i)\b(cookie|sessionid|connect\.sid|csrf[_-]?token)\s*[:=]' },
        @{ Name = "credential"; Pattern = '(?i)\b(password|passwd|pwd|credential|credentials)\s*[:=]' },
        @{ Name = "customer-payload"; Pattern = '(?i)\b(customer payload|client payload|production dump|database dump|private code)\b' },
        @{ Name = "pii-email"; Pattern = '(?i)\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b' },
        @{ Name = "pii-phone"; Pattern = '(?i)\b(phone|tel|mobile)\s*[:=]\s*\+?\d[\d\s().-]{8,}\d|(?<![\d-])\+\d[\d\s().-]{8,}\d(?![\d-])' }
    )

    foreach ($item in $patterns) {
        if ($Text -match $item.Pattern) {
            return $item.Name
        }
    }

    return $null
}

Assert-Required -Name "Title" -Value $Title
Assert-Required -Name "Scope" -Value $Scope
Assert-Required -Name "Preference" -Value $Preference
Assert-Required -Name "Evidence" -Value $Evidence
Assert-Required -Name "ReviewAfter" -Value $ReviewAfter

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
