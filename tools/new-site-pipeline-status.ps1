param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,
    [Parameter(Mandatory = $true)]
    [string]$Playbook,
    [string]$DeliveryProfile = "",
    [string[]]$SupportingGuides = @(),
    [switch]$Apply,
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$ContractPath = ""
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ProjectRoot -PathType Container)) {
    throw "ProjectRoot does not exist: $ProjectRoot"
}
if ([string]::IsNullOrWhiteSpace($ContractPath)) {
    $ContractPath = Join-Path $Root "resources/site-pipeline-contract.json"
}
if (-not (Test-Path -LiteralPath $ContractPath -PathType Leaf)) {
    throw "Pipeline contract does not exist: $ContractPath"
}
$contract = Get-Content -Raw -Encoding UTF8 -LiteralPath $ContractPath | ConvertFrom-Json
if ($contract.contractVersion -ne 2) {
    throw "Unsupported pipeline contract version: $($contract.contractVersion)"
}

$playbookEntry = @($contract.primaryPlaybooks | Where-Object id -eq $Playbook)
if ($playbookEntry.Count -ne 1) {
    throw "Unsupported primary Playbook: $Playbook"
}
if ([string]::IsNullOrWhiteSpace($DeliveryProfile)) {
    $DeliveryProfile = $playbookEntry[0].defaultDeliveryProfile
}
if (@($playbookEntry[0].allowedDeliveryProfiles) -notcontains $DeliveryProfile) {
    throw "Playbook $Playbook does not allow delivery profile: $DeliveryProfile"
}
$profileEntry = @($contract.deliveryProfiles | Where-Object id -eq $DeliveryProfile)
if ($profileEntry.Count -ne 1) {
    throw "Unsupported delivery profile: $DeliveryProfile"
}

$allowedGuideIds = @($contract.supportingGuides.id)
$normalizedGuides = @($SupportingGuides | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Sort-Object -Unique)
foreach ($guide in $normalizedGuides) {
    if ($allowedGuideIds -notcontains $guide) {
        throw "Unsupported supporting guide: $guide"
    }
}

$projectPath = (Resolve-Path -LiteralPath $ProjectRoot).Path
$statusPath = Join-Path $projectPath "_pipeline-status.md"
if (Test-Path -LiteralPath $statusPath) {
    throw "Pipeline status already exists: $statusPath"
}

$updated = Get-Date -Format "yyyy-MM-dd"
$guideText = if ($normalizedGuides.Count -eq 0) { "—" } else { $normalizedGuides -join ", " }
$notApplicable = @($profileEntry[0].notApplicablePhases)
$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# Pipeline status — $ProjectName")
$lines.Add("")
$lines.Add("Contract-Version: $($contract.contractVersion)")
$lines.Add("Playbook: $Playbook")
$lines.Add("Supporting-Guides: $guideText")
$lines.Add("Delivery-Profile: $DeliveryProfile")
$lines.Add("Обновлено: $updated")
$lines.Add("")
$lines.Add("| # | Фаза | Статус | Дата | Артефакт |")
$lines.Add("|---|------|--------|------|----------|")
foreach ($phase in @($contract.phases | Sort-Object number)) {
    if ($notApplicable -contains $phase.id) {
        $lines.Add("| $($phase.number) | $($phase.id) | not-applicable | $updated | — (delivery-profile $DeliveryProfile) |")
    }
    else {
        $lines.Add("| $($phase.number) | $($phase.id) | pending | — | ``$($phase.artifact)`` |")
    }
}
$lines.Add("")
$lines.Add("## Неприменимые фазы")
$lines.Add("")
if ($notApplicable.Count -eq 0) {
    $lines.Add("- нет")
}
else {
    foreach ($phase in $notApplicable) {
        $lines.Add("- ${phase}: not-applicable — delivery-profile $DeliveryProfile")
    }
}
$lines.Add("")
$lines.Add("## Пропуски и причины")
$lines.Add("")
$lines.Add("- нет (optional post-release можно пропустить только с явной причиной)")
$lines.Add("")
$lines.Add("## Открытые вопросы")
$lines.Add("")
$lines.Add("- —")
$lines.Add("")
$content = $lines -join "`r`n"

if (-not $Apply) {
    Write-Host "Dry run — файл НЕ записан."
    Write-Host "Target: $statusPath"
    Write-Host "----------------------------------------"
    Write-Host $content
    Write-Host "----------------------------------------"
    exit 0
}

try {
    $stream = [System.IO.File]::Open(
        $statusPath,
        [System.IO.FileMode]::CreateNew,
        [System.IO.FileAccess]::Write,
        [System.IO.FileShare]::None
    )
    try {
        $writer = [System.IO.StreamWriter]::new($stream, [System.Text.UTF8Encoding]::new($false))
        try { $writer.Write($content) }
        finally { $writer.Dispose() }
    }
    finally { $stream.Dispose() }
}
catch [System.IO.IOException] {
    if (Test-Path -LiteralPath $statusPath) {
        throw "Pipeline status already exists: $statusPath"
    }
    throw
}
Write-Host "Created pipeline status: $statusPath"
Write-Host "Verify: pwsh $(Join-Path $Root 'tools/verify-site-pipeline.ps1') -ProjectRoot $projectPath"
