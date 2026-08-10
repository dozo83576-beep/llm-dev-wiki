param(
    [string]$Root = (Resolve-Path ".").Path,
    [string]$RuntimeRoot = "D:\Work\.agent-skills",
    [string]$SkillValidator = "$env:USERPROFILE\.codex\skills\skill-maintainer\scripts\preflight_skills.py",
    [switch]$SkipRuntimeCompare,
    [switch]$VerifyUserRuntimes
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
            $relative = $_.FullName.Substring($root.Length).TrimStart([char[]]@("\", "/")).Replace("/", "\")
            $map[$relative] = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
        }
    return $map
}

function Test-SkillRuntime {
    param(
        [string]$SourceRoot,
        [string]$TargetRoot,
        [string]$TargetName,
        [System.Collections.Generic.List[string]]$Failures
    )

    if (-not (Test-Path -LiteralPath $TargetRoot -PathType Container)) {
        Add-Failure $Failures "$TargetName skills directory missing: $TargetRoot"
        return
    }

    $skills = Get-ChildItem -LiteralPath $SourceRoot -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") }

    foreach ($skill in $skills) {
        $targetSkill = Join-Path $TargetRoot $skill.Name
        if (-not (Test-Path -LiteralPath $targetSkill -PathType Container)) {
            Add-Failure $Failures "$TargetName missing skill: $($skill.Name)"
            continue
        }

        $sourceMap = Get-RelativeFileHashMap -Path $skill.FullName
        $targetMap = Get-RelativeFileHashMap -Path $targetSkill
        foreach ($key in $sourceMap.Keys) {
            if (-not $targetMap.ContainsKey($key)) {
                Add-Failure $Failures "$TargetName skill $($skill.Name) missing file: $key"
            }
            elseif ($targetMap[$key] -ne $sourceMap[$key]) {
                Add-Failure $Failures "$TargetName skill $($skill.Name) differs: $key"
            }
        }
    }
}

function Get-ProviderSkillRoot {
    param([string]$Provider)
    switch ($Provider) {
        "claude" { return (Join-Path $env:USERPROFILE ".claude\skills") }
        "agents" { return (Join-Path $env:USERPROFILE ".agents\skills") }
        "codex" { return (Join-Path $env:USERPROFILE ".codex\skills") }
        default { return "" }
    }
}

function Test-PluginEnabledState {
    param(
        [string]$ConfigText,
        [string]$PluginName,
        [bool]$ExpectedEnabled,
        [System.Collections.Generic.List[string]]$Failures
    )
    $escaped = [regex]::Escape($PluginName)
    $pattern = '(?ms)^\[plugins\."' + $escaped + '"\]\s*\r?\n(?:(?!^\[).)*?^enabled\s*=\s*(true|false)\s*$'
    $match = [regex]::Match($ConfigText, $pattern)
    if (-not $match.Success) {
        Add-Failure $Failures "Plugin state missing from Codex config: $PluginName"
        return
    }
    $actual = $match.Groups[1].Value -eq "true"
    if ($actual -ne $ExpectedEnabled) {
        Add-Failure $Failures "Plugin state differs for ${PluginName}: expected enabled=$($ExpectedEnabled.ToString().ToLowerInvariant())"
    }
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
        Write-Warning "Skill validator not found, skipped: $SkillValidator (pass -SkillValidator to point at preflight_skills.py)"
        $script:validatorSkipped = $true
    }

    $semanticVerifier = Join-Path $rootPath "tools\verify_skill_semantics.py"
    $capabilityPolicy = Join-Path $rootPath "resources\skill-capability-policy.json"
    if ((Test-Path -LiteralPath $semanticVerifier -PathType Leaf) -and
        (Test-Path -LiteralPath $capabilityPolicy -PathType Leaf)) {
        $semanticArgs = @("--root", $rootPath)
        if ($VerifyUserRuntimes) { $semanticArgs += "--verify-runtime" }
        $semanticOutput = & python $semanticVerifier @semanticArgs 2>&1
        if ($LASTEXITCODE -ne 0) {
            Add-Failure $failures "Skill semantic verification failed."
            $semanticOutput | Write-Host
        }
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

    if ($VerifyUserRuntimes) {
        Test-SkillRuntime -SourceRoot $source -TargetRoot (Join-Path $env:USERPROFILE ".codex\skills") -TargetName "Codex" -Failures $failures
        Test-SkillRuntime -SourceRoot $source -TargetRoot (Join-Path $env:USERPROFILE ".claude\skills") -TargetName "Claude Code" -Failures $failures
        Test-SkillRuntime -SourceRoot $source -TargetRoot (Join-Path $env:USERPROFILE ".agents\skills") -TargetName "Shared agents" -Failures $failures

        if (Test-Path -LiteralPath $capabilityPolicy -PathType Leaf) {
            $policy = Get-Content -LiteralPath $capabilityPolicy -Raw -Encoding UTF8 | ConvertFrom-Json
            $userSkillRoots = @(
                (Join-Path $env:USERPROFILE ".codex\skills"),
                (Join-Path $env:USERPROFILE ".claude\skills"),
                (Join-Path $env:USERPROFILE ".agents\skills")
            )
            foreach ($name in @($policy.catalog.forbiddenActiveSkills)) {
                foreach ($userRoot in $userSkillRoots) {
                    if (Test-Path -LiteralPath (Join-Path $userRoot ([string]$name)) -PathType Container) {
                        Add-Failure $failures "Forbidden direct skill is active: $name at $userRoot"
                    }
                }
            }
            if ($policy.catalog.providerQuarantine) {
                foreach ($provider in $policy.catalog.providerQuarantine.PSObject.Properties) {
                    $providerRoot = Get-ProviderSkillRoot -Provider $provider.Name
                    if ([string]::IsNullOrWhiteSpace($providerRoot)) { continue }
                    foreach ($name in @($provider.Value)) {
                        if (Test-Path -LiteralPath (Join-Path $providerRoot ([string]$name)) -PathType Container) {
                            Add-Failure $failures "Provider-specific overlap is active: $name at $providerRoot"
                        }
                    }
                }
            }

            $codexConfig = Join-Path $env:USERPROFILE ".codex\config.toml"
            if (Test-Path -LiteralPath $codexConfig -PathType Leaf) {
                $configText = Get-Content -LiteralPath $codexConfig -Raw -Encoding UTF8
                foreach ($plugin in $policy.pluginPolicy.PSObject.Properties) {
                    if ($plugin.Value.managedByConfig -eq $false) { continue }
                    if ($null -ne $plugin.Value.enabled) {
                        Test-PluginEnabledState -ConfigText $configText -PluginName $plugin.Name -ExpectedEnabled ([bool]$plugin.Value.enabled) -Failures $failures
                    }
                }
            }
            else {
                Add-Failure $failures "Codex plugin config missing: $codexConfig"
            }
        }
    }

    # Второй проход: соответствие открытому стандарту Agent Skills (agentskills.io).
    # Ловит то, чего не видит сравнение хешей: посторонние поля frontmatter, битый YAML,
    # расхождение name с именем каталога — всё, что ломает перенос скилла на Codex/Gemini/Cursor.
    # Пропускается, если валидатор не установлен: uv tool install skills-ref
    $specValidator = Join-Path $PSScriptRoot "validate-skills-spec.ps1"
    if ((Test-Path -LiteralPath $specValidator -PathType Leaf) -and (Get-Command agentskills -ErrorAction SilentlyContinue)) {
        $global:LASTEXITCODE = 0
        $specOutput = & $specValidator -Root $source 2>&1
        if ($LASTEXITCODE -ne 0) {
            Add-Failure $failures "Agent Skills spec validation failed for tracked source."
            $specOutput | Write-Host
        }
    }
    else {
        Write-Warning "Agent Skills spec validator not available, skipped (uv tool install skills-ref)."
    }
}

Write-Host "Agent skills verification"
Write-Host "Source: $source"
Write-Host "Runtime: $RuntimeRoot"
if ($VerifyUserRuntimes) {
    Write-Host "User runtimes: enabled"
}
if ($script:validatorSkipped) {
    Write-Host "Validator: SKIPPED (not found)"
}
Write-Host "Failures: $($failures.Count)"
foreach ($failure in $failures) {
    Write-Host "- $failure"
}

if ($failures.Count -gt 0) {
    exit 1
}
