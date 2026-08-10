---
name: site-architecture
description: Архитектурная фаза только внутри полного маршрута D:\Work или при явном вызове этой фазы; не активируется на обычные backend/API задачи.
---

# Site architecture

Входы: `_discovery.md`, `_competitive-analysis.md`, `_stack.md`, contract v2 и фактическое состояние проекта.

Нативно спроектируй компоненты, границы доверия, данные, интеграции и эксплуатационные риски. Загружай из вики только релевантные patterns и case studies.

Локальные инварианты:

- выбери один primary playbook и явно отдели supporting guides;
- обозначь server/client границы, authz, владение данными и миграции;
- для AI/RAG, realtime и marketplace используй соответствующий playbook и его специальные gates;
- не помещай секреты или реальные ПДн в диаграммы и примеры.

Артефакт `_architecture.md` содержит решения, отклонённые варианты, интерфейсы, риски и проверяемые acceptance gates. Обнови status только после проверки артефакта.
