param(
    [string]$Root = (Resolve-Path ".").Path,
    [string]$ProjectRoot = "",
    [string]$RequirePhase = "",
    [switch]$RequireComplete,
    [string]$ContractPath = ""
)

$ErrorActionPreference = "Stop"

function Add-Failure {
    param([System.Collections.Generic.List[string]]$Failures, [string]$Message)
    $Failures.Add($Message) | Out-Null
}

function Get-Text {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return "" }
    return Get-Content -Raw -Encoding UTF8 -LiteralPath $Path
}

function Get-MetadataValue {
    param([string]$Text, [string]$Name)
    $match = [regex]::Match($Text, "(?im)^$([regex]::Escape($Name)):\s*(.+)$")
    if (-not $match.Success) { return "" }
    return $match.Groups[1].Value.Trim()
}

function Get-ArtifactToken {
    param([string]$Text)
    $match = [regex]::Match($Text, '`([^`]+)`')
    if (-not $match.Success) { return "" }
    return $match.Groups[1].Value
}

function Get-CanonicalPath {
    param([string]$Path)

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $root = [System.IO.Path]::GetPathRoot($fullPath)
    $currentPath = $root
    foreach ($part in $fullPath.Substring($root.Length) -split '[\\/]') {
        if ([string]::IsNullOrWhiteSpace($part)) { continue }
        $candidate = Join-Path $currentPath $part
        if (Test-Path -LiteralPath $candidate) {
            $item = Get-Item -LiteralPath $candidate -Force
            if ($item.LinkType) {
                $target = $item.ResolveLinkTarget($true)
                if ($null -ne $target) {
                    $currentPath = $target.FullName
                    continue
                }
            }
            $currentPath = $item.FullName
        }
        else {
            $currentPath = $candidate
        }
    }
    return [System.IO.Path]::GetFullPath($currentPath)
}

function Test-IsoDate {
    param([string]$Date)
    $parsed = [datetime]::MinValue
    return [datetime]::TryParseExact(
        $Date,
        "yyyy-MM-dd",
        [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::None,
        [ref]$parsed
    )
}

function Read-ProjectPipelineRows {
    param([string]$StatusPath)
    $rows = @()
    foreach ($line in Get-Content -Encoding UTF8 -LiteralPath $StatusPath) {
        if ($line -notmatch '^\|\s*(\d+)\s*\|') { continue }
        $cells = @($line.Trim().Trim("|").Split("|") | ForEach-Object { $_.Trim() })
        if ($cells.Count -lt 5 -or $cells[0] -notmatch '^\d+$') { continue }
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

function Get-StructuredSection {
    param([string]$Text, [string]$Heading)
    $match = [regex]::Match($Text, "(?ms)^##\s+$([regex]::Escape($Heading))\s*(.*?)(\r?\n##\s+|\z)")
    if (-not $match.Success) { return "" }
    return $match.Groups[1].Value
}

function Test-StructuredReason {
    param([string]$Section, [string]$Phase, [string]$Status)
    if ([string]::IsNullOrWhiteSpace($Section)) { return $false }
    $pattern = "(?m)^-\s*$([regex]::Escape($Phase)):\s*$([regex]::Escape($Status))\s+—\s*\S"
    return $Section -match $pattern
}

function Test-Contract {
    param(
        [object]$Contract,
        [string]$RootPath,
        [System.Collections.Generic.List[string]]$Failures
    )

    if ($Contract.contractVersion -ne 2) {
        Add-Failure $Failures "Pipeline contractVersion must be 2."
    }

    $phases = @($Contract.phases | Sort-Object number)
    if ($phases.Count -ne 17) {
        Add-Failure $Failures "Pipeline contract must contain 17 phases, found $($phases.Count)."
    }
    foreach ($duplicate in @($phases | Group-Object id | Where-Object Count -gt 1)) {
        Add-Failure $Failures "Pipeline contract has duplicate phase id: $($duplicate.Name)"
    }
    foreach ($duplicate in @($phases | Group-Object number | Where-Object Count -gt 1)) {
        Add-Failure $Failures "Pipeline contract has duplicate phase number: $($duplicate.Name)"
    }

    $phaseIds = @($phases.id)
    for ($index = 0; $index -lt $phases.Count; $index++) {
        if ($phases[$index].number -ne ($index + 1)) {
            Add-Failure $Failures "Pipeline contract phase numbering must be contiguous at $($phases[$index].id)."
        }
        foreach ($dependency in @($phases[$index].dependsOn)) {
            if ($phaseIds -notcontains $dependency) {
                Add-Failure $Failures "Pipeline contract phase $($phases[$index].id) has unknown dependency: $dependency"
            }
        }
    }

    foreach ($entry in @($Contract.primaryPlaybooks) + @($Contract.supportingGuides)) {
        $entryPath = Join-Path $RootPath $entry.path
        if (-not (Test-Path -LiteralPath $entryPath -PathType Leaf)) {
            Add-Failure $Failures "Pipeline contract references missing file: $($entry.id) -> $($entry.path)"
        }
    }
}

function Test-ProjectPipeline {
    param(
        [string]$ProjectPath,
        [object]$Contract,
        [System.Collections.Generic.List[string]]$Failures,
        [string]$RequiredPhase,
        [bool]$MustBeComplete
    )

    if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
        if (-not [string]::IsNullOrWhiteSpace($RequiredPhase) -or $MustBeComplete) {
            Add-Failure $Failures "-RequirePhase/-RequireComplete requires -ProjectRoot."
        }
        return
    }
    if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
        Add-Failure $Failures "ProjectRoot does not exist: $ProjectPath"
        return
    }

    $projectFullPath = Get-CanonicalPath -Path ((Resolve-Path -LiteralPath $ProjectPath).Path)
    $statusPath = Join-Path $projectFullPath "_pipeline-status.md"
    if (-not (Test-Path -LiteralPath $statusPath -PathType Leaf)) {
        Add-Failure $Failures "Project pipeline status missing: $statusPath"
        return
    }

    $statusText = Get-Text $statusPath
    $contractVersion = Get-MetadataValue -Text $statusText -Name "Contract-Version"
    $playbook = Get-MetadataValue -Text $statusText -Name "Playbook"
    $deliveryProfile = Get-MetadataValue -Text $statusText -Name "Delivery-Profile"
    $supportingRaw = Get-MetadataValue -Text $statusText -Name "Supporting-Guides"

    if ($contractVersion -ne [string]$Contract.contractVersion) {
        Add-Failure $Failures "Project pipeline Contract-Version must be $($Contract.contractVersion), found: $contractVersion"
    }

    $playbookEntry = @($Contract.primaryPlaybooks | Where-Object id -eq $playbook)
    if ($playbookEntry.Count -ne 1) {
        Add-Failure $Failures "Project pipeline has unsupported primary playbook: $playbook"
    }
    elseif (@($playbookEntry[0].allowedDeliveryProfiles) -notcontains $deliveryProfile) {
        Add-Failure $Failures "Playbook $playbook does not allow delivery profile: $deliveryProfile"
    }

    $profileEntry = @($Contract.deliveryProfiles | Where-Object id -eq $deliveryProfile)
    if ($profileEntry.Count -ne 1) {
        Add-Failure $Failures "Project pipeline has unsupported delivery profile: $deliveryProfile"
        $expectedNotApplicable = @()
    }
    else {
        $expectedNotApplicable = @($profileEntry[0].notApplicablePhases)
    }

    $allowedGuideIds = @($Contract.supportingGuides.id)
    $supportingGuides = @()
    if (-not [string]::IsNullOrWhiteSpace($supportingRaw) -and $supportingRaw -ne "—") {
        $supportingGuides = @($supportingRaw -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    }
    foreach ($guide in $supportingGuides) {
        if ($allowedGuideIds -notcontains $guide) {
            Add-Failure $Failures "Project pipeline has unsupported supporting guide: $guide"
        }
        if ($guide -eq $playbook) {
            Add-Failure $Failures "Primary playbook must not be repeated as a supporting guide: $guide"
        }
    }

    $phases = @($Contract.phases | Sort-Object number)
    $rows = @(Read-ProjectPipelineRows -StatusPath $statusPath)
    if ($rows.Count -ne $phases.Count) {
        Add-Failure $Failures "Project pipeline must contain $($phases.Count) phases, found $($rows.Count): $statusPath"
    }
    foreach ($duplicate in @($rows | Group-Object Number | Where-Object Count -gt 1)) {
        Add-Failure $Failures "Project pipeline has duplicate phase number: $($duplicate.Name)"
    }
    foreach ($duplicate in @($rows | Group-Object Phase | Where-Object Count -gt 1)) {
        Add-Failure $Failures "Project pipeline has duplicate phase: $($duplicate.Name)"
    }

    $rowsByPhase = @{}
    foreach ($row in $rows) { if (-not $rowsByPhase.ContainsKey($row.Phase)) { $rowsByPhase[$row.Phase] = $row } }
    $allowedStatuses = @("done", "in-progress", "not-applicable", "skipped", "pending")
    $skipSection = Get-StructuredSection -Text $statusText -Heading "Пропуски и причины"
    $notApplicableSection = Get-StructuredSection -Text $statusText -Heading "Неприменимые фазы"
    $completedStatuses = @("done", "not-applicable", "skipped")

    foreach ($phase in $phases) {
        if (-not $rowsByPhase.ContainsKey($phase.id)) {
            Add-Failure $Failures "Project pipeline missing phase $($phase.number): $($phase.id)"
            continue
        }
        $row = $rowsByPhase[$phase.id]
        if ($row.Number -ne $phase.number) {
            Add-Failure $Failures "Project pipeline phase $($phase.id) must use number $($phase.number), found $($row.Number)"
        }
        if ($allowedStatuses -notcontains $row.Status) {
            Add-Failure $Failures "Project pipeline phase $($phase.id) has unsupported status: $($row.Status)"
            continue
        }

        if ($row.Status -eq "pending") {
            if ($row.Date -ne "—" -and -not (Test-IsoDate -Date $row.Date)) {
                Add-Failure $Failures "Project pipeline pending phase $($phase.id) must use YYYY-MM-DD date or —"
            }
        }
        elseif (-not (Test-IsoDate -Date $row.Date)) {
            Add-Failure $Failures "Project pipeline phase $($phase.id) must use YYYY-MM-DD date"
        }

        $mustBeNotApplicable = $expectedNotApplicable -contains $phase.id
        if ($mustBeNotApplicable -and $row.Status -ne "not-applicable") {
            Add-Failure $Failures "Delivery profile $deliveryProfile requires not-applicable phase: $($phase.id)"
        }
        if (-not $mustBeNotApplicable -and $row.Status -eq "not-applicable") {
            Add-Failure $Failures "Delivery profile $deliveryProfile cannot mark phase not-applicable: $($phase.id)"
        }
        if ($row.Status -eq "not-applicable" -and -not (Test-StructuredReason -Section $notApplicableSection -Phase $phase.id -Status "not-applicable")) {
            Add-Failure $Failures "Project pipeline not-applicable phase has no reason: $($phase.id)"
        }

        if ($row.Status -eq "skipped") {
            if (@($Contract.optionalSkippedPhases) -notcontains $phase.id) {
                Add-Failure $Failures "Project pipeline cannot skip required phase: $($phase.id)"
            }
            if (-not (Test-StructuredReason -Section $skipSection -Phase $phase.id -Status "skipped")) {
                Add-Failure $Failures "Project pipeline skipped phase has no reason: $($phase.id)"
            }
        }

        if ($row.Status -in @("done", "in-progress")) {
            foreach ($dependency in @($phase.dependsOn)) {
                if (-not $rowsByPhase.ContainsKey($dependency) -or $completedStatuses -notcontains $rowsByPhase[$dependency].Status) {
                    Add-Failure $Failures "Project pipeline phase $($phase.id) has incomplete dependency: $dependency"
                }
            }
        }

        if ($row.Status -eq "done") {
            $artifact = Get-ArtifactToken -Text $row.Artifact
            if ($artifact -ne $phase.artifact) {
                Add-Failure $Failures "Project pipeline phase $($phase.id) must use canonical artifact: $($phase.artifact)"
                continue
            }
            $artifactPath = Get-CanonicalPath -Path ([System.IO.Path]::Combine($projectFullPath, $artifact))
            $relative = [System.IO.Path]::GetRelativePath($projectFullPath, $artifactPath)
            if ($relative -eq ".." -or $relative.StartsWith("..$([System.IO.Path]::DirectorySeparatorChar)")) {
                Add-Failure $Failures "Project pipeline artifact must stay inside ProjectRoot: $($phase.id) -> $artifact"
                continue
            }
            if (-not (Test-Path -LiteralPath $artifactPath -PathType Leaf)) {
                Add-Failure $Failures "Project pipeline done phase missing artifact: $($phase.id) -> $artifact"
                continue
            }
            if ((Get-Item -LiteralPath $artifactPath).Length -eq 0) {
                Add-Failure $Failures "Project pipeline done phase artifact is empty: $($phase.id) -> $artifact"
                continue
            }

            if ($Contract.artifactMarkers.PSObject.Properties.Name -contains $playbook) {
                $playbookMarkers = $Contract.artifactMarkers.$playbook
                if ($playbookMarkers.PSObject.Properties.Name -contains $phase.id) {
                    $artifactText = Get-Text $artifactPath
                    foreach ($marker in @($playbookMarkers.($phase.id))) {
                        if (-not $artifactText.Contains($marker)) {
                            Add-Failure $Failures "Project pipeline artifact $artifact is missing marker for ${playbook}: $marker"
                        }
                    }
                }
            }
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($RequiredPhase)) {
        if (@($phases.id) -notcontains $RequiredPhase) {
            Add-Failure $Failures "Unknown -RequirePhase value: $RequiredPhase"
        }
        elseif (-not $rowsByPhase.ContainsKey($RequiredPhase) -or $completedStatuses -notcontains $rowsByPhase[$RequiredPhase].Status) {
            Add-Failure $Failures "Required phase is not complete: $RequiredPhase"
        }
    }
    if ($MustBeComplete) {
        foreach ($phase in $phases) {
            if (-not $rowsByPhase.ContainsKey($phase.id) -or $completedStatuses -notcontains $rowsByPhase[$phase.id].Status) {
                Add-Failure $Failures "Project pipeline is not complete: $($phase.id)"
            }
        }
    }
}

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$failures = [System.Collections.Generic.List[string]]::new()
if ([string]::IsNullOrWhiteSpace($ContractPath)) {
    $ContractPath = Join-Path $rootPath "resources/site-pipeline-contract.json"
}
if (-not (Test-Path -LiteralPath $ContractPath -PathType Leaf)) {
    Add-Failure $failures "Pipeline contract missing: $ContractPath"
    $contract = $null
}
else {
    try { $contract = Get-Content -Raw -Encoding UTF8 -LiteralPath $ContractPath | ConvertFrom-Json }
    catch { Add-Failure $failures "Pipeline contract is invalid JSON: $($_.Exception.Message)"; $contract = $null }
}

if ($null -ne $contract) {
    Test-Contract -Contract $contract -RootPath $rootPath -Failures $failures
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
    foreach ($phase in @($contract.phases | Sort-Object number)) {
        foreach ($document in @(
            @{ Name = "site-pipeline-map.md"; Text = $pipelineMap },
            @{ Name = "pipeline-status.md"; Text = $pipelineStatus }
        )) {
            if ($document.Text -and $document.Text -notmatch "\|\s*$($phase.number)\s*\|\s*$([regex]::Escape($phase.id))\s*\|") {
                Add-Failure $failures "$($document.Name) missing phase $($phase.number): $($phase.id)"
            }
        }
    }
    foreach ($document in @(
        @{ Name = "build-modern-site SKILL.md"; Text = $buildSkill },
        @{ Name = "UserPromptSubmit hook"; Text = $hook },
        @{ Name = "build-modern-site openai.yaml"; Text = $openAiYaml }
    )) {
        if ($document.Text -and -not $document.Text.Contains("site-pipeline-map.md")) {
            Add-Failure $failures "$($document.Name) must reference site-pipeline-map.md"
        }
        if ($document.Text -and -not ($document.Text -match "17\s+фаз|17 phases")) {
            Add-Failure $failures "$($document.Name) must state 17 phases."
        }
    }
    if ($buildSkill -and -not $buildSkill.Contains("site-pipeline-contract.json")) {
        Add-Failure $failures "build-modern-site SKILL.md must reference site-pipeline-contract.json"
    }
    if ($fullCycle -and (($fullCycle -notmatch "13\.\s+Тестирование") -or ($fullCycle -notmatch "14\.\s+Security review"))) {
        Add-Failure $failures "full-cycle.md must keep testing and security review stages for mapping into site-review."
    }

    Test-ProjectPipeline -ProjectPath $ProjectRoot -Contract $contract -Failures $failures `
        -RequiredPhase $RequirePhase -MustBeComplete ([bool]$RequireComplete)
}

Write-Host "Site pipeline verification"
Write-Host "Root: $rootPath"
Write-Host "Contract: $ContractPath"
if (-not [string]::IsNullOrWhiteSpace($ProjectRoot)) { Write-Host "ProjectRoot: $ProjectRoot" }
if ($null -ne $contract) { Write-Host "Expected phases: $(@($contract.phases).Count)" }
Write-Host "Failures: $($failures.Count)"
foreach ($failure in $failures) { Write-Host "- $failure" }
if ($failures.Count -gt 0) { exit 1 }
exit 0
