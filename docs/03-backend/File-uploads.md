---
title: "File uploads"
category: "backend"
updated: "2026-05-24"
status: "active"
tags: ["uploads", "storage"]
source_priority: "internal"
---

# File uploads

File upload — security boundary. Любой файл считается недоверенным.

## Production-паттерны

- Direct-to-storage upload через signed URL для крупных файлов.
- Server-side validation: размер, MIME, расширение, ownership, quota.
- Virus scan для пользовательских файлов в рискованных доменах.
- Public/private buckets разделены.

## Частые ошибки

- Доверие client MIME.
- Публичный доступ к приватным файлам.
- Отсутствие лимитов размера и количества.

## Проверка

- Negative tests: чужой файл, слишком большой файл, неверный тип.
- E2E: upload, preview/download, delete.

## Когда использовать

Используй upload flow для avatars, documents, imports, media, attachments и user-generated content.

## Когда не использовать

Не принимай файл через backend memory buffer, если ожидаются крупные файлы или высокая конкуренция. Direct-to-storage безопаснее и масштабируемее.

## Edge cases

- Resumable uploads (tus / multi-part) для крупных файлов и нестабильной сети.
- EXIF / metadata strip перед публикацией изображений (могут содержать геоданные).
- Path traversal в имени файла: всегда генерировать собственный storage path.
- Race на overwrite: оптимистический lock по version или генерация уникального ключа.
- Image resize / transcoding — отдельный async job, не в request handler.

## Security risks

SSRF при download from URL без allowlist, XSS через SVG со script тегом, malware download через `Content-Disposition: inline`, утечка чужих файлов через предсказуемые ID/ключи.

## Источники

См. security guidance выбранного storage provider (S3 / R2 / GCS) и [Secrets](../05-auth-security/Secrets.md).

