<#
.SYNOPSIS
    Проверяет каталог скиллов на соответствие открытому стандарту Agent Skills (agentskills.io).

.DESCRIPTION
    Обёртка над валидатором `agentskills` (пакет skills-ref), который умеет проверять
    только один скилл за вызов. Обходит каталог рекурсивно — вложенные скиллы вроде
    superpowers/* тоже попадают в проверку.

    Отличает два класса провалов, иначе отчёт превращается в шум:

    - FAIL — нарушение стандарта: битый YAML, неверное имя, отсутствие обязательных полей,
      посторонние поля, не читаемые ни одним рантаймом.
    - VENDOR — поле, которого нет в стандарте, но которое реально читает Claude Code
      (см. $VendorFields). Такие поля несут поведение: `disable-model-invocation: true`
      делает скилл вызываемым только слэш-командой. Их удаление ломает скилл, поэтому
      это предупреждение, а не провал.

    Скилл, у которого есть и vendor-поле, и настоящее нарушение, считается FAIL.

.PARAMETER Root
    Каталог со скиллами. Например ~/.claude/skills, ~/.agents/skills, D:\Work\.agent-skills.

.PARAMETER VendorFields
    Поля вне стандарта, которые считаются намеренными. Правь список, только убедившись,
    что рантайм поле действительно читает.

.PARAMETER FailOnVendor
    Считать vendor-поля провалом. Нужно, когда каталог готовится к переносу на рантайм,
    который этих полей не понимает.

.PARAMETER KnownExceptions
    Скиллы, чьи нарушения признаны и не чинятся. Только для чужих скиллов: правка чужого
    SKILL.md молча откатится при следующем `npx skills update`, поэтому чинить его локально
    бессмысленно. Свои скиллы сюда добавлять нельзя — их надо чинить.
    Отчёт показывает такие скиллы отдельно и не роняет выход.

.EXAMPLE
    pwsh tools/validate-skills-spec.ps1 -Root "$HOME/.claude/skills"
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Root,

    [string[]]$VendorFields = @("disable-model-invocation", "argument-hint"),

    # Чужие скиллы: agent-reach — поле `triggers`; market-research — flow-стиль в `tags`
    # и поля version/author/compatible_tools вне стандарта. Обновляются из своих репозиториев.
    [string[]]$KnownExceptions = @("agent-reach", "market-research"),

    [switch]$FailOnVendor
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command agentskills -ErrorAction SilentlyContinue)) {
    Write-Error "Валидатор не найден. Установи: uv tool install skills-ref (исполняемый файл называется agentskills)."
    exit 2
}

if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
    Write-Error "Каталог не найден: $Root"
    exit 2
}

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$skillDirs = Get-ChildItem -LiteralPath $rootPath -Recurse -Filter "SKILL.md" -File |
    ForEach-Object { $_.Directory } |
    Sort-Object FullName -Unique

$passed = [System.Collections.Generic.List[string]]::new()
$vendor = [System.Collections.Generic.List[object]]::new()
$excepted = [System.Collections.Generic.List[string]]::new()
$failed = [System.Collections.Generic.List[object]]::new()

foreach ($dir in $skillDirs) {
    $relative = $dir.FullName.Substring($rootPath.Length).TrimStart([char[]]@("\", "/"))
    if ([string]::IsNullOrEmpty($relative)) { $relative = "." }

    $global:LASTEXITCODE = 0
    $output = & agentskills validate $dir.FullName 2>&1
    $text = ($output | ForEach-Object { [string]$_ }) -join " "

    if ($LASTEXITCODE -eq 0) {
        $passed.Add($relative) | Out-Null
        continue
    }

    # Достаём список посторонних полей из сообщения валидатора.
    $unexpected = @()
    if ($text -match "Unexpected fields in frontmatter:\s*([^.]+)\.") {
        $unexpected = $matches[1] -split "\s*,\s*" | ForEach-Object { $_.Trim() } | Where-Object { $_ }
    }

    # Провал считается «только vendor», если посторонние поля найдены,
    # все они из списка известных, и других претензий у валидатора нет.
    $onlyVendorFields = ($unexpected.Count -gt 0) -and
                        (-not ($unexpected | Where-Object { $VendorFields -notcontains $_ }))
    $hasOtherComplaint = $text -match "Invalid YAML|Missing required|must match|Invalid name|too long|not a directory"

    if ($onlyVendorFields -and -not $hasOtherComplaint -and -not $FailOnVendor) {
        $vendor.Add([pscustomobject]@{ Skill = $relative; Fields = ($unexpected -join ", ") }) | Out-Null
    }
    elseif ($KnownExceptions -contains $dir.Name) {
        $excepted.Add($relative) | Out-Null
    }
    else {
        $failed.Add([pscustomobject]@{ Skill = $relative; Message = $text }) | Out-Null
    }
}

Write-Host ""
Write-Host "Agent Skills spec validation"
Write-Host "Root: $rootPath"
Write-Host "Skills: $($skillDirs.Count) | OK: $($passed.Count) | vendor: $($vendor.Count) | исключения: $($excepted.Count) | FAIL: $($failed.Count)"

if ($excepted.Count -gt 0) {
    Write-Host ""
    Write-Host "Известные исключения (чужие скиллы, чинятся у себя в апстриме):"
    foreach ($item in $excepted) {
        Write-Host ("  [EXCEPT] {0}" -f $item)
    }
}

if ($vendor.Count -gt 0) {
    Write-Host ""
    Write-Host "Vendor-поля (вне стандарта, но читаются Claude Code — не удалять):"
    foreach ($item in $vendor) {
        Write-Host ("  [VENDOR] {0} — {1}" -f $item.Skill, $item.Fields)
    }
}

if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Host "Нарушения стандарта:"
    foreach ($item in $failed) {
        Write-Host ("  [FAIL] {0}" -f $item.Skill)
        Write-Host ("         {0}" -f $item.Message)
    }
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "Нарушений стандарта нет."
exit 0
