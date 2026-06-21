<#
    Периодическая проверка свежести стека для llm-dev-wiki.
    Запускает tools\check-updates.ps1 (technology-watchlist: npm/pypi/github) и пишет датированный лог.
    Неблокирующий: ошибки сети не валят запуск. Предназначен для запуска по расписанию (Task Scheduler).
#>
param(
    [string]$WikiRoot = 'D:\Work\llm-dev-wiki'
)

$ErrorActionPreference = 'Continue'

$logDir = 'D:\Work\.agent-skills\logs'
if (-not (Test-Path -LiteralPath $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

$stamp = (Get-Date).ToString('yyyy-MM-dd_HHmm')
$log = Join-Path $logDir "freshness-$stamp.log"
$checkScript = Join-Path $WikiRoot 'tools\check-updates.ps1'

("[{0}] Старт проверки свежести стека (WikiRoot={1})" -f (Get-Date -Format o), $WikiRoot) | Tee-Object -FilePath $log

if (-not (Test-Path -LiteralPath $checkScript)) {
    ("[{0}] ОШИБКА: не найден {1}" -f (Get-Date -Format o), $checkScript) | Tee-Object -FilePath $log -Append
    exit 1
}

try {
    & pwsh -NoProfile -File $checkScript -Root $WikiRoot *>&1 | Tee-Object -FilePath $log -Append
}
catch {
    ("[{0}] Проверка завершилась с ошибкой (non-blocking): {1}" -f (Get-Date -Format o), $_) | Tee-Object -FilePath $log -Append
}

("[{0}] Готово. Лог: {1}" -f (Get-Date -Format o), $log) | Tee-Object -FilePath $log -Append
exit 0
