# Prompt: backend audit

Проведи backend audit.

Проверь:

- API contract и error contract;
- validation на границе;
- authorization и object-level permissions;
- transaction boundaries;
- logging без секретов;
- background jobs, retries, idempotency;
- webhooks signature и replay protection;
- rate limits;
- integration tests.

Формат ответа: findings по severity, затем fix plan и regression tests.

