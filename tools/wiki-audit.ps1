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
