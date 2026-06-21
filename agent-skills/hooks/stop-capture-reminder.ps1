<#
    Stop-hook петли самообучения для Claude Code.
    Неблокирующий (exit 0, без decision) и троттлится, чтобы не напоминать каждый ход.
    Печатает короткую подсказку в stderr (видна пользователю), если с прошлого напоминания
    прошло >= $throttleMinutes. Срабатывает на завершении ответа ассистента.
#>
$ErrorActionPreference = 'SilentlyContinue'

$throttleMinutes = 30
$marker = Join-Path $env:TEMP 'agent-capture-reminder.marker'
$now = Get-Date

if (Test-Path -LiteralPath $marker) {
    $last = (Get-Item -LiteralPath $marker).LastWriteTime
    if (($now - $last).TotalMinutes -lt $throttleMinutes) {
        exit 0
    }
}

Set-Content -LiteralPath $marker -Value $now.ToString('o') -Encoding UTF8

$msg = '[capture-loop] Если в этой задаче были одобренные решения, предпочтения, дизайн-решения или переиспользуемый опыт/ошибка — запусти /capture-learnings, чтобы система самообучилась.'
[Console]::Error.WriteLine($msg)
exit 0
