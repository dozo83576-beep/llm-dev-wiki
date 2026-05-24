# Database review checklist

- [ ] У сущностей есть понятный lifecycle.
- [ ] Foreign keys и unique constraints отражают бизнес-инварианты.
- [ ] Индексы соответствуют реальным фильтрам и сортировкам.
- [ ] Миграции проверены на staging или локальной копии.
- [ ] Для больших таблиц учтены locks и backfill.
- [ ] Soft delete и audit log применены только там, где нужны.
- [ ] Backup и restore-процедура определены.
- [ ] Multi-tenancy изоляция проверена тестами.

