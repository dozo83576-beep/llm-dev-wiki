<#
    Stop-hook петли самообучения для Claude Code.

    Механика (исправлено 2026-07-02, аудит local-market-woo):
    - Раньше подсказка писалась в stderr при exit 0 — по семантике хуков Claude Code
      такой вывод не попадает ни модели, ни пользователю в desktop-приложении,
      поэтому петля /capture-learnings фактически не замыкалась.
    - Теперь хук отдаёт JSON {"decision":"block","reason":...} в stdout: Claude получает
      reason как инструкцию и либо запускает /capture-learnings, либо коротко отвечает,
      что фиксировать нечего.
    - Троттлинг маркер-файлом (>= $throttleMinutes между срабатываниями) + проверка
      stop_hook_active из stdin защищают от зацикливания.
#>
$ErrorActionPreference = 'SilentlyContinue'

# Claude Code читает stdin/stdout хука как UTF-8, а PowerShell по умолчанию использует OEM
# (cp866 на русской Windows) — без этих строк кириллица приходит кракозябрами.
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

$throttleMinutes = 30
$marker = Join-Path $env:TEMP 'agent-capture-reminder.marker'
$now = Get-Date

# Защита от петли: если это продолжение после нашего же блока, молча выходим.
$stdin = [Console]::In.ReadToEnd()
if ($stdin -match '"stop_hook_active"\s*:\s*true') {
    exit 0
}

if (Test-Path -LiteralPath $marker) {
    $last = (Get-Item -LiteralPath $marker).LastWriteTime
    if (($now - $last).TotalMinutes -lt $throttleMinutes) {
        exit 0
    }
}

Set-Content -LiteralPath $marker -Value $now.ToString('o') -Encoding UTF8

$reason = '[capture-loop] Перед завершением: если в этой сессии были одобренные решения, предпочтения, дизайн-выборы или переиспользуемый опыт/ошибка — запусти /capture-learnings и зафиксируй их. Если фиксировать нечего — ответь одной строкой, что фиксировать нечего, и заверши.'

# Enforcement дат ревизии (WS4, 2026-07-04): у записей AGENT-PREFERENCES.local.md
# есть "Review after: <дата>", но раньше их никто не проверял. Хук — естественная
# точка: срабатывает в момент рефлексии, уже троттлится.
$prefFile = 'D:\Work\AGENT-PREFERENCES.local.md'
if (Test-Path -LiteralPath $prefFile) {
    $expired = @()
    $currentTitle = ''
    foreach ($line in (Get-Content -LiteralPath $prefFile -Encoding UTF8)) {
        if ($line -match '^###\s+(.+)$') {
            $currentTitle = $Matches[1].Trim()
        }
        elseif ($line -match 'Review after:\s*(\d{4}-\d{2}-\d{2})') {
            # ISO-даты сравниваются лексикографически — парсер не нужен.
            if ($Matches[1] -lt $now.ToString('yyyy-MM-dd')) {
                $expired += $currentTitle
            }
        }
    }
    if ($expired.Count -gt 0) {
        $reason += " ⚠ Просрочены на ревизию $($expired.Count) предпочтений в AGENT-PREFERENCES.local.md: " + ($expired -join '; ') + '. Предложи пользователю пересмотреть их (подтвердить/обновить/удалить).'
    }
}

@{ decision = 'block'; reason = $reason } | ConvertTo-Json -Compress
exit 0
