# API review checklist

- [ ] API-контракт описан или выводится из typed routes/OpenAPI.
- [ ] Ошибки имеют стабильный формат.
- [ ] Пагинация, фильтры и сортировки имеют allowlist.
- [ ] Mutations идемпотентны там, где повтор запроса возможен.
- [ ] Status codes соответствуют смыслу ошибки.
- [ ] Breaking changes имеют version/deprecation plan.
- [ ] External API покрыты contract или integration tests.

