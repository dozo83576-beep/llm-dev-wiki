---
name: capture-learnings
description: >-
  Фиксирует переиспользуемое знание после задачи в D:\Work. Использовать, когда пользователь явно
  одобрил подход, стиль, шрифт, референс, стек или запрет, либо когда задача дала паттерн, ошибку
  или риск, полезные в следующий раз. Личные предпочтения → AGENT-PREFERENCES.local.md через
  PowerShell-инструмент со сканом секретов и dry-run; обезличенные паттерны и кейсы → llm-dev-wiki.
---

# capture-learnings

Отделить подтверждённое знание от шума и направить в нужный сток, ничего приватного не сохранив.

Вызывается вручную или когда в работе появилось что-то, что пригодится в следующий раз. Не для
каждой задачи: нет явного одобрения и нет свидетельств (команды, diff, тесты, источники, отзыв
пользователя) — значит фиксировать нечего, так и скажи.

Детали классификации и роутинга — `D:\Work\llm-dev-wiki\prompts\post-task-learning-review.md`,
правила предпочтений — `prompts\update-user-preferences.md`, правила вики — `prompts\update-wiki.md`.
Читай их, когда дошло до соответствующего шага.

## Личные предпочтения

Только через инструмент — он сканирует секреты и PII. Руками файл не дописывать.

```
pwsh D:\Work\llm-dev-wiki\tools\update-local-preferences.ps1 -DryRun `
  -Title "<кратко>" -Scope "global|site-building|frontend|backend|design|project:<name>" `
  -Preference "<что предпочитать>" -Avoid "<что не предлагать>" `
  -Evidence "<user approval | project result | test | diff | source>" `
  -ReviewAfter "<дата или условие>" -Links "<безопасные ссылки>"
```

Сначала `-DryRun`, `-Apply` — после подтверждения пользователя. Если инструмент заблокировал запись,
значит в ней токен, ключ, cookie, пароль или PII — переформулируй без них.

Перед записью посмотри `AGENT-PREFERENCES.local.md`: обнови существующую запись, а не плоди дубль.

## Обезличенное знание → вики

- Удачный приём → `llm-dev-wiki\patterns\<area>\<pattern-name>.md`
- Успех → `case-studies\successes\YYYY-MM-DD-<slug>.md`
- Ошибка или риск → `case-studies\failures\...` либо `lessons-learned\YYYY-MM-DD-<topic>.md`
- Новый критерий ревью → файл в `checklists\`

Проверь существующие артефакты и шаблоны `_template-*.md` — обновляй, а не дублируй. Секреты, PII,
приватный код, клиентские payload и личные референсы в вики не уходят.

Если знание привязано к конкретному проекту, добавь в его `AGENTS.md` секцию `## Связанные знания`
со ссылками — вернувшись через полгода, агент увидит документированные решения.

## После правок

Менялась вики:
```
pwsh D:\Work\llm-dev-wiki\tools\ci-local.ps1
```

Менялись файлы в `llm-dev-wiki\agent-skills\` — раскатай канон, иначе рантаймы останутся на старой
версии. Последняя команда нужна локально: GitHub CI не видит пользовательские skill-каталоги.
```
pwsh D:\Work\llm-dev-wiki\agent-skills\sync-skills.ps1 -DryRun
pwsh D:\Work\llm-dev-wiki\agent-skills\sync-skills.ps1
pwsh D:\Work\llm-dev-wiki\tools\verify-agent-skills.ps1 -VerifyUserRuntimes
```

## Итог

Короткое резюме: что сохранено, что предложено в вики, что осталось за пользователем. В проекте
сайта сложи его в `_learning-review.md` — это evidence финальной фазы пайплайна.
