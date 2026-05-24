param(
    [string]$Root = (Resolve-Path ".").Path,
    [switch]$FailOnWarnings
)

$ErrorActionPreference = "Stop"

function Add-Warning {
    param(
        [System.Collections.Generic.List[string]]$Warnings,
        [string]$Message
    )
    $Warnings.Add($Message) | Out-Null
}

$rootPath = Resolve-Path -LiteralPath $Root
$warnings = [System.Collections.Generic.List[string]]::new()
$productionRoots = @(
    "docs/02-frontend",
    "docs/03-backend",
    "docs/04-databases",
    "docs/05-auth-security",
    "docs/06-api-design",
    "docs/07-mcp-and-ai-tools",
    "docs/08-devops-deploy",
    "docs/09-testing",
    "docs/13-playbooks",
    "docs/14-llm-indexing"
)

$sectionPatterns = @(
    @{ Name = "usage"; Pattern = "(?im)^##\s+(Когда использовать|Стек по умолчанию|Pipeline|Шаги|Проверки)" },
    @{ Name = "avoid"; Pattern = "(?im)^##\s+(Когда не использовать|Анти-паттерны|Stop conditions|Edge cases)" },
    @{ Name = "production"; Pattern = "(?im)^##\s+(Production-паттерны|Порядок разработки|Правила|Pipeline)" },
    @{ Name = "mistakes"; Pattern = "(?im)^##\s+(Частые ошибки|Анти-паттерны|Риски)" },
    @{ Name = "verification"; Pattern = "(?im)^##\s+(Проверка|Testing strategy|Проверки|Test plan)" },
    @{ Name = "sources"; Pattern = "(?im)(Источник|Источники|https?://)" }
)

$files = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
foreach ($relativeRoot in $productionRoots) {
    $fullRoot = Join-Path $rootPath $relativeRoot
    if (Test-Path -LiteralPath $fullRoot) {
        Get-ChildItem -LiteralPath $fullRoot -Recurse -File |
            Where-Object { $_.Extension -in @(".md", ".mdx") } |
            ForEach-Object { $files.Add($_) | Out-Null }
    }
}

foreach ($file in $files) {
    $content = Get-Content -Raw -LiteralPath $file.FullName
    $relativePath = Resolve-Path -LiteralPath $file.FullName -Relative

    if ($content.Length -lt 700) {
        Add-Warning $warnings ("Short production document: {0} ({1} chars)" -f $relativePath, $content.Length)
    }

    foreach ($section in $sectionPatterns) {
        if ($content -notmatch $section.Pattern) {
            Add-Warning $warnings ("Missing quality section '{0}': {1}" -f $section.Name, $relativePath)
        }
    }
}

Write-Output "# Wiki quality report"
Write-Output ""
Write-Output ("- Checked production documents: {0}" -f $files.Count)
Write-Output ("- Warnings: {0}" -f $warnings.Count)
Write-Output ""

if ($warnings.Count -gt 0) {
    Write-Output "## Warnings"
    Write-Output ""
    foreach ($warning in $warnings) {
        Write-Output ("- {0}" -f $warning)
    }
}
else {
    Write-Output "No quality warnings found."
}

if ($FailOnWarnings -and $warnings.Count -gt 0) {
    exit 1
}

exit 0

