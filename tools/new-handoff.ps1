param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [Parameter(Mandatory = $true)]
    [string]$ProductionUrl,

    [string]$PreviewUrl = "",
    [string]$RepoUrl = "",
    [int]$SupportDays = 14
)

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "lib\secret-scan.ps1")

function Invoke-GitValue {
    param(
        [string]$Root,
        [string[]]$GitArgs
    )

    $output = & git -C $Root @GitArgs 2>$null
    if ($LASTEXITCODE -ne 0) {
        return ""
    }

    return (($output | Select-Object -First 1) -as [string]).Trim()
}

function Format-Value {
    param(
        [string]$Value,
        [string]$Fallback = "не указано"
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $Fallback
    }

    return $Value.Trim()
}

$rootPath = Resolve-Path -LiteralPath $ProjectRoot
$handoffPath = Join-Path $rootPath "handoff.md"
$today = Get-Date -Format "yyyy-MM-dd"

$branch = Invoke-GitValue -Root $rootPath -GitArgs @("rev-parse", "--abbrev-ref", "HEAD")
$commit = Invoke-GitValue -Root $rootPath -GitArgs @("rev-parse", "--short", "HEAD")
$tag = Invoke-GitValue -Root $rootPath -GitArgs @("describe", "--tags", "--abbrev=0")
$originUrl = Invoke-GitValue -Root $rootPath -GitArgs @("remote", "get-url", "origin")

$resolvedRepoUrl = if ([string]::IsNullOrWhiteSpace($RepoUrl)) { $originUrl } else { $RepoUrl }
$releaseVersion = if ([string]::IsNullOrWhiteSpace($tag)) { "без tag" } else { $tag }

$projectNameText = Format-Value -Value $ProjectName
$productionUrlText = Format-Value -Value $ProductionUrl
$previewUrlText = Format-Value -Value $PreviewUrl
$repoUrlText = Format-Value -Value $resolvedRepoUrl
$branchText = Format-Value -Value $branch
$commitText = Format-Value -Value $commit

$content = @"
# Передача проекта: $projectNameText

> Сгенерировано: $today командой ``tools/new-handoff.ps1``.
> Не записывать в этот файл пароли, токены, cookies, приватные ключи и секретные значения.

## Сводка

| Поле | Значение |
|---|---|
| Production URL | $productionUrlText |
| Preview / staging URL | $previewUrlText |
| Репозиторий | $repoUrlText |
| Дата деплоя | $today |
| Дата передачи | $today |
| Версия релиза | $releaseVersion |
| Commit | $commitText |
| Branch | $branchText |

## Проверка после деплоя

- [ ] Сайт открывается по production-домену.
- [ ] HTTPS работает без предупреждений браузера.
- [ ] Основные страницы открываются без 404/500.
- [ ] Меню, кнопки и внутренние ссылки работают.
- [ ] Формы отправляются.
- [ ] Письма или заявки приходят в согласованный канал.
- [ ] Мобильная версия проверена.
- [ ] Нет тестовых текстов, заглушек и debug-элементов.
- [ ] Нет критичных ошибок в консоли браузера.
- [ ] Страница 404 работает корректно.
- [ ] SEO/analytics подключены, если входили в задачу.

## Доступы

Не записывать пароли, токены, cookies, приватные ключи и секретные значения. Фиксировать только сервис, владельца, способ передачи и ссылку на безопасное хранилище без раскрытия секрета.

| Зона | Сервис / ссылка | Владелец | Как передано | Статус |
|---|---|---|---|---|
| Хостинг |  |  | Приглашение / password manager | [ ] |
| Домен / DNS |  |  | Приглашение / password manager | [ ] |
| CMS / админка |  |  | Приглашение / password manager | [ ] |
| Репозиторий | $repoUrlText |  | Приглашение в GitHub/GitLab | [ ] |
| Аналитика |  |  | Приглашение | [ ] |
| Почта / формы |  |  | Приглашение / password manager | [ ] |
| CRM / API |  |  | Приглашение / password manager | [ ] |
| Платежи |  |  | Приглашение владельца аккаунта | [ ] |

## Что передано заказчику

- [ ] Ссылка на production-сайт.
- [ ] Инструкция входа в админку, если есть админка.
- [ ] Инструкция изменения контента.
- [ ] Инструкция просмотра заявок.
- [ ] Ссылка на репозиторий или архив исходников.
- [ ] Ссылка на аналитику, если входила в задачу.
- [ ] Условия гарантийной поддержки.

## Сообщение заказчику

Сайт развернут на production:
$productionUrlText

Пожалуйста, проверьте одним списком:
1. Основные страницы.
2. Формы заявок.
3. Контакты, тексты и изображения.
4. Мобильную версию.
5. Сценарии покупки, заявки или регистрации, если они есть.

Баги по согласованному ТЗ исправляются в рамках передачи. Новые функции, новые страницы, изменения дизайна и новые интеграции оцениваются отдельно.

## Подтверждение приемки

| Поле | Значение |
|---|---|
| Дата приемки |  |
| Кто принял |  |
| Где подтверждено |  |
| Комментарий |  |

После подтверждения приемки новые функции, новые страницы, изменения дизайна, новые интеграции и изменения бизнес-логики считаются отдельными задачами.

## Поддержка

- Гарантийный срок: $SupportDays дней.
- В гарантию входят баги по согласованному ТЗ текущего релиза.
- В гарантию не входят новые функции, новые страницы, правки дизайна, новые интеграции, изменение текстов и изменение бизнес-логики.
- Хостинг, домен, платные сервисы и подписки оплачивает заказчик, если не согласовано иначе.
"@

$secretFindings = @(Find-SecretLikeText -Text $content)
if ($secretFindings.Count -gt 0) {
    $summary = ($secretFindings | ForEach-Object { "line $($_.Line): $($_.Rule)" }) -join "; "
    throw "secret-scan: подозрительные данные в сгенерированном handoff.md ($summary). Проверьте параметры ProjectName/ProductionUrl/PreviewUrl/RepoUrl на встроенные credentials/токены и повторите запуск. Файл не записан."
}

[System.IO.File]::WriteAllText($handoffPath, $content, [System.Text.UTF8Encoding]::new($false))

Write-Host "Создан или обновлен handoff.md: $handoffPath"
Write-Host "Проект: $projectNameText"
Write-Host "Production URL: $productionUrlText"
Write-Host "Дата передачи: $today"
Write-Host "Версия релиза: $releaseVersion"
Write-Host "Commit: $commitText"
Write-Host "Branch: $branchText"
Write-Host "Важно: секреты и пароли в handoff.md не записывать."
