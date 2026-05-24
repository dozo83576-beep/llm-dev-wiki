# Prompt: MCP security review

Проведи MCP security review.

Проверь:

- список MCP-серверов;
- права каждого инструмента;
- read/write/destructive boundaries;
- доступ к secrets, filesystem, production DB, deploy, DNS, billing;
- prompt injection через tool outputs;
- audit logs;
- confirmation gates;
- rollback для ошибочных действий агента.

Выдай разрешенный набор прав и запреты.

