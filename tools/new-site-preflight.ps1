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

function Get-RouteModeDecision {
    param([string]$RequestText, $RouterResult)

    $text = $RequestText.ToLowerInvariant()
    $classificationText = $text
    $capabilityPatterns = @(
        'backend|бэкенд', 'cms', 'авторизац\w*|auth',
        'плат[её]ж\w*|оплат\w*', 'баз\w*\s+данн\w*|бд', 'server|сервер\w*'
    )
    foreach ($capabilityPattern in $capabilityPatterns) {
        if ($text -match "без[^.;]{0,120}($capabilityPattern)") {
            $classificationText = $classificationText -replace "($capabilityPattern)", ''
        }
    }
    $classificationText = $classificationText -replace '(не\s+нуж(?:ен|на|ны)?|не\s+использ(?:уется|овать)?)\s+(backend|бэкенд|cms|авторизац\w*|auth|плат[её]ж\w*|оплат\w*|баз\w*\s+данн\w*|бд|server|сервер\w*)', ''
    $reasons = [System.Collections.Generic.List[string]]::new()
    $focused = $text -match 'поправ|исправ|замен|обнов|отредакт|правк|hero|хиро|секци|один\s+блок|существующ'
    $staticBoundary = $text -match 'статическ|чист(?:ый|ом)\s+html|html\s*(и|\+|/)\s*css|без\s+(js|javascript|backend|бэкенд|cms|server|сервер)'
    $explicitFull = $text -match 'полный\s+цикл|full[- ]?pipeline|все\s+17\s+фаз|под\s+ключ'
    $auth = $classificationText -match 'авторизац|регистрац|\bauth\b|\brbac\b|рол[ьи]|roles?'
    $payments = $classificationText -match 'плат[её]ж|оплат|payment|stripe|эквайринг|billing'
    $data = $classificationText -match '\bcms\b|баз\w*\s+данн|\bбд\b|database|postgres|миграц'
    $integration = $classificationText -match 'интеграц|webhook|\bapi\b|crm|backend|бэкенд|server|сервер'
    $complexProduct = [string]$RouterResult.recommendedPlaybook -in @(
        'saas','ecommerce','admin-dashboard','marketplace','ai-rag-app','api-only-backend','real-time-app'
    )

    if ($explicitFull) { $reasons.Add('explicit-full-cycle') | Out-Null }
    if ($auth) { $reasons.Add('auth-or-roles') | Out-Null }
    if ($payments) { $reasons.Add('payments') | Out-Null }
    if ($data) { $reasons.Add('data-or-cms') | Out-Null }
    if ($integration) { $reasons.Add('server-integration') | Out-Null }
    if ($complexProduct -and -not ($focused -or $staticBoundary)) { $reasons.Add('complex-product') | Out-Null }

    if ($reasons.Count -gt 0) {
        return [pscustomobject]@{ mode='full-pipeline'; reasons=@($reasons); actionableDirect=$false }
    }
    if ($focused) { $reasons.Add('focused-existing-change') | Out-Null }
    elseif ($staticBoundary) { $reasons.Add('static-no-server') | Out-Null }
    elseif ([string]$RouterResult.recommendedPlaybook -in @('landing','content-site')) { $reasons.Add('simple-public-site') | Out-Null }
    else { $reasons.Add('insufficient-complexity-evidence') | Out-Null }
    return [pscustomobject]@{ mode='direct'; reasons=@($reasons); actionableDirect=($focused -or $staticBoundary) }
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
$routeDecision = Get-RouteModeDecision -RequestText $Request -RouterResult $router

$requiredWikiDocs = @($router.wikiLinks)
$siteAuditCommand = New-AuditCommand -AuditScript $auditScript -TargetUrl $Url -TargetRoutes $Routes
$canStartImplementation = (
    ($router.confidence -ne "low" -and $router.confidence -ne "blocker") -or
    ($routeDecision.mode -eq "direct" -and $routeDecision.actionableDirect)
)
$nextSteps = if ($canStartImplementation) {
    if ($routeDecision.mode -eq "full-pipeline") {
        @(
            "Read required wiki docs before coding.",
            "Confirm assumptions and answer remaining open questions.",
            "Create _pipeline-status.md with new-site-pipeline-status.ps1 (dry-run first).",
            "Add the site audit command to the handoff/release plan."
        )
    }
    else {
        @(
            "Use only the project rules and checks relevant to this focused task.",
            "Do not create full-pipeline state for the direct route.",
            "Run proportionate legal, visual and verification gates."
        )
    }
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
    routeMode = $routeDecision.mode
    routeReasons = @($routeDecision.reasons)
    recommendedRoute = $router.recommendedRoute
    recommendedPlaybook = $router.recommendedPlaybook
    recommendedDeliveryProfile = $router.recommendedDeliveryProfile
    supportingGuides = @($router.supportingGuides)
    recommendedStack = $router.recommendedStack
    assumptions = @($router.assumptions)
    openQuestions = @($router.openQuestions)
    rejectedAlternatives = @($router.rejectedAlternatives)
    acceptanceGates = @($router.acceptanceGates)
    requiredWikiDocs = $requiredWikiDocs
    lessonLinks = @($router.lessonLinks | Where-Object { $_ })
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
    Write-Host "Route mode: $($result.routeMode)"
    Write-Host "Route reasons: $($result.routeReasons -join ', ')"
    Write-Host "Primary playbook: $($result.recommendedPlaybook)"
    Write-Host "Delivery profile: $($result.recommendedDeliveryProfile)"
    Write-Host "Supporting guides: $($result.supportingGuides -join ', ')"
    Write-Host "Recommended route: $($result.recommendedRoute)"
    Write-Host "Recommended stack: $($result.recommendedStack)"
    Write-Host ""
    Write-Host "Open questions:"
    foreach ($item in $result.openQuestions) { Write-Host "- $item" }
    Write-Host ""
    Write-Host "Required wiki docs:"
    foreach ($item in $result.requiredWikiDocs) { Write-Host "- $item" }
    if ($result.lessonLinks.Count -gt 0) {
        Write-Host ""
        Write-Host "Lessons learned (прочитать до реализации):"
        foreach ($item in $result.lessonLinks) { Write-Host "- $item" }
    }
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
