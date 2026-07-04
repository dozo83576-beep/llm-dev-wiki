---
title: "Lesson: pytest импортирует script-style инструменты как пакет — нужен conftest с sys.path"
category: "lesson"
updated: "2026-07-05"
status: "active"
tags: ["pytest", "python", "tooling", "imports", "ci", "wiki"]
source_priority: "internal"
date: "2026-07-05"
project_type: "other"
---

# Lesson: pytest импортирует script-style инструменты как пакет — нужен conftest с sys.path

## TL;DR

Скрипт из `tools/`, который импортирует соседний модуль напрямую (`from retrieval_lib import …`),
работает при запуске `python tools/script.py`, но падает с `ModuleNotFoundError`, когда pytest
импортирует его как `tools.script`. Каталог со script-style модулями нужно добавить в `sys.path`
через `tests/conftest.py`.

## Контекст

`tools/run_offline_retrieval_evals.py` разделяет BM25-ядро с `tools/ask_wiki.py` через общий модуль
`tools/retrieval_lib.py` и импортирует его по-скриптовому: `from retrieval_lib import …`. Тест
`tests/tools/test_run_offline_retrieval_evals.py` делает `from tools.run_offline_retrieval_evals
import …`.

## Что произошло

`python -m pytest tests/tools` падал на этапе collection: `ModuleNotFoundError: No module named
'retrieval_lib'` — 1 error, 56 тестов не запускались целиком (`Interrupted: 1 error during
collection`). Баг был латентным: тест добавлен в незапушенном коммите и локально до этого ревью
полный прогон не выполнялся.

## Корень

При запуске скрипта напрямую Python кладёт каталог скрипта (`tools/`) в `sys.path` — соседний
импорт работает. При импорте через pytest модуль грузится как `tools.run_offline_retrieval_evals`
(cwd в `sys.path` от `python -m`), а сам `tools/` в `sys.path` не попадает — соседний `retrieval_lib`
не находится. Два способа запуска = два разных контекста импорта.

## Новое правило

Когда тесты импортируют модули из каталога script-style инструментов (без `__init__.py`, с прямыми
импортами соседей) → добавь `tests/conftest.py` с
`sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))`. И прогоняй полный
`python -m pytest` локально до push — collection-ошибки не видны при запуске отдельных файлов.

## Применимость

Репозитории, где `tools/`/`scripts/` — не пакет, а набор исполняемых скриптов с общими модулями.
Не нужно, если инструменты оформлены как устанавливаемый пакет с абсолютными импортами.

## Обновлённые документы

- tests/conftest.py — bootstrap `sys.path` для `tools/` (коммит `fce3ff7`).

## Ссылки

- Связанные [lessons-learned](../lessons-learned) — `2026-07-05-generated-file-timezone-date.md` (второй фикс того же CI-прогона).
