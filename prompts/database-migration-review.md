# Prompt: database migration review

Проведи review миграции БД.

Проверь:

- backward compatibility;
- locks и impact на большие таблицы;
- expand-and-contract plan;
- backfill strategy;
- constraints и indexes;
- rollback path;
- data loss risk;
- staging verification;
- application compatibility до и после deploy.

Если миграция рискованная, предложи безопасную последовательность из нескольких deploy.

