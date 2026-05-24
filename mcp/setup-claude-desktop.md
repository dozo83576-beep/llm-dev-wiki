# Claude Desktop MCP setup

Для Claude Desktop подключай только нужные MCP-серверы:

- filesystem с ограничением на директорию проекта;
- GitHub с минимальными scopes;
- browser/playwright для локальной проверки;
- docs/search server для документации;
- database server в read-only режиме.

Production write-доступ не включать как настройку по умолчанию.

