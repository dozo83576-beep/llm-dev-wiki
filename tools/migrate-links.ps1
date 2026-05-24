param(
    [string]$Root = (Resolve-Path ".").Path,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$rootPath = Resolve-Path -LiteralPath $Root

# Directories to search for content
$contentRoots = @(
    "docs",
    "patterns",
    "prompts",
    "checklists",
    "stacks",
    "case-studies",
    "lessons-learned",
    "mcp",
    "resources"
)

# Build target index: filename (without .md) -> relative path
Write-Output "Building file index..."
$targetIndex = @{}
foreach ($cr in $contentRoots) {
    $full = Join-Path $rootPath $cr
    if (-not (Test-Path -LiteralPath $full)) { continue }
    Get-ChildItem -LiteralPath $full -Recurse -File -Filter "*.md" | ForEach-Object {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
        $rel = $_.FullName.Substring($rootPath.Path.Length + 1) -replace '\\', '/'
        if (-not $targetIndex.ContainsKey($baseName)) {
            $targetIndex[$baseName] = [System.Collections.Generic.List[string]]::new()
        }
        $targetIndex[$baseName].Add($rel) | Out-Null
    }
}
# Also index README.md, AGENTS.md, llms.txt at root
foreach ($n in @("README", "AGENTS", "llms.txt")) {
    $fname = if ($n -eq "llms.txt") { "llms.txt" } else { "$n.md" }
    $p = Join-Path $rootPath $fname
    if (Test-Path -LiteralPath $p) {
        $key = if ($n -eq "llms.txt") { "llms.txt" } else { $n }
        if (-not $targetIndex.ContainsKey($key)) {
            $targetIndex[$key] = [System.Collections.Generic.List[string]]::new()
        }
        $targetIndex[$key].Add($fname) | Out-Null
    }
}

Write-Output ("Indexed {0} target names." -f $targetIndex.Count)

# Collect files to migrate
$filesToMigrate = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
foreach ($cr in $contentRoots) {
    $full = Join-Path $rootPath $cr
    if (-not (Test-Path -LiteralPath $full)) { continue }
    Get-ChildItem -LiteralPath $full -Recurse -File -Filter "*.md" |
        ForEach-Object { $filesToMigrate.Add($_) | Out-Null }
}
# Also root README, AGENTS
foreach ($f in @("README.md", "AGENTS.md")) {
    $p = Join-Path $rootPath $f
    if (Test-Path -LiteralPath $p) {
        $filesToMigrate.Add((Get-Item -LiteralPath $p)) | Out-Null
    }
}

$wikiLinkPattern = '\[\[([^\]\|]+)(?:\|([^\]]+))?\]\]'
$totalReplacements = 0
$brokenRefs = [System.Collections.Generic.List[string]]::new()
$ambiguousRefs = [System.Collections.Generic.List[string]]::new()
$migratedFiles = 0

foreach ($file in $filesToMigrate) {
    $content = Get-Content -Raw -LiteralPath $file.FullName
    if ($content -notmatch $wikiLinkPattern) { continue }

    $fileDir = Split-Path -Parent $file.FullName
    $fileDirAbs = (Resolve-Path -LiteralPath $fileDir).Path

    $newContent = [regex]::Replace($content, $wikiLinkPattern, {
        param($m)
        $target = $m.Groups[1].Value.Trim()
        $label = if ($m.Groups[2].Success) { $m.Groups[2].Value.Trim() } else { $target }

        # Strip anchor / section after #
        $cleanTarget = $target
        $anchor = ""
        if ($target -match '^([^#]+)#(.+)$') {
            $cleanTarget = $matches[1]
            $anchor = "#" + $matches[2]
        }

        # Look up by basename
        $key = Split-Path -Leaf $cleanTarget
        # Also handle paths like "../../checklists/security-review"
        if (-not $targetIndex.ContainsKey($key)) {
            $script:brokenRefs.Add(("{0}: [[{1}]] -> not found" -f $file.FullName, $target)) | Out-Null
            return "[[$($m.Groups[1].Value)$(if ($m.Groups[2].Success) { '|' + $m.Groups[2].Value })]]"
        }

        $candidates = $targetIndex[$key]
        if ($candidates.Count -gt 1) {
            # Try to pick the one matching the path hint
            $bestMatch = $null
            # Strip ../ prefixes and normalize
            $targetNorm = ($cleanTarget -replace '\\', '/') -replace '^(\.\./)+', ''
            foreach ($cand in $candidates) {
                $candNoExt = $cand -replace '\.md$', ''
                if ($candNoExt -eq $targetNorm -or $candNoExt.EndsWith("/" + $targetNorm)) {
                    $bestMatch = $cand
                    break
                }
            }
            # Second pass: match by directory hint (first non-../ segment)
            if (-not $bestMatch -and $targetNorm -match '^([^/]+)/') {
                $dirHint = $matches[1]
                foreach ($cand in $candidates) {
                    if ($cand.StartsWith($dirHint + "/")) {
                        $bestMatch = $cand
                        break
                    }
                }
            }
            if (-not $bestMatch) {
                $script:ambiguousRefs.Add(("{0}: [[{1}]] -> {2} candidates: {3}" -f $file.FullName, $target, $candidates.Count, ($candidates -join ', '))) | Out-Null
                $bestMatch = $candidates[0]  # pick first as best effort
            }
            $targetPath = $bestMatch
        } else {
            $targetPath = $candidates[0]
        }

        # Compute relative path from file to target
        $targetAbs = Join-Path $rootPath $targetPath
        $relPath = [System.IO.Path]::GetRelativePath($fileDirAbs, $targetAbs) -replace '\\', '/'

        $script:totalReplacements++
        return "[$label]($relPath$anchor)"
    })

    if ($newContent -ne $content) {
        $migratedFiles++
        if (-not $DryRun) {
            [System.IO.File]::WriteAllText($file.FullName, $newContent, [System.Text.UTF8Encoding]::new($false))
        }
    }
}

Write-Output ""
Write-Output ("Replacements: {0}" -f $totalReplacements)
Write-Output ("Files modified: {0}" -f $migratedFiles)
Write-Output ("Broken refs: {0}" -f $brokenRefs.Count)
Write-Output ("Ambiguous refs: {0}" -f $ambiguousRefs.Count)

if ($brokenRefs.Count -gt 0) {
    Write-Output ""
    Write-Output "## Broken refs"
    foreach ($r in $brokenRefs) { Write-Output ("- {0}" -f $r) }
}

if ($ambiguousRefs.Count -gt 0) {
    Write-Output ""
    Write-Output "## Ambiguous refs (picked first candidate)"
    foreach ($r in $ambiguousRefs) { Write-Output ("- {0}" -f $r) }
}

if ($DryRun) {
    Write-Output ""
    Write-Output "(dry run — no files written)"
}
