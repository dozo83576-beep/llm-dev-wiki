---
title: "Библиотека промптов Claude Code (конспект официальной библиотеки)"
category: "prompt"
updated: "2026-07-07"
reviewed: "2026-07-07"
status: "active"
tags: ["prompting", "claude-code", "library", "workflow", "agents"]
source_priority: "official-docs"
---

# Библиотека промптов Claude Code

Конспект официальной библиотеки промптов Claude Code: 52 промпта по фазам SDLC + 6 паттернов сильного промпта + петля закрепления «промпт → skill → CLAUDE.md».

- Источник: <https://code.claude.com/docs/ru/prompt-library> (EN: `/en/prompt-library`). Проверено: 2026-07-07.
- Тексты промптов — дословные EN-шаблоны для копирования (так они и опубликованы; работают в любом языке сессии). Пояснения — собственный сжатый конспект.
- `{слоты}` заполняются под задачу; рядом даны примерные значения с официальной страницы.

## Назначение

Готовые формулировки задач для агентных сессий (Claude Code, Codex и др.): от исследования кодовой базы до реализации, тестов, ревью, релиза и эксплуатации. Это отправные точки, а не скрипты: под каждым — паттерн, по которому пишется свой промпт.

## Когда использовать

- Начало незнакомой задачи: не знаешь, с чего начать — бери промпт нужной фазы.
- Формулировка подзадач субагентам и постановка задач в пайплайне.
- Обучение заказчика/команды работе с агентом.

## Когда не использовать

- Сборка сайтов в D:\Work идёт через обязательный пайплайн `build-modern-site` (17 фаз) — эти промпты дополняют фазовые скиллы, но не заменяют их.
- Не превращать непроверенный промпт в skill: сначала приём должен доказать пользу (см. «Петля закрепления»).

## Пять промптов для старта

| № | Промпт | Раздел |
|---|--------|--------|
| 1 | Обзор кодовой базы | Исследование → Подключение |
| 2 | Найти, где что-то происходит | Исследование → Понимание |
| 3 | Найти и исправить падающий тест | Эксплуатация → Отладка |
| 4 | Написать тесты, запустить, исправить | Разработка → Тестирование |
| 5 | Ревью незакоммиченных изменений | Разработка → Проверка |

---

## Фаза 1. Исследование (Discover)

### Подключение (Onboard)

**Ориентация в новом репозитории** ⭐ старт №1

```text
give me an overview of this codebase: architecture, key directories, and how the pieces connect
```

Суть: описывай, что хочешь узнать, а не какие файлы читать — агент сам исследует проект. Закрепить: `/init` → CLAUDE.md, чтобы контекст был в каждой сессии.

### Понимание (Understand)

**Объяснить незнакомый код**

```text
explain what {path} does and how data flows through it. write it up as {format}
```

Слоты: `{path}=src/scheduler/queue.ts`, `{format}=an HTML page with a diagram, then open it in my browser`. Суть: назови файл и формат ответа (диаграмма, список, HTML). Закрепить: output style под предпочитаемый формат.

**Найти, где что-то происходит** ⭐ старт №2

```text
where do we {behavior}?
```

Слот: `{behavior}=validate uploaded file types`. Суть: поиск по поведению, а не по имени файла — работает, даже когда не знаешь названий.

**Проверить, что сломается перед удалением**

```text
what would break if I deleted {target}?
```

Слот: `{target}=the retryWithBackoff helper`. Суть: список вызывающих и downstream-эффектов показывает, однострочная это чистка или координируемое изменение.

**Проследить эволюцию кода**

```text
look through the commit history of {path} and summarize how it evolved and why
```

Слот: `{path}=internal/auth/session.go`. Суть: когда вопрос «почему», а не «что» — агент читает log/blame и объясняет решения за текущей реализацией.

**Оценить объём изменения до старта**

```text
which files would I need to touch to {change}?
```

Слот: `{change}=add a dark mode toggle to settings`. Суть: список файлов показывает, один это компонент или сквозное изменение — оценка до попадания в роадмап.

**Продуктовый вопрос к кодовой базе**

```text
I am a {role}. walk me through what happens when a user {action}, from the UI down to the result
```

Слоты: `{role}=PM`, `{action}=clicks Export to PDF`. Суть: назови роль — ответ будет на нужном уровне; агент объясняет продукт из исходников.

## Фаза 2. Дизайн (Design)

### Планирование (Plan)

**План многофайлового изменения без правок**

```text
plan how to refactor the {target} to {goal}. list the files you would change, but don't edit anything yet
```

Слоты: `{target}=payment module`, `{goal}=support multiple currencies`. Суть: «don't edit yet» отделяет исследование от изменений. Закрепить: plan mode (Shift+Tab) как дефолт для крупных задач.

**Спека через интервью**

```text
I want to build {feature}. interview me about implementation, UX, edge cases, and tradeoffs until we have covered everything, then write the spec to SPEC.md
```

Слот: `{feature}=per-workspace rate limits`. Суть: агент задаёт структурированные вопросы до полноты требований, затем пишет спеку в файл. Закрепить: свои вопросы интервью → skill `/spec`.

**Встреча → тикеты** (требует: трекер через MCP/коннектор)

```text
read {input} and write up the action items, then create a {tracker} ticket for each with acceptance criteria
```

Слоты: `{input}=@meeting-notes.md`, `{tracker}=Linear`. Суть: action items из неструктурированного текста сразу в трекер — ревьюишь тикеты, а не транскрипт. Закрепить: skill `/tickets`.

**Карта edge cases до разработки**

```text
list the error states, empty states, and edge cases for {feature} that the design needs to cover
```

Слот: `{feature}=the file upload flow`. Суть: спрашивай, чего не хватает, а не что есть — агент перечисляет то, что happy-path-дизайн пропускает.

### Прототипирование (Prototype)

**Макет → кликабельный прототип** (вставь/перетащи картинку макета)

```text
here is a mockup. build a working prototype I can click through, matching the layout and states shown
```

Суть: кликабельный прототип отвечает на вопросы, на которые статичный макет не может; инженерам отдаётся код, а не документ с описанием взаимодействий.

**Реализация со скриншота с самопроверкой** (вставь картинку дизайна; требует: браузер/превью)

```text
implement this design, then take a screenshot of the result, compare it to the original, and fix any differences
```

Суть: встроенная петля проверки — агент рендерит, сравнивает с оригиналом и итерирует сам. Закрепить: `/goal` до совпадения скриншотов.

## Фаза 3. Разработка (Build)

### Реализация (Implement)

**Следовать существующему паттерну**

```text
look at how {example} is implemented to understand the pattern, then build {new} the same way
```

Слоты: `{example}=the GitHub webhook handler`, `{new}=a Stripe webhook handler`. Суть: без референса агент пишет «общие best practices», с референсом — соблюдает соглашения твоей кодовой базы. Закрепить: паттерн → CLAUDE.md.

**Документация для недокументированного кода**

```text
find {scope} without {format} comments and add them, matching the style already used in the file
```

Слоты: `{scope}=the public functions in src/auth/`, `{format}=JSDoc`. Суть: назови область и формат — новые комментарии будут в стиле файла.

**Небольшая чётко определённая фича**

```text
add a {endpoint} endpoint that returns {payload}
```

Слоты: `{endpoint}=/health`, `{payload}=the app version and uptime`. Суть: задай входы и выходы, а не способ реализации — агент найдёт, где живёт похожий код.

**Внутренний инструмент с нуля**

```text
create a {tool} using HTML, CSS, and vanilla JavaScript, then open it in my browser
```

Слот: `{tool}=drag-and-drop Kanban board with three columns`. Суть: без проекта, фреймворка и сборки — опиши инструмент и попроси открыть в браузере.

**Issue от начала до конца** (требует: gh CLI)

```text
read issue #{issue}, implement the fix, and run the tests
```

Слот: `{issue}=312`. Суть: давай номер, а не пересказ — агент читает полный тикет и проверяет изменение перед отчётом.

**Найти и обновить текст по всей базе**

```text
find every place we say "{copy}" or a close variant, show me each one in context, then update them all to "{new}". leave tests and the changelog alone
```

Слоты: `{copy}=Sign up free`, `{new}=Start free trial`. Суть: «и близкие варианты» ловит то, что буквальный поиск пропустит; исключения названы явно.

**Черновик по прошлым примерам**

```text
read the {examples} in {folder} to learn the structure and voice, then draft a new one for {topic}
```

Слоты: `{examples}=privacy impact assessments`, `{folder}=legal/pia/`, `{topic}=the new analytics integration`. Суть: папка готовых работ вместо описания стиля — черновик читается как твой. Закрепить: «голос» → skill.

### Тестирование (Test)

**Написать тесты, запустить, исправить** ⭐ старт №4

```text
write tests for {path}, run them, and fix any failures
```

Слот: `{path}=app/parsers/feed.py`. Суть: «написать + запустить + исправить» в одном задании — агент итерирует без остановок за инструкциями. Закрепить: `/init`, чтобы агент выучил команду тестов.

**Реализация от тестов (TDD)**

```text
write tests for {feature} first, then implement it until they pass
```

Слот: `{feature}=the password reset flow`. Суть: тесты определяют, когда работа завершена; агент итерирует реализацию до зелёного.

**Закрыть пробелы из coverage-отчёта**

```text
read {report} and add tests for the lowest-covered files until each is above {target}%
```

Слоты: `{report}=coverage/coverage-summary.json`, `{target}=80`. Суть: отчёт вместо догадок — тесты пишутся туда, где они нужнее всего. Закрепить: `/goal` до целевого покрытия.

### Рефакторинг (Refactor)

**Миграция паттерна по всей базе**

```text
migrate everything from {from} to {to}: identify every place that needs to change, then make the changes
```

Слоты: `{from}=the old logging API`, `{to}=the structured logger`. Суть: «сначала перечисли все места» — список call sites в ответе позволяет проверить, что ничего не пропущено.

**Портирование на другой язык**

```text
port {source} to {target}, keeping the same {keep}
```

Слоты: `{source}=this Python module`, `{target}=Rust`, `{keep}=public API and test behavior`. Суть: скажи, что сохранить, а не только целевой язык — это контракт для проверки порта.

**Оптимизация под измеримую цель**

```text
optimize {target} to bring {metric} from {current} down to under {goal}
```

Слоты: `{target}=the search query`, `{metric}=p95 latency`, `{current}=2s`, `{goal}=500ms`. Суть: метрика и порог = однозначное определение «готово». Закрепить: `/goal` до достижения числа.

**Точный визуальный баг**

```text
the {element} extends {amount} beyond the {container} on {viewport}. fix it.
```

Слоты: `{element}=login button`, `{amount}=20px`, `{container}=card border`, `{viewport}=mobile`. Суть: точная обратная связь (элемент, размер, viewport) даёт точный фикс. Закрепить: превью-инструмент для самопроверки скриншотом.

### Проверка (Review)

**Ревью незакоммиченных изменений** ⭐ старт №5

```text
review my uncommitted changes and flag anything that looks risky before I commit
```

Суть: проблемы ловятся, пока дёшевы; агент читает изменённые файлы целиком, а не только строки диффа. Закрепить: `/code-review`.

**Ревью pull request** (требует: gh CLI)

```text
review PR #{pr} and summarize what changed, then list any concerns
```

Слот: `{pr}=247`. Суть: ревью со всей кодовой базой в контексте, а не только диффом — видит то, что diff-only ревью пропустит.

**Ревью инфраструктурных изменений** (вставь вывод плана)

```text
here is my Terraform plan output. what is this going to do, and is anything here going to cause problems?
```

Суть: плотный plan-вывод превращается в человеческое резюме «что реально изменится» до apply.

**Security-ревью субагентом**

```text
use a subagent to review {path} for security issues and report what it finds
```

Слот: `{path}=src/api/`. Суть: субагент делает длинный аудит в своём контексте и возвращает сводку — основная сессия не засоряется. Закрепить: выделенный security-review субагент для команды.

**Проверка контента до формального ревью**

```text
review {file} for {concerns} and list anything I should fix before it goes to {reviewer}
```

Слоты: `{file}=launch-post.md`, `{concerns}=unsupported claims, missing attributions, and brand-guideline issues`, `{reviewer}=legal`. Суть: назови конкретные риски — ревью будет сфокусированным; человеку уходит чистый черновик. Закрепить: чеклист ревью → skill.

### Управление агентом (Steer)

**Скорректировать неверный подход**

```text
that is not right: {feedback}. try a different approach
```

Слот: `{feedback}=the function signature needs to stay backward-compatible`. Суть: назови пропущенное ограничение, а не просто «неправильно» — иначе агент снова гадает. Закрепить: Esc×2 → rewind для чистого ретрая.

**Сузить область изменения**

```text
that is too much. keep only the changes to {scope} and undo your other edits
```

Слот: `{scope}=the validation logic in src/forms/`. Суть: когда направление верное, но задело лишнее — граница словами, без полного отката.

**Исправление → правило**

```text
you keep {mistake}. add a rule to CLAUDE.md so this stops happening
```

Слот: `{mistake}=using default exports when this project uses named exports`. Суть: исправление в чате не переживает сессию; правило в CLAUDE.md читается на старте каждой. Закрепить: `/memory` — проверить, что записано.

## Фаза 4. Выпуск (Ship)

### Git

**Разрешить merge-конфликты**

```text
resolve the merge conflicts in this branch and explain what you kept from each side
```

Суть: говори, какое состояние нужно, а не какие маркеры оставить; объяснение делает merge проверяемым.

**Коммит со сгенерированным сообщением**

```text
commit these changes with a message that summarizes what I did
```

Суть: сообщение выводится из диффа и соответствует стилю коммитов репозитория.

**PR из тикета** (требует: трекер через MCP/коннектор)

```text
find the {tracker} ticket about {topic} and open a PR that implements it
```

Слоты: `{tracker}=Linear`, `{topic}=the login timeout`. Суть: один промпт читает спеку, делает изменение и открывает PR — без переключений трекер/редактор/GitHub.

### Релиз (Release)

**Release notes из истории git**

```text
compare {from} to {to} and draft release notes grouped by feature, fix, and breaking change
```

Слоты: `{from}=v2.3.0`, `{to}=v2.4.0`. Суть: две контрольные точки + желаемая структура — агент читает лог между ними. Закрепить: skill `/changelog`.

**CI-workflow**

```text
write a GitHub Actions workflow that {steps} on every push to {branch}
```

Слоты: `{steps}=runs the tests and deploys to staging`, `{branch}=main`. Суть: опиши «когда» и «что» — YAML генерируется под команды сборки/тестов проекта.

## Фаза 5. Эксплуатация (Operate)

### Отладка (Debug)

**Найти и исправить падающий тест** ⭐ старт №3

```text
the {test} test is failing, find out why and fix it
```

Слот: `{test}=UserAuth`. Суть: опиши симптом — не нужно знать, какой файл сломан; агент запускает тест, трассирует и чинит.

**Расследовать ошибку у пользователей**

```text
users are seeing {symptom} on {where}. investigate and tell me what is going on
```

Слоты: `{symptom}=500 errors`, `{where}=/api/settings`. Суть: симптом + место; стектрейсы и логи вставляй прямо в промпт. Закрепить: deeplink с этим промптом в runbook.

**Ошибка сборки — чинить корень** (вставь вывод ошибки)

```text
here is a build error. fix the root cause and verify the build succeeds
```

Суть: «root cause + verify» блокирует поверхностные патчи, глушащие ошибку без починки.

### Инцидент (Incident)

**Инцидент в production**

```text
{symptom}. check the logs, recent deploys, and config changes, then tell me the most likely cause
```

Слот: `{symptom}=the checkout endpoint started returning 500s an hour ago`. Суть: перечисли источники улик для корреляции, а не шаги — логи + git-история + конфиг сужают причину. Закрепить: Sentry/лог-стор через MCP.

**Диагноз по скриншоту консоли** (вставь скриншот)

```text
here is a screenshot of {console}. walk me through why {resource} is failing and give me the exact commands to fix it
```

Слоты: `{console}=the GCP Kubernetes dashboard`, `{resource}=this pod`. Суть: консоль показывает проблему, но не команды; агент переводит дашборд в kubectl/gcloud/aws.

**Логи простым языком** (требует: БД/лог-стор через MCP)

```text
show me all {events} for {scope} over {timeframe}. write the query, run it, and tell me what stands out
```

Слоты: `{events}=failed logins`, `{scope}=the auth service`, `{timeframe}=the past 24 hours`. Суть: вопрос вместо SQL; агент показывает и запрос, и результат — можно проверить, что выполнилось.

### Данные (Data)

**Анализ файла данных** (перетащи файл / @-упоминание)

```text
read {file}, summarize the key patterns, and write the results to {output}
```

Слоты: `{file}=@reports/q1-signups.csv`, `{output}=an HTML page with charts, then open it in my browser`. Суть: разовый вопрос не требует разового скрипта. Закрепить: источник данных через MCP вместо экспорта.

**Вариации из данных о производительности** (перетащи файл)

```text
read {file}, find the underperforming {items}, and generate {n} new variations that stay under {limit} characters
```

Слоты: `{file}=@ads-performance.csv`, `{items}=headlines`, `{n}=20`, `{limit}=90`. Суть: ограничение задаётся в начале — генерация не выходит за лимит.

### Автоматизация (Automate)

**Повторяющаяся задача → skill**

```text
create a /{name} skill for this project that {steps}
```

Слоты: `{name}=ship`, `{steps}=runs the linter and tests, then drafts a commit message`. Суть: назови шаги один раз — дальше команда `/name` для всей команды.

**Hook для повторяющегося поведения**

```text
write a hook that {action} after every {event}
```

Слоты: `{action}=runs prettier`, `{event}=edit to a .ts or .tsx file`. Суть: hook делает поведение автоматическим — не нужно помнить и просить.

**Подключить инструмент через MCP**

```text
set up the {server} MCP server so you can read my {data} directly
```

Слоты: `{server}=Sentry`, `{data}=error reports`. Суть: подключи источник один раз вместо вставки данных в каждую сессию.

**Зафиксировать выученное за сессию**

```text
summarize what we did this session and suggest what to add to CLAUDE.md
```

Суть: спроси до того, как забыл, — агент знает, в чём ему пришлось разбираться, и предлагает записи, чтобы следующая сессия начиналась с этого контекста.

---

## Шесть паттернов сильного промпта

1. **Результат, а не шаги.** Скажи, что нужно, — агент сам найдёт файлы:
   `add rate limiting to the public API and make sure existing tests still pass`
2. **Встроенная петля самопроверки.** Проси «сделай + запусти + сравни/проверь» в одном задании — агент итерирует, а не останавливается после первой попытки:
   `write the migration, run it against the dev database, and confirm the schema matches`
3. **Опора на референс.** Назови существующий файл/тест/паттерн — новый код будет согласован с базой:
   `add a settings page that follows the same layout as the profile page`
4. **Измеримая цель.** Метрика + порог = однозначный критерий готовности:
   `get the bundle size under 200KB and show me what you removed`
5. **Артефакт вместо пересказа.** Ошибки, логи, скриншоты, план — прямо в промпт или через `@файл`:
   `why is the build failing? @build.log`
6. **Заданный формат ответа.** Формат, длина, аудитория — под то, как ответ будет использован:
   `explain how the payment retry logic works as an HTML page with a diagram, then open it in my browser`

## Петля закрепления (промпт → skill → правила)

Официальная рекомендация: промпт — отправная точка; когда он **доказал** пользу — сделать повторяемым.

Привязка к системе D:\Work:

1. **Промпт сработал ≥2 раз** → skill в каноне `agent-skills/` (см. [skill-system](../docs/00-start-here/skill-system.md)), затем `pwsh agent-skills/sync-skills.ps1`. Кандидаты со страницы: `/spec` (спека-интервью), `/tickets` (встреча→тикеты), `/changelog` (release notes).
2. **Выучено соглашение** (стиль, запрет, конвенция) → правило в `AGENTS.md` / project-`CLAUDE.md`; личные предпочтения — через `capture-learnings` в `AGENT-PREFERENCES.local.md`.
3. **Повторяемое поведение** (формат, prettier, проверка) → hook.
4. **Регулярно нужный источник данных** → MCP-сервер вместо вставки данных в каждую сессию.
5. **Крупное/рискованное изменение** → plan mode (список файлов до правок).
6. **Итерация до измеримой цели** → `/goal` (покрытие, latency, совпадение скриншотов).

## Частые ошибки

- Копировать промпт как скрипт, не заполнив слоты и не адаптировав под проект.
- Диктовать агенту шаги вместо результата — теряется его способность найти лучший путь.
- Промпт без петли проверки: агент останавливается после первой попытки вместо итераций.
- Плодить скиллы из непроверенных промптов — сначала польза, потом автоматизация.
- Использовать эти промпты вместо обязательных фаз пайплайна `build-modern-site` при сборке сайтов.
- Исправлять агента в чате и не фиксировать правило — та же ошибка повторится в следующей сессии.

## Связанные материалы вики

Детализированные внутренние промпты под те же задачи: [code-review](code-review.md), [security-review](security-review.md), [debug-issue](debug-issue.md), [write-tests](write-tests.md), [refactor](refactor.md), [implementation-plan](implementation-plan.md), [discovery-interview](discovery-interview.md), [deploy](deploy.md), [post-task-learning-review](post-task-learning-review.md).

## Источники

- [Prompt library — code.claude.com](https://code.claude.com/docs/ru/prompt-library) — первоисточник, проверено 2026-07-07.
- [Common workflows](https://code.claude.com/docs/ru/common-workflows), [Best practices](https://code.claude.com/docs/ru/best-practices) — origin большинства промптов.
- [How Anthropic teams use Claude Code](https://claude.com/blog/how-anthropic-teams-use-claude-code) + deep-dives: [legal](https://claude.com/blog/how-anthropic-uses-claude-legal), [cybersecurity](https://claude.com/blog/how-anthropic-uses-claude-cybersecurity).
- [Scaling agentic coding across your organization (PDF)](https://resources.anthropic.com/hubfs/Scaling%20agentic%20coding%20across%20your%20organization.pdf).
- Курс: [Claude Code in Action — Anthropic Academy](https://anthropic.skilljar.com/claude-code-in-action).
