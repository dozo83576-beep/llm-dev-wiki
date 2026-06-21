---
name: capture-learnings
description: >-
  Замыкает петлю самообучения после завершённой задачи или значимого этапа в D:\Work. Использовать,
  когда пользователь явно одобрил подход, стиль, шрифт, референс, стек, дизайн-решение, запрет или
  повторяемый приём, либо когда задача дала переиспользуемое знание, ошибку или риск. Решает, что
  сохранить, и куда: личные предпочтения → D:\Work\AGENT-PREFERENCES.local.md (через безопасный
  PowerShell-инструмент со сканом секретов и dry-run); обезличенные паттерны/кейсы/уроки → wiki
  (предлагается, подтверждается вручную). Триггерится Stop-hook'ом slash-command runtime, правилом AGENTS.md
  в Codex и ручным вызовом.
---

# capture-learnings — петля самообучения

Тонкий роутер логики `D:\Work\llm-dev-wiki\prompts\post-task-learning-review.md`. Цель — отделить
подтверждённое знание от шума и направить его в правильный сток, не сохранив ничего приватного.

## Когда использовать
- Пользователь явно сказал «запомни», одобрил или повторно подтвердил предпочтение/приём.
- Завершена задача с новым стеком, риском, удачным приёмом, hard-won fix или ошибкой.

## Когда НЕ использовать / отказ
- Нет явного approval и нет evidence (команды, diff, тесты, источники, user feedback) — не выдумывать опыт.
- Тривиальная задача без переиспользуемого знания — зафиксируй `no artifact needed` и причину.

## Сначала прочитай
- `D:\Work\llm-dev-wiki\prompts\post-task-learning-review.md` — как классифицировать и роутить опыт.
- `D:\Work\llm-dev-wiki\prompts\update-user-preferences.md` — правила сохранения предпочтения.
- `D:\Work\AGENT-PREFERENCES.local.md` — текущие записи (дедуп, не плодить).

## Стоки (куда направлять)
1. **Личные предпочтения → `D:\Work\AGENT-PREFERENCES.local.md`** (основной автосток).
   Только через инструмент, никогда не дописывать файл руками в обход скана секретов:
   - Dry-run (показать предложенную запись, обязательно сначала):
     ```
     pwsh D:\Work\llm-dev-wiki\tools\update-local-preferences.ps1 -DryRun `
       -Title "<кратко>" -Scope "global|site-building|frontend|backend|design|project:<name>" `
       -Preference "<что предпочитать>" -Avoid "<что не предлагать>" `
       -Evidence "<user approval | project result | test | diff | source>" `
       -ReviewAfter "<дата или условие>" -Links "<публичные/локальные безопасные ссылки>"
     ```
   - Apply только после явного подтверждения пользователя: заменить `-DryRun` на `-Apply`.
   - Инструмент сам блокирует токены, ключи, cookies, пароли, PII — если blocked, переформулируй без приватных данных.
2. **Обезличенное переиспользуемое знание → wiki** (предлагается, подтверждается вручную):
   - Удачный приём → `D:\Work\llm-dev-wiki\patterns\<area>\<pattern-name>.md`.
   - Успех → `D:\Work\llm-dev-wiki\case-studies\successes\YYYY-MM-DD-<slug>.md`.
   - Ошибка/риск → `D:\Work\llm-dev-wiki\case-studies\failures\YYYY-MM-DD-<slug>.md` или
     `D:\Work\llm-dev-wiki\lessons-learned\YYYY-MM-DD-<topic>.md`.
   - Новый критерий ревью → файл в `D:\Work\llm-dev-wiki\checklists\`.
   - Портфолио/service-site с reusable deploy, screenshot gallery или lead-form flow → case-study + patterns, если есть тесты/deploy evidence.
   - Перед созданием артефакта проверь существующие — обновляй, а не дублируй. Используй `_template-*.md`.

## Шаги
1. **Classify significance** — был ли новый стек, риск, failure, reusable pattern, необычный trade-off или fix.
2. **Check evidence** — без команд/diff/тестов/источников/feedback не фиксировать.
3. **Route** — preference (local) и/или wiki-артефакт; для предпочтений всегда сначала `-DryRun`.
4. **Deduplicate** — найти существующие записи, обновить вместо дубля.
5. **Sanitize** — убрать секреты, PII, приватный код, customer payloads; личные референсы не уносить в GitHub-wiki.
6. **Apply** — preference только после approval (`-Apply`); wiki-артефакты после подтверждения.
7. **Quality gate вики** — если менялись файлы вики:
   ```
   pwsh D:\Work\llm-dev-wiki\tools\ci-local.ps1
   ```
   Если задача про актуальность технологий:
   ```
   pwsh D:\Work\llm-dev-wiki\tools\ci-local.ps1 -IncludeUpdateCheck
   ```

## Output schema
```
## Learning review
Decision: save local preference | propose wiki artifact | both | no artifact needed
Reason: ...
Evidence: команды/тесты/источники/user feedback

## Routing
- AGENT-PREFERENCES.local.md: <proposed entry или ->
- patterns/case-studies/lessons/checklists: <путь + краткое описание или ->

## Commands
- pwsh ...\update-local-preferences.ps1 -DryRun ...
- pwsh ...\ci-local.ps1   (если менялась вики)
```

## Передача дальше
Это финальный скилл цикла. После него — короткое резюме: что сохранено, что предложено в вики, что осталось от пользователя.
