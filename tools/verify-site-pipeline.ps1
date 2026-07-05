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

function Get-Text {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return ""
    }
    return Get-Content -Raw -Encoding UTF8 -LiteralPath $Path
}

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$failures = [System.Collections.Generic.List[string]]::new()

$phaseNames = @(
    "preflight",
    "site-discovery",
    "playbook",
    "site-competitive-analysis",
    "site-stack",
    "site-architecture",
    "project-agents",
    "site-content",
    "site-design",
    "site-backend",
    "site-frontend",
    "site-seo",
    "site-review",
    "site-deploy",
    "site-handoff",
    "post-release",
    "capture-learnings"
)

$paths = @{
    PipelineMap = Join-Path $rootPath "docs/01-development-process/site-pipeline-map.md"
    PipelineStatus = Join-Path $rootPath "docs/10-templates/pipeline-status.md"
    BuildSkill = Join-Path $rootPath "agent-skills/build-modern-site/SKILL.md"
    Hook = Join-Path $rootPath "agent-skills/hooks/userpromptsubmit-site-intent.ps1"
    OpenAiYaml = Join-Path $rootPath "agent-skills/build-modern-site/agents/openai.yaml"
    FullCycle = Join-Path $rootPath "docs/01-development-process/full-cycle.md"
}

foreach ($name in $paths.Keys) {
    if (-not (Test-Path -LiteralPath $paths[$name] -PathType Leaf)) {
        Add-Failure $failures "Missing required pipeline file: $($paths[$name])"
    }
}

$pipelineMap = Get-Text $paths.PipelineMap
$pipelineStatus = Get-Text $paths.PipelineStatus
$buildSkill = Get-Text $paths.BuildSkill
$hook = Get-Text $paths.Hook
$openAiYaml = Get-Text $paths.OpenAiYaml
$fullCycle = Get-Text $paths.FullCycle

if ($pipelineMap -and ($pipelineMap -notmatch "17 фаз")) {
    Add-Failure $failures "site-pipeline-map.md must state canonical 17 phases."
}

for ($i = 0; $i -lt $phaseNames.Count; $i++) {
    $number = $i + 1
    $phase = $phaseNames[$i]
    if ($pipelineMap -and ($pipelineMap -notmatch "\|\s*$number\s*\|\s*$([regex]::Escape($phase))\s*\|")) {
        Add-Failure $failures "site-pipeline-map.md missing phase ${number}: $phase"
    }
    if ($pipelineStatus -and ($pipelineStatus -notmatch "\|\s*$number\s*\|\s*$([regex]::Escape($phase))\s*\|")) {
        Add-Failure $failures "pipeline-status.md missing phase ${number}: $phase"
    }
}

foreach ($phase in @("site-content", "site-design", "site-backend", "site-frontend", "site-seo", "site-review", "site-deploy", "site-handoff", "capture-learnings")) {
    if ($buildSkill -and -not $buildSkill.Contains($phase)) {
        Add-Failure $failures "build-modern-site SKILL.md does not mention required phase: $phase"
    }
}

foreach ($textItem in @(
    @{ Name = "build-modern-site SKILL.md"; Text = $buildSkill },
    @{ Name = "UserPromptSubmit hook"; Text = $hook },
    @{ Name = "build-modern-site openai.yaml"; Text = $openAiYaml }
)) {
    if ($textItem.Text -and -not $textItem.Text.Contains("site-pipeline-map.md")) {
        Add-Failure $failures "$($textItem.Name) must reference site-pipeline-map.md"
    }
    if ($textItem.Text -and -not ($textItem.Text -match "17\s+фаз|17 phases")) {
        Add-Failure $failures "$($textItem.Name) must state 17 phases."
    }
}

if ($fullCycle -and (($fullCycle -notmatch "13\.\s+Тестирование") -or ($fullCycle -notmatch "14\.\s+Security review"))) {
    Add-Failure $failures "full-cycle.md must keep testing and security review stages for mapping into site-review."
}

$workAgents = Join-Path (Split-Path -Parent $rootPath) "AGENTS.md"
if (Test-Path -LiteralPath $workAgents -PathType Leaf) {
    $agents = Get-Text $workAgents
    foreach ($phase in @("site-backend", "site-frontend", "site-handoff")) {
        if (-not $agents.Contains($phase)) {
            Add-Failure $failures "D:\Work\AGENTS.md must mention phase skill: $phase"
        }
    }
    if (-not $agents.Contains("site-pipeline-map.md")) {
        Add-Failure $failures "D:\Work\AGENTS.md must reference site-pipeline-map.md"
    }
}

Write-Host "Site pipeline verification"
Write-Host "Root: $rootPath"
Write-Host "Expected phases: $($phaseNames.Count)"
Write-Host "Failures: $($failures.Count)"
foreach ($failure in $failures) {
    Write-Host "- $failure"
}

if ($failures.Count -gt 0) {
    exit 1
}
exit 0
