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

@{ decision = 'block'; reason = $reason } | ConvertTo-Json -Compress
exit 0
