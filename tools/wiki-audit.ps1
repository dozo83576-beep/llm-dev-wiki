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

function Resolve-WikiLinkTarget {
    param(
        [string]$Target,
        [System.IO.FileInfo]$SourceFile,
        [string]$RootPath,
        [System.IO.FileInfo[]]$MarkdownFiles
    )

    $cleanTarget = $Target.Trim()
    if ([string]::IsNullOrWhiteSpace($cleanTarget)) {
        return $true
    }

    $cleanTarget = ($cleanTarget -split "\|", 2)[0].Trim()
    $cleanTarget = ($cleanTarget -split "#", 2)[0].Trim()

    if ([string]::IsNullOrWhiteSpace($cleanTarget)) {
        return $true
    }

    if ($cleanTarget -match "^[a-zA-Z][a-zA-Z0-9+.-]*:" -or $cleanTarget.StartsWith("#")) {
        return $true
    }

    $candidateTargets = [System.Collections.Generic.List[string]]::new()
    $normalizedTarget = $cleanTarget.Replace("/", [System.IO.Path]::DirectorySeparatorChar)

    if ([System.IO.Path]::IsPathRooted($normalizedTarget)) {
        $candidateTargets.Add($normalizedTarget) | Out-Null
    }
    elseif ($normalizedTarget.StartsWith(".")) {
        $candidateTargets.Add((Join-Path $SourceFile.DirectoryName $normalizedTarget)) | Out-Null
    }
    elseif ($normalizedTarget.Contains([System.IO.Path]::DirectorySeparatorChar)) {
        $candidateTargets.Add((Join-Path $RootPath $normalizedTarget)) | Out-Null
        $candidateTargets.Add((Join-Path $SourceFile.DirectoryName $normalizedTarget)) | Out-Null
    }
    else {
        $candidateTargets.Add((Join-Path $SourceFile.DirectoryName $normalizedTarget)) | Out-Null
        $candidateTargets.Add((Join-Path $RootPath $normalizedTarget)) | Out-Null
    }

    $expandedCandidates = [System.Collections.Generic.List[string]]::new()
    foreach ($candidate in $candidateTargets) {
        $expandedCandidates.Add($candidate) | Out-Null
        if ([System.IO.Path]::GetExtension($candidate) -eq "") {
            $expandedCandidates.Add("$candidate.md") | Out-Null
            $expandedCandidates.Add("$candidate.mdx") | Out-Null
            $expandedCandidates.Add((Join-Path $candidate "index.md")) | Out-Null
            $expandedCandidates.Add((Join-Path $candidate "index.mdx")) | Out-Null
        }
    }

    foreach ($candidate in $expandedCandidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $true
        }
    }

    if (-not $cleanTarget.Contains("/") -and -not $cleanTarget.Contains('\')) {
        $matchingNote = $MarkdownFiles | Where-Object {
            [System.IO.Path]::GetFileNameWithoutExtension($_.Name) -eq $cleanTarget
        } | Select-Object -First 1

        if ($matchingNote) {
            return $true
        }
    }

    return $false
}

function Test-InternalLinks {
    param(
        [System.IO.FileInfo[]]$MarkdownFiles,
        [string]$RootPath,
        [System.Collections.Generic.List[string]]$Failures
    )

    foreach ($file in $MarkdownFiles) {
        $inCodeBlock = $false
        $lineNumber = 0
        foreach ($line in Get-Content -LiteralPath $file.FullName) {
            $lineNumber++
            if ($line.TrimStart().StartsWith('```')) {
                $inCodeBlock = -not $inCodeBlock
                continue
            }
            if ($inCodeBlock) {
                continue
            }

            $wikiMatches = [regex]::Matches($line, '\[\[([^\]]+)\]\]')
            foreach ($match in $wikiMatches) {
                $target = $match.Groups[1].Value
                if (-not (Resolve-WikiLinkTarget -Target $target -SourceFile $file -RootPath $RootPath -MarkdownFiles $MarkdownFiles)) {
                    Add-Failure $Failures ("Broken Obsidian link: {0}:{1} -> [[{2}]]" -f $file.FullName, $lineNumber, $target)
                }
            }

            $markdownMatches = [regex]::Matches($line, '(?<!\!)\[[^\]]+\]\(([^)]+)\)')
            foreach ($match in $markdownMatches) {
                $target = $match.Groups[1].Value.Trim()
                $target = ($target -split "\s+", 2)[0].Trim("<>").Trim()

                if ([string]::IsNullOrWhiteSpace($target) -or
                    $target.StartsWith("#") -or
                    $target.StartsWith("mailto:") -or
                    $target -match "^[a-zA-Z][a-zA-Z0-9+.-]*://") {
                    continue
                }

                if (-not (Resolve-WikiLinkTarget -Target $target -SourceFile $file -RootPath $RootPath -MarkdownFiles $MarkdownFiles)) {
                    Add-Failure $Failures ("Broken Markdown link: {0}:{1} -> {2}" -f $file.FullName, $lineNumber, $target)
                }
            }
        }
    }
}

$failures = [System.Collections.Generic.List[string]]::new()
$rootPath = Resolve-Path -LiteralPath $Root
$markdownFiles = Get-ChildItem -LiteralPath $rootPath -Recurse -File |
    Where-Object { $_.Extension -in @(".md", ".mdx") }

if ($markdownFiles.Count -eq 0) {
    Add-Failure $failures "No Markdown files found."
}

$emptyFiles = $markdownFiles | Where-Object { $_.Length -eq 0 }
foreach ($file in $emptyFiles) {
    Add-Failure $failures "Empty Markdown file: $($file.FullName)"
}

$unfinishedMatches = Select-String -Path ($markdownFiles | ForEach-Object FullName) -Pattern "TODO|TBD" -CaseSensitive:$false -ErrorAction SilentlyContinue
foreach ($match in $unfinishedMatches) {
    Add-Failure $failures "Unfinished marker: $($match.Path):$($match.LineNumber)"
}

$frontMatterRoots = @("docs", "stacks", "patterns")
foreach ($folder in $frontMatterRoots) {
    $folderPath = Join-Path $rootPath $folder
    if (Test-Path -LiteralPath $folderPath) {
        $files = Get-ChildItem -LiteralPath $folderPath -Recurse -File |
            Where-Object { $_.Extension -in @(".md", ".mdx") }
        foreach ($file in $files) {
            $firstLine = Get-Content -LiteralPath $file.FullName -TotalCount 1
            if ($firstLine -ne "---") {
                Add-Failure $failures "Missing front matter: $($file.FullName)"
            }
        }
    }
}

$checklistPath = Join-Path $rootPath "checklists"
if (Test-Path -LiteralPath $checklistPath) {
    $checklists = Get-ChildItem -LiteralPath $checklistPath -File -Filter *.md
    foreach ($file in $checklists) {
        $hasCheckbox = Select-String -LiteralPath $file.FullName -Pattern "^- \[[ xX]\]" -Quiet
        if (-not $hasCheckbox) {
            Add-Failure $failures "Checklist has no checkbox items: $($file.FullName)"
        }
    }
}
else {
    Add-Failure $failures "Missing checklists directory."
}

$resourcePath = Join-Path $rootPath "resources"
if (Test-Path -LiteralPath $resourcePath) {
    $resources = Get-ChildItem -LiteralPath $resourcePath -File -Filter *.md
    foreach ($file in $resources) {
        $hasLink = Select-String -LiteralPath $file.FullName -Pattern "https?://" -Quiet
        if (-not $hasLink) {
            Add-Failure $failures "Resource file has no external links: $($file.FullName)"
        }
    }
}
else {
    Add-Failure $failures "Missing resources directory."
}

$requiredPaths = @(
    "README.md",
    "AGENTS.md",
    "llms.txt",
    "docs/00-start-here/overview.md",
    "docs/01-development-process/stack-selection.md",
    "docs/05-auth-security/MCP-security.md",
    "docs/09-testing/Unit-testing.md",
    "docs/13-playbooks/index.md",
    "docs/14-llm-indexing/index.md",
    "case-studies/successes/_template.md",
    "case-studies/failures/_template.md"
)

foreach ($relativePath in $requiredPaths) {
    $fullPath = Join-Path $rootPath $relativePath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        Add-Failure $failures "Missing required path: $relativePath"
    }
}

Test-InternalLinks -MarkdownFiles $markdownFiles -RootPath $rootPath -Failures $failures

Write-Host "Wiki audit"
Write-Host "Root: $rootPath"
Write-Host "Markdown files: $($markdownFiles.Count)"

if ($failures.Count -gt 0) {
    Write-Host "Failures: $($failures.Count)"
    foreach ($failure in $failures) {
        Write-Host "- $failure"
    }
    exit 1
}

Write-Host "Failures: 0"
exit 0
