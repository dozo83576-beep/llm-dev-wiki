from __future__ import annotations

import json
from pathlib import Path

from tools.build_embeddings import (
    build_chunks,
    corpus_hash,
    discover_files,
    write_manifest,
    write_snapshot,
)


def write_doc(path: Path, body: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(body, encoding="utf-8")


def test_discover_files_excludes_templates_and_index(tmp_path: Path) -> None:
    write_doc(tmp_path / "docs" / "INDEX.md", "# Index\n")
    write_doc(tmp_path / "docs" / "_template.md", "# Template\n")
    write_doc(tmp_path / "docs" / "guide.md", "# Guide\n")

    discovered = [path.relative_to(tmp_path).as_posix() for path in discover_files(tmp_path)]

    assert discovered == ["docs/guide.md"]


def test_build_chunks_skips_redirect_and_preserves_front_matter_metadata(tmp_path: Path) -> None:
    write_doc(
        tmp_path / "docs" / "active.md",
        """---
title: "Active Doc"
category: "testing"
updated: "2026-05-25"
status: "active"
tags: ["rag", "metadata"]
source_priority: "internal"
---

# Active Doc

Intro text.

## Usage

Use this document.
""",
    )
    write_doc(
        tmp_path / "docs" / "redirect.md",
        """---
title: "Redirect Doc"
status: "redirect"
---

# Redirect Doc

Moved to [Active Doc](active.md).
""",
    )

    chunks = build_chunks(tmp_path)

    assert {chunk.path for chunk in chunks} == {"docs/active.md"}
    assert chunks[0].title == "Active Doc"
    assert chunks[0].category == "testing"
    assert chunks[0].updated == "2026-05-25"
    assert chunks[0].source_priority == "internal"
    assert chunks[0].status == "active"
    assert chunks[0].tags == ["rag", "metadata"]


def test_build_chunks_generates_stable_chunk_ids_and_manifest_fields(tmp_path: Path) -> None:
    write_doc(
        tmp_path / "docs" / "guide.md",
        """---
title: "Guide"
category: "testing"
updated: "2026-05-25"
status: "active"
tags: ["chunking"]
source_priority: "internal"
---

# Guide

Intro.

## First Section

Body.

### Nested Section

Nested body.
""",
    )

    chunks = build_chunks(tmp_path)
    snapshot_path = tmp_path / "embeddings" / "snapshot.jsonl"
    manifest_path = tmp_path / "embeddings" / "manifest.json"
    write_snapshot(chunks, snapshot_path)
    write_manifest(chunks, "text-embedding-3-small", manifest_path, "offline-text", False)

    chunk_ids = [chunk.chunk_id for chunk in chunks]
    assert chunk_ids == [
        "docs/guide.md#__intro__",
        "docs/guide.md#first-section",
        "docs/guide.md#first-section-nested-section",
    ]
    assert corpus_hash(chunks) == corpus_hash(build_chunks(tmp_path))

    snapshot_lines = snapshot_path.read_text(encoding="utf-8").splitlines()
    assert len(snapshot_lines) == 3
    assert json.loads(snapshot_lines[0])["chunk_id"] == "docs/guide.md#__intro__"

    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    assert manifest["embedding_model"] is None
    assert manifest["chunk_count"] == 3
    assert manifest["files_indexed"] == ["docs/guide.md"]
    assert manifest["has_vectors"] is False
    assert manifest["retrieval_mode"] == "offline-text"


def test_write_manifest_preserves_generated_at_when_content_is_unchanged(tmp_path: Path) -> None:
    write_doc(
        tmp_path / "docs" / "guide.md",
        """---
title: "Guide"
status: "active"
---

# Guide

Stable content.
""",
    )
    chunks = build_chunks(tmp_path)
    manifest_path = tmp_path / "embeddings" / "manifest.json"

    write_manifest(chunks, "text-embedding-3-small", manifest_path, "offline-text", False)
    first_manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    first_manifest["generated_at"] = "2000-01-01T00:00:00Z"
    manifest_path.write_text(json.dumps(first_manifest, ensure_ascii=False), encoding="utf-8")

    write_manifest(chunks, "text-embedding-3-small", manifest_path, "offline-text", False)

    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    assert manifest["generated_at"] == "2000-01-01T00:00:00Z"
    assert manifest["corpus_hash"] == first_manifest["corpus_hash"]


def test_write_manifest_refreshes_generated_at_when_content_changes(tmp_path: Path) -> None:
    doc_path = tmp_path / "docs" / "guide.md"
    write_doc(
        doc_path,
        """---
title: "Guide"
status: "active"
---

# Guide

Original content.
""",
    )
    manifest_path = tmp_path / "embeddings" / "manifest.json"

    write_manifest(build_chunks(tmp_path), "text-embedding-3-small", manifest_path, "offline-text", False)
    first_manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    first_manifest["generated_at"] = "2000-01-01T00:00:00Z"
    manifest_path.write_text(json.dumps(first_manifest, ensure_ascii=False), encoding="utf-8")

    write_doc(
        doc_path,
        """---
title: "Guide"
status: "active"
---

# Guide

Changed content.
""",
    )
    write_manifest(build_chunks(tmp_path), "text-embedding-3-small", manifest_path, "offline-text", False)

    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    assert manifest["generated_at"] != "2000-01-01T00:00:00Z"
    assert manifest["corpus_hash"] != first_manifest["corpus_hash"]
