param(
    [Parameter(Mandatory = $true)]
    [string]$Request,
    [string]$Url = "",
    [string[]]$Routes = @(),
    [switch]$OutputJson,
    [switch]$FailOnLowConfidence,
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

function Join-CommandArg {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) {
        return "''"
    }
    if ($Value -match "[\s'`"`$<>|&;()]") {
        return "'" + ($Value -replace "'", "''") + "'"
    }
    return $Value
}

function New-AuditCommand {
    param([string]$AuditScript, [string]$TargetUrl, [string[]]$TargetRoutes)

    $auditUrl = if ([string]::IsNullOrWhiteSpace($TargetUrl)) { "<dev-or-staging-url>" } else { $TargetUrl }
    $command = "pwsh $(Join-CommandArg -Value $AuditScript) -Url $(Join-CommandArg -Value $auditUrl)"
    $normalizedRoutes = @(
        foreach ($route in $TargetRoutes) {
            foreach ($item in ($route -split ",")) {
                if (-not [string]::IsNullOrWhiteSpace($item)) {
                    $item.Trim()
                }
            }
        }
    )
    if ($normalizedRoutes.Count -gt 0) {
        $command += " -Routes " + (($normalizedRoutes | ForEach-Object { Join-CommandArg -Value $_ }) -join ",")
    }
    return $command
}

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$routerScript = Join-Path $rootPath "tools/site-stack-router.ps1"
if (-not (Test-Path -LiteralPath $routerScript)) {
    throw "site-stack-router.ps1 not found under Root: $rootPath"
}
$auditScript = Join-Path $rootPath "tools/site-audit.ps1"
if (-not (Test-Path -LiteralPath $auditScript)) {
    throw "site-audit.ps1 not found under Root: $rootPath"
}

$routerJson = & pwsh -NoProfile -File $routerScript -Request $Request -OutputJson -Root $rootPath
if ($LASTEXITCODE -ne 0) {
    throw "site-stack-router.ps1 failed with exit code $LASTEXITCODE"
}
$router = $routerJson | ConvertFrom-Json

$requiredWikiDocs = @($router.wikiLinks)
$siteAuditCommand = New-AuditCommand -AuditScript $auditScript -TargetUrl $Url -TargetRoutes $Routes
$canStartImplementation = ($router.confidence -ne "low" -and $router.confidence -ne "blocker")
$nextSteps = if ($canStartImplementation) {
    @(
        "Read required wiki docs before coding.",
        "Confirm assumptions and answer remaining open questions.",
        "Add the site audit command to the handoff/release plan."
    )
}
else {
    @(
        "Do not scaffold the project yet.",
        "Ask the open questions returned by the router.",
        "Rerun preflight after discovery updates the request."
    )
}

$result = [pscustomobject]@{
    status = if ($canStartImplementation) { "ready" } else { "needs-discovery" }
    confidence = $router.confidence
    recommendedRoute = $router.recommendedRoute
    recommendedStack = $router.recommendedStack
    assumptions = @($router.assumptions)
    openQuestions = @($router.openQuestions)
    rejectedAlternatives = @($router.rejectedAlternatives)
    acceptanceGates = @($router.acceptanceGates)
    requiredWikiDocs = $requiredWikiDocs
    siteAuditCommand = $siteAuditCommand
    nextSteps = $nextSteps
    router = $router
}

if ($OutputJson) {
    $result | ConvertTo-Json -Depth 10
}
else {
    Write-Host "Preflight status: $($result.status)"
    Write-Host "Decision confidence: $($result.confidence)"
    Write-Host "Recommended route: $($result.recommendedRoute)"
    Write-Host "Recommended stack: $($result.recommendedStack)"
    Write-Host ""
    Write-Host "Open questions:"
    foreach ($item in $result.openQuestions) { Write-Host "- $item" }
    Write-Host ""
    Write-Host "Required wiki docs:"
    foreach ($item in $result.requiredWikiDocs) { Write-Host "- $item" }
    Write-Host ""
    Write-Host "Site audit command:"
    Write-Host $result.siteAuditCommand
    Write-Host ""
    Write-Host "Next steps:"
    foreach ($item in $result.nextSteps) { Write-Host "- $item" }
}

if ($FailOnLowConfidence -and -not $canStartImplementation) {
    exit 1
}
exit 0
