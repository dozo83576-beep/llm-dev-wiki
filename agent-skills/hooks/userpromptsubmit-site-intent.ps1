<#
    Неактивный по умолчанию UserPromptSubmit-хук: подсказка для preflight сайта.

    Зачем: вход в пайплайн по триггер-фразе был вероятностным (зависел от внимания
    модели). Если владелец когда-либо включит хук явно, он только требует preflight,
    но не выбирает полный маршрут за модель и не перечисляет обязательные фазы.

    Поведение:
    - Нет матча / мета-разговор о самой системе / уже инъецировано в этой сессии
      → мгновенный exit 0 без вывода (fast path).
    - Матч → JSON hookSpecificOutput.additionalContext (см. ниже), маркер сессии.
#>
$ErrorActionPreference = 'SilentlyContinue'

# stdin/stdout хука читаются как UTF-8; без этого кириллица уходит кракозябрами (cp866).
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$stdin = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($stdin)) { exit 0 }

$payload = $null
try { $payload = $stdin | ConvertFrom-Json } catch { exit 0 }
$prompt = [string]$payload.prompt
if ([string]::IsNullOrWhiteSpace($prompt)) { exit 0 }

$normalized = $prompt.ToLowerInvariant()

# Исключения: мета-разговоры о самой системе создания сайтов / вики / скиллах / аудите.
$excludePatterns = @(
    'систем[аеыу].{0,20}создани',
    'вики', 'wiki', 'skill', 'скилл', 'хук', 'hook',
    'аудит', 'ревью систем', 'review систем', 'оркестратор', 'пайплайн'
)
foreach ($pattern in $excludePatterns) {
    if ($normalized -match $pattern) { exit 0 }
}

# Интент нового сайта.
$intentPatterns = @(
    'создат[ьи].{0,40}(сайт|лендинг|магазин|маркетплейс|веб-приложени)',
    'хочу\s+(создать\s+)?сайт',
    'нов(ый|ого)\s+сайт',
    'сделай(те)?\s+.{0,30}(сайт|лендинг)',
    'нужен\s+(сайт|лендинг|интернет-магазин|маркетплейс)',
    'веб-приложени.{0,20}с нуля',
    'собер[иё]м?\s+.{0,20}(сайт|лендинг)'
)
$matched = $false
foreach ($pattern in $intentPatterns) {
    if ($normalized -match $pattern) { $matched = $true; break }
}
if (-not $matched) { exit 0 }

# Одна инъекция на уникальный site-intent в сессии.
$sessionId = [string]$payload.session_id
if ([string]::IsNullOrWhiteSpace($sessionId)) { $sessionId = 'unknown' }
$hashBytes = [System.Security.Cryptography.SHA256]::HashData([System.Text.Encoding]::UTF8.GetBytes($normalized))
$hash = -join ($hashBytes[0..5] | ForEach-Object { $_.ToString('x2') })
$tempRoot = [System.IO.Path]::GetTempPath()
$marker = Join-Path $tempRoot ("site-intent-" + ($sessionId -replace '[^\w-]', '_') + '-' + $hash + '.flag')
if (Test-Path -LiteralPath $marker) { exit 0 }
Set-Content -LiteralPath $marker -Value (Get-Date -Format 'o') -Encoding UTF8

$context = 'Запрос похож на создание сайта. Используй /build-modern-site только как preflight-router: запусти pwsh D:\Work\llm-dev-wiki\tools\new-site-preflight.ps1 -Request "<запрос>" -OutputJson. При routeMode direct не создавай pipeline state; при routeMode full-pipeline следуй contract v2 и только применимым фазам из site-pipeline-map.md.'

@{ hookSpecificOutput = @{ hookEventName = 'UserPromptSubmit'; additionalContext = $context } } | ConvertTo-Json -Compress
exit 0
