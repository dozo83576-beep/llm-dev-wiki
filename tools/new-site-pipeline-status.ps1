param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,
    [Parameter(Mandatory = $true)]
    [string]$Playbook,
    [switch]$Apply,
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

# Bootstrap для _pipeline-status.md: по умолчанию Dry Run (печатает содержимое),
# запись выполняет только -Apply. Формат — docs/10-templates/pipeline-status.md,
# фазы — docs/01-development-process/site-pipeline-map.md (17 фаз).

$playbookPath = Join-Path $Root "docs/13-playbooks/$Playbook.md"
if (-not (Test-Path -LiteralPath $playbookPath -PathType Leaf)) {
    throw "Unknown playbook '$Playbook': $playbookPath not found. Mix playbooks is not allowed - pick one from docs/13-playbooks/."
}

if (-not (Test-Path -LiteralPath $ProjectRoot -PathType Container)) {
    throw "ProjectRoot does not exist: $ProjectRoot"
}

$statusPath = Join-Path (Resolve-Path -LiteralPath $ProjectRoot).Path "_pipeline-status.md"
if (Test-Path -LiteralPath $statusPath -PathType Leaf) {
    throw "_pipeline-status.md already exists: $statusPath. Bootstrap only creates a new file - edit the existing one instead."
}

$phases = @(
    @{ N = 1;  Name = "preflight";                 Artifact = '`_preflight.md`' },
    @{ N = 2;  Name = "site-discovery";            Artifact = '`_discovery.md`' },
    @{ N = 3;  Name = "playbook";                  Artifact = '`_pipeline-status.md` (строка Playbook выше)' },
    @{ N = 4;  Name = "site-competitive-analysis"; Artifact = '`_competitive-analysis.md`' },
    @{ N = 5;  Name = "site-stack";                Artifact = '`_stack.md`' },
    @{ N = 6;  Name = "site-architecture";         Artifact = '`_architecture.md`' },
    @{ N = 7;  Name = "project-agents";            Artifact = '`AGENTS.md`' },
    @{ N = 8;  Name = "site-content";              Artifact = '`_content-model.md`' },
    @{ N = 9;  Name = "site-design";               Artifact = '`DESIGN-DIRECTION.md` (лендинг) / токены' },
    @{ N = 10; Name = "site-backend";              Artifact = '`_backend-gate.md`' },
    @{ N = 11; Name = "site-frontend";             Artifact = '`_frontend-smoke.md`' },
    @{ N = 12; Name = "site-seo";                  Artifact = '`_seo-report.md`' },
    @{ N = 13; Name = "site-review";               Artifact = '`_review-report.md`' },
    @{ N = 14; Name = "site-deploy";               Artifact = '`_deploy.md` или production URL' },
    @{ N = 15; Name = "site-handoff";              Artifact = '`handoff.md`' },
    @{ N = 16; Name = "post-release";              Artifact = '`_post-release-plan.md`' },
    @{ N = 17; Name = "capture-learnings";         Artifact = '`_learning-review.md`' }
)

# Единая политика пропусков: api-only-backend обязан пропустить ровно эти фазы
# (тот же список, что в tools/verify-site-pipeline.ps1).
$apiOnlySkips = @("site-content", "site-design", "site-frontend", "site-seo")
$today = Get-Date -Format "yyyy-MM-dd"

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# Pipeline status — $ProjectName")
$lines.Add("")
$lines.Add("Playbook: $Playbook")
$lines.Add("Обновлено: $today")
$lines.Add("")
$lines.Add("| # | Фаза | Статус | Дата | Артефакт |")
$lines.Add("|---|------|--------|------|----------|")

$skipLines = [System.Collections.Generic.List[string]]::new()
foreach ($phase in $phases) {
    $isSkipped = ($Playbook -eq "api-only-backend" -and $apiOnlySkips -contains $phase.Name)
    if ($isSkipped) {
        $lines.Add("| $($phase.N) | $($phase.Name) | skipped | $today | — (playbook api-only-backend) |")
        $skipLines.Add("- $($phase.Name): skipped — playbook api-only-backend")
    }
    else {
        $lines.Add("| $($phase.N) | $($phase.Name) | pending | — | $($phase.Artifact) |")
    }
}

$lines.Add("")
$lines.Add("## Пропуски и причины")
$lines.Add("")
if ($skipLines.Count -gt 0) {
    foreach ($skip in $skipLines) { $lines.Add($skip) }
}
else {
    $lines.Add("- нет (молчаливый пропуск запрещён; единственный optional — post-release, с причиной)")
}
$lines.Add("")
$lines.Add("## Открытые вопросы")
$lines.Add("")
$lines.Add("- —")
$lines.Add("")

$content = $lines -join "`r`n"

if ($Apply) {
    Set-Content -LiteralPath $statusPath -Value $content -Encoding UTF8
    Write-Host "Created: $statusPath"
    Write-Host "Next: pwsh $(Join-Path $Root 'tools/verify-site-pipeline.ps1') -ProjectRoot $ProjectRoot"
}
else {
    Write-Host "Dry run — файл НЕ записан. Содержимое:"
    Write-Host "----------------------------------------"
    Write-Host $content
    Write-Host "----------------------------------------"
    Write-Host "Запись: добавь -Apply. Цель: $statusPath"
}
exit 0
