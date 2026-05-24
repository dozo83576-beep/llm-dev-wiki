# Security review checklist

- [ ] Проверен broken access control: чужие ID, tenant boundary, admin routes.
- [ ] Нет SQL/NoSQL injection, XSS, SSRF, CSRF на критичных путях.
- [ ] CORS разрешает только нужные origins.
- [ ] CSP совместима с frontend и снижает XSS-риск.
- [ ] Секреты не попали в Git, логи, frontend bundle, wiki.
- [ ] Rate limiting включен для auth, AI endpoints и expensive routes.
- [ ] Dependency scan не показывает критичные уязвимости.
- [ ] MCP-инструменты имеют минимальные права.
- [ ] Ошибки не раскрывают stack trace, SQL и секреты пользователю.

