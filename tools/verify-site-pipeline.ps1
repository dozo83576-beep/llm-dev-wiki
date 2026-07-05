param(
    [string]$Root = (Resolve-Path ".").Path,
    [string]$ProjectRoot = ""
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

function Get-ArtifactToken {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text) -or $Text.Trim() -eq "—") {
        return ""
    }
    $match = [regex]::Match($Text, '`([^`]+)`')
    if ($match.Success) {
        return $match.Groups[1].Value
    }
    return ""
}

function Test-PlaceholderArtifact {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $true
    }
    $trimmed = $Text.Trim()
    return $trimmed -eq "—" -or $trimmed -match '^—\s*\('
}

function Test-DeployUrlEvidence {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $false
    }
    return $Text.Trim() -match '^https?://'
}

function Read-ProjectPipelineRows {
    param([string]$StatusPath)

    $rows = @()
    foreach ($line in Get-Content -Encoding UTF8 -LiteralPath $StatusPath) {
        if ($line -notmatch '^\|\s*(\d+)\s*\|') {
            continue
        }
        if ($line -match '^\|\s*---') {
            continue
        }

        $cells = @($line.Trim().Trim("|").Split("|") | ForEach-Object { $_.Trim() })
        if ($cells.Count -lt 5 -or $cells[0] -notmatch '^\d+$') {
            continue
        }

        $rows += [pscustomobject]@{
            Number = [int]$cells[0]
            Phase = $cells[1]
            Status = $cells[2].ToLowerInvariant()
            Date = $cells[3]
            Artifact = $cells[4]
        }
    }
    return $rows
}

function Test-ProjectPipeline {
    param(
        [string]$ProjectPath,
        [string[]]$PhaseNames,
        [System.Collections.Generic.List[string]]$Failures
    )

    if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
        return
    }

    if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
        Add-Failure $Failures "ProjectRoot does not exist: $ProjectPath"
        return
    }

    $projectFullPath = (Resolve-Path -LiteralPath $ProjectPath).Path
    $statusPath = Join-Path $projectFullPath "_pipeline-status.md"
    if (-not (Test-Path -LiteralPath $statusPath -PathType Leaf)) {
        Add-Failure $Failures "Project pipeline status missing: $statusPath"
        return
    }

    $statusText = Get-Text $statusPath
    $playbook = ""
    if ($statusText -match '(?im)^Playbook:\s*(.+)$') {
        $playbook = $matches[1].Trim()
    }

    $rows = @(Read-ProjectPipelineRows -StatusPath $statusPath)
    if ($rows.Count -ne $PhaseNames.Count) {
        Add-Failure $Failures "Project pipeline must contain $($PhaseNames.Count) phases, found $($rows.Count): $statusPath"
    }

    $allowedStatuses = @("done", "in-progress", "skipped", "pending")
    $seenIncomplete = $false
    $skipReasons = ""
    if ($statusText -match '(?ms)^## Пропуски и причины\s*(.*?)(\r?\n## |\z)') {
        $skipReasons = $matches[1]
    }

    $apiOnlySkips = @("site-content", "site-design", "site-frontend", "site-seo")

    for ($i = 0; $i -lt $PhaseNames.Count; $i++) {
        $expectedNumber = $i + 1
        $expectedPhase = $PhaseNames[$i]
        $row = @($rows | Where-Object { $_.Number -eq $expectedNumber } | Select-Object -First 1)
        if ($row.Count -eq 0) {
            Add-Failure $Failures "Project pipeline missing phase ${expectedNumber}: $expectedPhase"
            continue
        }

        $item = $row[0]
        if ($item.Phase -ne $expectedPhase) {
            Add-Failure $Failures "Project pipeline phase ${expectedNumber} must be $expectedPhase, found $($item.Phase)"
        }
        if ($allowedStatuses -notcontains $item.Status) {
            Add-Failure $Failures "Project pipeline phase $($item.Phase) has unsupported status: $($item.Status)"
        }

        if ($seenIncomplete -and $item.Status -eq "done") {
            Add-Failure $Failures "Project pipeline has done phase after incomplete phase: $($item.Phase)"
        }
        if ($item.Status -in @("pending", "in-progress")) {
            $seenIncomplete = $true
        }

        if ($item.Status -eq "skipped") {
            if ([string]::IsNullOrWhiteSpace($skipReasons) -or $skipReasons -notmatch [regex]::Escape($item.Phase)) {
                Add-Failure $Failures "Project pipeline skipped phase has no reason: $($item.Phase)"
            }
            if ($playbook -match "api-only-backend") {
                if ($apiOnlySkips -notcontains $item.Phase) {
                    Add-Failure $Failures "api-only-backend cannot skip phase: $($item.Phase)"
                }
            }
            elseif ($item.Phase -in @("site-content", "site-design", "site-backend", "site-frontend", "site-seo", "site-review", "site-deploy", "site-handoff", "capture-learnings")) {
                Add-Failure $Failures "Non-api project cannot skip required phase: $($item.Phase)"
            }
        }

        if ($item.Status -eq "done") {
            if (Test-PlaceholderArtifact -Text $item.Artifact) {
                Add-Failure $Failures "Project pipeline done phase has no artifact/evidence: $($item.Phase)"
                continue
            }

            $artifact = Get-ArtifactToken -Text $item.Artifact
            if ([string]::IsNullOrWhiteSpace($artifact)) {
                if ($item.Phase -eq "site-deploy" -and (Test-DeployUrlEvidence -Text $item.Artifact)) {
                    continue
                }
                Add-Failure $Failures "Project pipeline done phase must use a file artifact: $($item.Phase)"
                continue
            }

            $artifactPath = Join-Path $projectFullPath $artifact
            if (-not (Test-Path -LiteralPath $artifactPath -PathType Leaf)) {
                Add-Failure $Failures "Project pipeline done phase missing artifact: $($item.Phase) -> $artifact"
            }
        }
    }
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

Test-ProjectPipeline -ProjectPath $ProjectRoot -PhaseNames $phaseNames -Failures $failures

Write-Host "Site pipeline verification"
Write-Host "Root: $rootPath"
if (-not [string]::IsNullOrWhiteSpace($ProjectRoot)) {
    Write-Host "ProjectRoot: $ProjectRoot"
}
Write-Host "Expected phases: $($phaseNames.Count)"
Write-Host "Failures: $($failures.Count)"
foreach ($failure in $failures) {
    Write-Host "- $failure"
}

if ($failures.Count -gt 0) {
    exit 1
}
exit 0
