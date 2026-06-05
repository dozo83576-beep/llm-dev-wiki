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
        foreach ($line in Get-Content -LiteralPath $file.FullName -Encoding UTF8) {
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

function Test-TechnologyWatchlist {
    param(
        [string]$RootPath,
        [System.Collections.Generic.List[string]]$Failures
    )

    $watchlistPath = Join-Path $RootPath "resources/technology-watchlist.json"
    if (-not (Test-Path -LiteralPath $watchlistPath)) {
        Add-Failure $Failures "Missing technology watchlist: resources/technology-watchlist.json"
        return
    }

    try {
        $entries = Get-Content -Raw -Encoding UTF8 -LiteralPath $watchlistPath | ConvertFrom-Json
    }
    catch {
        Add-Failure $Failures "Invalid technology watchlist JSON: $($_.Exception.Message)"
        return
    }

    $allowedEcosystems = @("npm", "pypi", "github-releases", "github-tags", "manual")
    $index = 0
    foreach ($entry in $entries) {
        $index++
        foreach ($field in @("name", "ecosystem", "docsUrl", "notes")) {
            if (-not $entry.PSObject.Properties.Name.Contains($field) -or [string]::IsNullOrWhiteSpace([string]$entry.$field)) {
                Add-Failure $Failures ("Watchlist entry {0} missing required field: {1}" -f $index, $field)
            }
        }

        if ($entry.ecosystem -and $allowedEcosystems -notcontains $entry.ecosystem) {
            Add-Failure $Failures ("Watchlist entry {0} has unsupported ecosystem: {1}" -f $index, $entry.ecosystem)
        }

        if ($entry.ecosystem -in @("npm", "pypi") -and [string]::IsNullOrWhiteSpace([string]$entry.package)) {
            Add-Failure $Failures ("Watchlist entry {0} requires package for ecosystem {1}" -f $index, $entry.ecosystem)
        }

        if ($entry.ecosystem -in @("github-releases", "github-tags") -and [string]::IsNullOrWhiteSpace([string]$entry.repository)) {
            Add-Failure $Failures ("Watchlist entry {0} requires repository for ecosystem {1}" -f $index, $entry.ecosystem)
        }
    }
}

function Test-UnfinishedMarkerLine {
    param(
        [string]$Line
    )

    if ($Line -notmatch '(?i)\b(TODO|TBD|FIXME)\b') {
        return $false
    }

    $allowedContexts = @(
        '(?i)\bNo\b.*`?(TODO|TBD|FIXME)`?',
        '(?i)\bNever\s+leave\s+`?(TODO|TBD|FIXME)`?',
        '(?i)Не\s+(пиши|создавать|оставлять)\s+.*`?(TODO|TBD|FIXME)`?',
        '(?i)без\s+`?(TODO|TBD|FIXME)`?',
        '(?i)`?(TODO|TBD|FIXME)`?\s*-?only',
        '(?i)"?(TODO|TBD|FIXME)"?\s+артефакты',
        '(?i)`?(TODO|TBD|FIXME)`?\s*/\s*`?(TODO|TBD|FIXME)`?',
        '(?i)\b(TODO|TBD|FIXME)\b.*(запрещ|нельзя|не допуска)'
    )

    foreach ($pattern in $allowedContexts) {
        if ($Line -match $pattern) {
            return $false
        }
    }

    return $true
}

function Get-FrontMatterMap {
    param(
        [string]$Content
    )

    $frontMatter = @{}
    if ($Content -notmatch '(?ms)^---\s*\r?\n(.*?)\r?\n---') {
        return $frontMatter
    }

    foreach ($line in ($matches[1] -split "\r?\n")) {
        if ([string]::IsNullOrWhiteSpace($line) -or $line.TrimStart().StartsWith("#")) {
            continue
        }
        if ($line -match '^([A-Za-z_][\w-]*)\s*:\s*(.*?)\s*$') {
            $frontMatter[$matches[1]] = $matches[2].Trim()
        }
    }

    return $frontMatter
}

function Test-FrontMatter {
    param(
        [System.IO.FileInfo[]]$MarkdownFiles,
        [string]$RootPath,
        [System.Collections.Generic.List[string]]$Failures
    )

    $contentRoots = @("docs", "stacks", "patterns", "checklists", "prompts", "case-studies", "lessons-learned", "resources", "mcp")
    $requiredFields = @("title", "category", "updated", "status", "tags", "source_priority")
    $allowedStatuses = @("active", "archived", "draft", "redirect", "validated")
    $allowedSourcePriorities = @("internal", "official-docs", "vendor-docs", "mixed", "community", "external-proposal")

    foreach ($file in $MarkdownFiles) {
        $relativePath = $file.FullName.Substring($RootPath.Length + 1).Replace("\", "/")
        $root = ($relativePath -split "/", 2)[0]
        if ($contentRoots -notcontains $root) {
            continue
        }

        $content = Get-Content -Raw -Encoding UTF8 -LiteralPath $file.FullName
        $frontMatter = Get-FrontMatterMap -Content $content
        if ($frontMatter.Count -eq 0) {
            Add-Failure $Failures "Missing front matter: $($file.FullName)"
            continue
        }

        foreach ($field in $requiredFields) {
            if (-not $frontMatter.ContainsKey($field) -or [string]::IsNullOrWhiteSpace([string]$frontMatter[$field])) {
                Add-Failure $Failures ("Missing front matter field '{0}': {1}" -f $field, $file.FullName)
            }
        }

        if ($frontMatter.ContainsKey("status")) {
            $status = ([string]$frontMatter["status"]).Trim(" `"'").ToLowerInvariant()
            if ($allowedStatuses -notcontains $status) {
                Add-Failure $Failures ("Unsupported status '{0}': {1}" -f $frontMatter["status"], $file.FullName)
            }
            if ($status -eq "redirect") {
                $body = ($content -replace '(?ms)^---\s*\r?\n.*?\r?\n---\s*', '').Trim()
                $hasCanonicalLink = $body -match '(?<!\!)\[[^\]]+\]\(([^)]+)\)' -or $body -match '\[\[([^\]]+)\]\]'
                if (-not $hasCanonicalLink) {
                    Add-Failure $Failures "Redirect document has no canonical link: $($file.FullName)"
                }
            }
        }

        if ($frontMatter.ContainsKey("source_priority")) {
            $sourcePriority = ([string]$frontMatter["source_priority"]).Trim(" `"'").ToLowerInvariant()
            if ($allowedSourcePriorities -notcontains $sourcePriority) {
                Add-Failure $Failures ("Unsupported source_priority '{0}': {1}" -f $frontMatter["source_priority"], $file.FullName)
            }
        }
    }
}

$failures = [System.Collections.Generic.List[string]]::new()
$rootPath = Resolve-Path -LiteralPath $Root
$generatedMarkdownReports = @(
    "evals-report.md",
    "pytest-report.txt",
    "tool-tests-report.txt",
    "technology-update-report.md",
    "wiki-quality-report.md",
    ".tmp-github-summary.md"
)
$markdownFiles = Get-ChildItem -LiteralPath $rootPath -Recurse -File |
    Where-Object {
        $_.Extension -in @(".md", ".mdx") -and
        $generatedMarkdownReports -notcontains ($_.FullName.Substring($rootPath.Path.Length + 1) -replace "\\", "/")
    }

if ($markdownFiles.Count -eq 0) {
    Add-Failure $failures "No Markdown files found."
}

$emptyFiles = $markdownFiles | Where-Object { $_.Length -eq 0 }
foreach ($file in $emptyFiles) {
    Add-Failure $failures "Empty Markdown file: $($file.FullName)"
}

$unfinishedMatches = Select-String -Path ($markdownFiles | ForEach-Object FullName) -Encoding UTF8 -Pattern "\b(TODO|TBD|FIXME)\b" -CaseSensitive:$false -ErrorAction SilentlyContinue
foreach ($match in $unfinishedMatches) {
    if (Test-UnfinishedMarkerLine -Line $match.Line) {
        Add-Failure $failures "Unfinished marker: $($match.Path):$($match.LineNumber)"
    }
}

Test-FrontMatter -MarkdownFiles $markdownFiles -RootPath $rootPath -Failures $failures

$checklistPath = Join-Path $rootPath "checklists"
if (Test-Path -LiteralPath $checklistPath) {
    $checklists = Get-ChildItem -LiteralPath $checklistPath -File -Filter *.md
    foreach ($file in $checklists) {
        $hasCheckbox = Select-String -LiteralPath $file.FullName -Encoding UTF8 -Pattern "^- \[[ xX]\]" -Quiet
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
        $hasLink = Select-String -LiteralPath $file.FullName -Encoding UTF8 -Pattern "https?://" -Quiet
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
Test-TechnologyWatchlist -RootPath $rootPath -Failures $failures

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
