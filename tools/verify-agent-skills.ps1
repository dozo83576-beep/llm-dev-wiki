param(
    [string]$Root = (Resolve-Path ".").Path,
    [string]$RuntimeRoot = "D:\Work\.agent-skills",
    [string]$SkillValidator = "$env:USERPROFILE\.codex\skills\skill-maintainer\scripts\preflight_skills.py",
    [switch]$SkipRuntimeCompare
)

$ErrorActionPreference = "Stop"

function Add-Failure {
    param(
        [System.Collections.Generic.List[string]]$Failures,
        [string]$Message
    )
    $Failures.Add($Message) | Out-Null
}

function Get-RelativeFileHashMap {
    param([string]$Path)

    $root = (Resolve-Path -LiteralPath $Path).Path
    $map = @{}
    Get-ChildItem -LiteralPath $root -Recurse -File |
        Where-Object { $_.FullName -notmatch '\\logs\\' } |
        ForEach-Object {
            $relative = $_.FullName.Substring($root.Length).TrimStart('\')
            $map[$relative] = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
        }
    return $map
}

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$source = Join-Path $rootPath "agent-skills"
$failures = [System.Collections.Generic.List[string]]::new()

if (-not (Test-Path -LiteralPath $source -PathType Container)) {
    Add-Failure $failures "Missing tracked agent-skills directory: $source"
}

if ($failures.Count -eq 0) {
    $skills = Get-ChildItem -LiteralPath $source -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") }
    if ($skills.Count -eq 0) {
        Add-Failure $failures "No skills found under tracked source."
    }

    $unfinished = Select-String -Path (Join-Path $source "*\SKILL.md") -Pattern "\b(TODO|TBD|FIXME)\b" -CaseSensitive:$false -ErrorAction SilentlyContinue
    foreach ($item in $unfinished) {
        Add-Failure $failures "Unfinished marker in $($item.Path):$($item.LineNumber)"
    }

    if (Test-Path -LiteralPath $SkillValidator -PathType Leaf) {
        $validatorOutput = & python $SkillValidator --root $source --json
        if ($LASTEXITCODE -ne 0) {
            Add-Failure $failures "Skill validator failed for tracked source."
            $validatorOutput | Write-Host
        }
    }
    else {
        Write-Host "Skill validator not found, skipped: $SkillValidator"
    }

    if (-not $SkipRuntimeCompare -and (Test-Path -LiteralPath $RuntimeRoot -PathType Container)) {
        $sourceMap = Get-RelativeFileHashMap -Path $source
        $runtimeMap = Get-RelativeFileHashMap -Path $RuntimeRoot
        foreach ($key in $sourceMap.Keys) {
            if (-not $runtimeMap.ContainsKey($key)) {
                Add-Failure $failures "Runtime missing file from tracked source: $key"
            }
            elseif ($runtimeMap[$key] -ne $sourceMap[$key]) {
                Add-Failure $failures "Runtime differs from tracked source: $key"
            }
        }
    }
}

Write-Host "Agent skills verification"
Write-Host "Source: $source"
Write-Host "Runtime: $RuntimeRoot"
Write-Host "Failures: $($failures.Count)"
foreach ($failure in $failures) {
    Write-Host "- $failure"
}

if ($failures.Count -gt 0) {
    exit 1
}
