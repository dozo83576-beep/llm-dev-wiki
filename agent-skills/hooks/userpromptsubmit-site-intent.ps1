<#
    UserPromptSubmit-хук: механический вход в оркестратор build-modern-site.

    Зачем: вход в пайплайн по триггер-фразе был вероятностным (зависел от внимания
    модели) — реальный проект (local-market-woo, 2026-07-02) прошёл мимо оркестратора,
    т.к. plan-режим перехватил управление. Этот хук детектирует интент «новый сайт»
    в тексте запроса и МЕХАНИЧЕСКИ инъецирует требование пайплайна через
    additionalContext — оно попадает в контекст ДО планирования, поэтому работает
    и в plan-режиме.

    Поведение:
    - Нет матча / мета-разговор о самой системе / уже инъецировано в этой сессии
      → мгновенный exit 0 без вывода (fast path).
    - Матч → JSON hookSpecificOutput.additionalContext (см. ниже), маркер сессии.
#>
$ErrorActionPreference = 'SilentlyContinue'

# stdout хука читается как UTF-8; без этого кириллица уходит кракозябрами (cp866).
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

# Одна инъекция за сессию.
$sessionId = [string]$payload.session_id
if ([string]::IsNullOrWhiteSpace($sessionId)) { $sessionId = 'unknown' }
$marker = Join-Path $env:TEMP ("site-intent-" + ($sessionId -replace '[^\w-]', '_') + '.flag')
if (Test-Path -LiteralPath $marker) { exit 0 }
Set-Content -LiteralPath $marker -Value (Get-Date -Format 'o') -Encoding UTF8

$context = 'ОБЯЗАТЕЛЬНО: запрос — новый сайт. Войти в скилл /build-modern-site (все 17 фаз), первым шагом запустить pwsh D:\Work\llm-dev-wiki\tools\new-site-preflight.ps1 -Request "<запрос>". Если активен plan-режим — фазы 1–7 пайплайна и есть содержимое плана, и план ОБЯЗАН перечислить все фазы, включая контент (юридические страницы/152-ФЗ), дизайн, SEO и ревью по чеклистам. Молчаливый пропуск фаз запрещён; осознанный пропуск фиксируется в плане с причиной.'

@{ hookSpecificOutput = @{ hookEventName = 'UserPromptSubmit'; additionalContext = $context } } | ConvertTo-Json -Compress
exit 0
