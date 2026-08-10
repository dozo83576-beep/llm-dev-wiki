param(
    [string[]]$Roots = @(
        (Join-Path $env:USERPROFILE ".codex\skills"),
        (Join-Path $env:USERPROFILE ".claude\skills"),
        (Join-Path $env:USERPROFILE ".agents\skills")
    ),
    [string]$PolicyPath = (Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..")).Path "resources\skill-capability-policy.json"),
    [string]$QuarantineRoot = "D:\Work\.skill-quarantine",
    [switch]$Quarantine,
    [switch]$Restore,
    [switch]$RefreshManifest,
    [switch]$VerifyQuarantine,
    [string]$ManifestPath = "",
    [switch]$Apply,
    [switch]$OutputJson
)

$ErrorActionPreference = "Stop"

function Get-ContainedPath {
    param([string]$Parent, [string]$Child)
    $parentPath = [IO.Path]::GetFullPath($Parent).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    $childPath = [IO.Path]::GetFullPath($Child)
    if (-not $childPath.StartsWith($parentPath, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path escapes expected root: $childPath"
    }
    return $childPath
}

function Get-DirectoryHash {
    param([string]$Path)
    $root = (Resolve-Path -LiteralPath $Path).Path
    $rows = Get-ChildItem -LiteralPath $root -Recurse -File | Sort-Object FullName | ForEach-Object {
        $relative = $_.FullName.Substring($root.Length).TrimStart('\', '/').Replace('\', '/')
        "$relative=$((Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash)"
    }
    $bytes = [Text.Encoding]::UTF8.GetBytes(($rows -join "`n"))
    return [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes))
}

function Get-SkillVersion {
    param([string]$Path)
    $skillPath = Join-Path $Path "SKILL.md"
    $match = Select-String -LiteralPath $skillPath -Pattern '^\s*version:\s*["'']?([^"'']+)' |
        Select-Object -First 1
    if ($match) { return $match.Matches[0].Groups[1].Value.Trim() }
    return "unknown"
}

function Get-ProviderLabel {
    param([string]$Root)
    $normalized = [IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
    if ($normalized -match '[\\/]\.claude[\\/]skills$') { return "claude" }
    if ($normalized -match '[\\/]\.agents[\\/]skills$') { return "agents" }
    if ($normalized -match '[\\/]\.codex[\\/]skills$') { return "codex" }
    return "other"
}

function Write-Result {
    param($Value)
    if ($OutputJson) {
        $Value | ConvertTo-Json -Depth 10 -Compress
    }
    else {
        $Value | Format-List | Out-Host
    }
}

if ($VerifyQuarantine) {
    $failures = [System.Collections.Generic.List[string]]::new()
    $manifestCount = 0
    $entryCount = 0
    if (Test-Path -LiteralPath $QuarantineRoot -PathType Container) {
        foreach ($manifestPath in Get-ChildItem -LiteralPath $QuarantineRoot -Directory | ForEach-Object { Join-Path $_.FullName "manifest.json" } | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf }) {
            $manifestCount++
            $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
            foreach ($entry in @($manifest.entries)) {
                $entryCount++
                $quarantined = [IO.Path]::GetFullPath([string]$entry.quarantinePath)
                if (-not $quarantined.StartsWith(([IO.Path]::GetFullPath($QuarantineRoot).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase)) {
                    $failures.Add("Quarantine path escapes root: $quarantined") | Out-Null
                    continue
                }
                if (-not (Test-Path -LiteralPath $quarantined -PathType Container)) {
                    $failures.Add("Quarantined skill missing: $quarantined") | Out-Null
                    continue
                }
                if ((Get-DirectoryHash -Path $quarantined) -ne [string]$entry.hash) {
                    $failures.Add("Quarantined skill hash changed: $quarantined") | Out-Null
                }
            }
        }
    }
    Write-Result ([pscustomobject]@{
        mode="verify-quarantine"
        manifests=$manifestCount
        entries=$entryCount
        failures=@($failures)
        failureCount=$failures.Count
    })
    if ($failures.Count -gt 0) { exit 1 }
    exit 0
}

if ($RefreshManifest) {
    if ([string]::IsNullOrWhiteSpace($ManifestPath) -or -not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) {
        throw "-RefreshManifest requires an existing -ManifestPath."
    }
    $manifest = Get-Content -LiteralPath $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($entry in @($manifest.entries)) {
        $quarantined = [IO.Path]::GetFullPath([string]$entry.quarantinePath)
        if (-not (Test-Path -LiteralPath $quarantined -PathType Container)) {
            throw "Quarantined skill missing: $quarantined"
        }
        if ((Get-DirectoryHash -Path $quarantined) -ne [string]$entry.hash) {
            throw "Quarantined skill hash changed: $quarantined"
        }
        $entry | Add-Member -NotePropertyName version -NotePropertyValue (Get-SkillVersion -Path $quarantined) -Force
    }
    $manifest | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $ManifestPath -Encoding UTF8
    Write-Result ([pscustomobject]@{ mode="refresh-manifest"; entries=@($manifest.entries).Count; manifestPath=[IO.Path]::GetFullPath($ManifestPath) })
    exit 0
}

if ($Restore) {
    if ([string]::IsNullOrWhiteSpace($ManifestPath) -or -not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) {
        throw "-Restore requires an existing -ManifestPath."
    }
    $manifest = Get-Content -LiteralPath $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $actions = @()
    foreach ($entry in @($manifest.entries)) {
        $source = [IO.Path]::GetFullPath([string]$entry.sourcePath)
        $quarantined = [IO.Path]::GetFullPath([string]$entry.quarantinePath)
        if (-not (Test-Path -LiteralPath $quarantined -PathType Container)) {
            throw "Quarantined skill missing: $quarantined"
        }
        if (Test-Path -LiteralPath $source) {
            throw "Restore target already exists: $source"
        }
        if ((Get-DirectoryHash -Path $quarantined) -ne [string]$entry.hash) {
            throw "Quarantined skill hash changed: $quarantined"
        }
        $actions += [pscustomobject]@{ operation="restore"; source=$quarantined; target=$source }
        if ($Apply) {
            New-Item -ItemType Directory -Path (Split-Path -Parent $source) -Force | Out-Null
            Move-Item -LiteralPath $quarantined -Destination $source
        }
    }
    Write-Result ([pscustomobject]@{ mode=if($Apply){"restore"}else{"restore-dry-run"}; actions=$actions; manifestPath=[IO.Path]::GetFullPath($ManifestPath) })
    exit 0
}

$expandedRoots = @(
    foreach ($rootItem in $Roots) {
        foreach ($part in ([string]$rootItem -split ',')) {
            if (-not [string]::IsNullOrWhiteSpace($part)) { [IO.Path]::GetFullPath($part.Trim()) }
        }
    }
)
$policy = Get-Content -LiteralPath $PolicyPath -Raw -Encoding UTF8 | ConvertFrom-Json
$active = @{}; foreach ($name in @($policy.catalog.activeSkills)) { $active[[string]$name] = $true }
$quarantinedNames = @{}; foreach ($name in @($policy.catalog.quarantineSkills)) { $quarantinedNames[[string]$name] = $true }
$providerQuarantine = @{}
if ($policy.catalog.providerQuarantine) {
    foreach ($provider in $policy.catalog.providerQuarantine.PSObject.Properties) {
        $names = @{}
        foreach ($name in @($provider.Value)) { $names[[string]$name] = $true }
        $providerQuarantine[[string]$provider.Name] = $names
    }
}
$occurrences = @()
for ($rootIndex = 0; $rootIndex -lt $expandedRoots.Count; $rootIndex++) {
    $root = $expandedRoots[$rootIndex]
    $providerLabel = Get-ProviderLabel -Root $root
    if (-not (Test-Path -LiteralPath $root -PathType Container)) { continue }
    foreach ($dir in Get-ChildItem -LiteralPath $root -Directory) {
        if (-not (Test-Path -LiteralPath (Join-Path $dir.FullName "SKILL.md") -PathType Leaf)) { continue }
        $safePath = Get-ContainedPath -Parent $root -Child $dir.FullName
        $providerBlocked = $providerQuarantine.ContainsKey($providerLabel) -and $providerQuarantine[$providerLabel].ContainsKey($dir.Name)
        $classification = if ($providerBlocked) { "quarantine" } elseif ($active.ContainsKey($dir.Name)) { "active" } elseif ($quarantinedNames.ContainsKey($dir.Name)) { "quarantine" } else { "review" }
        $reason = if ($providerBlocked) { "provider-capability-overlap" } elseif ($classification -eq "quarantine") { "generic-capability-overlap" } elseif ($classification -eq "active") { "approved-active-capability" } else { "manual-review-required" }
        $occurrences += [pscustomobject]@{
            name=$dir.Name; root=$root; rootIndex=$rootIndex; path=$safePath
            hash=(Get-DirectoryHash -Path $safePath); version=(Get-SkillVersion -Path $safePath)
            classification=$classification
            reason=$reason
        }
    }
}

$skills = @($occurrences | Group-Object name | Sort-Object Name | ForEach-Object {
    $group = @($_.Group)
    [pscustomobject]@{
        name=$_.Name
        classification=$group[0].classification
        variants=@($group.hash | Sort-Object -Unique).Count
        occurrences=@($group | ForEach-Object { [pscustomobject]@{ root=$_.root; path=$_.path; hash=$_.hash; version=$_.version; reason=$_.reason } })
    }
})

$actions = @()
$manifestFile = ""
if ($Quarantine) {
    foreach ($item in @($occurrences | Where-Object classification -eq "quarantine")) {
        $rootLabel = "{0:D2}-{1}" -f $item.rootIndex, ((Split-Path -Leaf $item.root) -replace '[^A-Za-z0-9_.-]', '_')
        $actions += [pscustomobject]@{
            operation="quarantine"; name=$item.name; source=$item.path
            target=(Join-Path (Join-Path $QuarantineRoot "<session>") (Join-Path $rootLabel $item.name))
            hash=$item.hash; version=$item.version; reason=$item.reason; root=$item.root; rootLabel=$rootLabel
        }
    }
    if ($Apply -and $actions.Count -gt 0) {
        $session = Get-Date -Format "yyyyMMdd-HHmmssfff"
        $sessionRoot = Get-ContainedPath -Parent $QuarantineRoot -Child (Join-Path $QuarantineRoot $session)
        New-Item -ItemType Directory -Path $sessionRoot -Force | Out-Null
        $entries = @()
        foreach ($action in $actions) {
            $target = Get-ContainedPath -Parent $sessionRoot -Child (Join-Path $sessionRoot (Join-Path $action.rootLabel $action.name))
            if (Test-Path -LiteralPath $target) { throw "Quarantine target already exists: $target" }
            $materializedDependents = @()
            $dependents = @($occurrences | Where-Object {
                $_.name -eq $action.name -and
                $_.path -ne $action.source -and
                $_.classification -ne "quarantine"
            })
            foreach ($dependent in $dependents) {
                $link = Get-Item -LiteralPath $dependent.path -Force
                if (-not $link.LinkType) { continue }
                $linkTargets = @($link.Target)
                if ($linkTargets.Count -eq 0) { continue }
                $resolvedLinkTarget = [IO.Path]::GetFullPath([string]$linkTargets[0])
                if (-not $resolvedLinkTarget.Equals([IO.Path]::GetFullPath($action.source), [StringComparison]::OrdinalIgnoreCase)) { continue }

                $dependentParent = Split-Path -Parent $dependent.path
                $temporary = Get-ContainedPath -Parent $dependentParent -Child (Join-Path $dependentParent (".materialize-{0}" -f [guid]::NewGuid().ToString("N")))
                Copy-Item -LiteralPath $action.source -Destination $temporary -Recurse
                if ((Get-DirectoryHash -Path $temporary) -ne $action.hash) {
                    Remove-Item -LiteralPath $temporary -Recurse -Force
                    throw "Materialized provider copy hash differs: $($dependent.path)"
                }
                Remove-Item -LiteralPath $dependent.path -Force
                Move-Item -LiteralPath $temporary -Destination $dependent.path
                if ((Get-DirectoryHash -Path $dependent.path) -ne $action.hash) {
                    throw "Materialized provider copy verification failed: $($dependent.path)"
                }
                $materializedDependents += [pscustomobject]@{
                    path=$dependent.path
                    previousLinkTarget=$resolvedLinkTarget
                    hash=$action.hash
                }
            }
            New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
            Move-Item -LiteralPath $action.source -Destination $target
            $action.target = $target
            if ((Get-DirectoryHash -Path $target) -ne $action.hash) {
                $donor = @($entries | Where-Object {
                    $_.hash -eq $action.hash -and
                    (Test-Path -LiteralPath $_.quarantinePath -PathType Container)
                } | Select-Object -First 1)
                if ($donor.Count -eq 0) {
                    throw "Quarantine copy hash changed and no identical donor exists: $target"
                }
                Remove-Item -LiteralPath $target -Recurse -Force
                Copy-Item -LiteralPath $donor[0].quarantinePath -Destination $target -Recurse
                if ((Get-DirectoryHash -Path $target) -ne $action.hash) {
                    throw "Quarantine copy hash still differs after donor recovery: $target"
                }
            }
            $entries += [pscustomobject]@{
                name=$action.name
                source="direct-runtime"
                version=$action.version
                hash=$action.hash
                previousRuntimePath=$action.source
                sourcePath=$action.source
                quarantinePath=$target
                originalRoot=$action.root
                reason=$action.reason
                materializedDependents=$materializedDependents
            }
        }
        $manifestFile = Join-Path $sessionRoot "manifest.json"
        $restoreCommand = "pwsh -NoProfile -File `"$PSCommandPath`" -Restore -ManifestPath `"$manifestFile`" -Apply"
        [pscustomobject]@{ schemaVersion=1; createdAt=(Get-Date).ToString('o'); policyPath=[IO.Path]::GetFullPath($PolicyPath); restoreCommand=$restoreCommand; entries=$entries } |
            ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $manifestFile -Encoding UTF8
    }
}

$result = [pscustomobject]@{
    mode=if($Quarantine){if($Apply){"quarantine"}else{"quarantine-dry-run"}}else{"audit"}
    roots=$expandedRoots; skills=$skills; actions=$actions; manifestPath=$manifestFile
}
Write-Result $result
