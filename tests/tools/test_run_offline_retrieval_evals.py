from __future__ import annotations

from pathlib import Path

from tools.run_offline_retrieval_evals import (
    Chunk,
    build_index,
    expand_query_tokens,
    find_best_expected_rank,
    load_synonyms,
    render_report,
    score_query,
)


def test_load_synonyms_ignores_front_matter_and_normalizes_values(tmp_path: Path) -> None:
    synonyms_path = tmp_path / "retrieval-synonyms.yaml"
    synonyms_path.write_text(
        """---
title: "Retrieval synonyms"
---
synonyms:
  Версионировать:
    - Versioning
    - versions
  мокать: "Mock Service Worker"
""",
        encoding="utf-8",
    )

    synonyms = load_synonyms(synonyms_path)

    assert synonyms["версионировать"] == ["versioning", "versions"]
    assert synonyms["мокать"] == ["mock", "service", "worker"]


def test_load_synonyms_returns_empty_dict_for_invalid_synonyms_section(tmp_path: Path) -> None:
    synonyms_path = tmp_path / "retrieval-synonyms.yaml"
    synonyms_path.write_text("synonyms:\n  - not\n  - a\n  - mapping\n", encoding="utf-8")

    assert load_synonyms(synonyms_path) == {}


def test_expand_query_tokens_preserves_original_tokens_and_appends_expansions() -> None:
    tokens = ["мокать", "api"]
    synonyms = {"мокать": ["mock", "sandbox"]}

    assert expand_query_tokens(tokens, synonyms) == ["мокать", "api", "mock", "sandbox"]


def test_find_best_expected_rank_returns_lowest_rank_or_none() -> None:
    ranked = [
        ("docs/a.md", 10.0),
        ("docs/b.md", 9.0),
        ("docs/c.md", 8.0),
    ]

    assert find_best_expected_rank(ranked, ["docs/c.md", "docs/b.md"]) == 2
    assert find_best_expected_rank(ranked, ["docs/missing.md"]) is None


def test_score_query_uses_metadata_to_rank_relevant_chunk_above_body_only_match() -> None:
    chunks = [
        Chunk(
            path="docs/13-playbooks/marketplace.md",
            chunk_id="docs/13-playbooks/marketplace.md#__intro__",
            title="Playbook: Marketplace",
            category="playbooks",
            tags=("marketplace", "payments"),
            section_path=("Стек по умолчанию",),
            text="Площадка с продавцами, покупателями, payouts и dispute-flow.",
        ),
        Chunk(
            path="docs/noise.md",
            chunk_id="docs/noise.md#__intro__",
            title="General commerce notes",
            category="notes",
            tags=("commerce",),
            section_path=("Notes",),
            text="marketplace marketplace marketplace общие заметки без playbook metadata.",
        ),
    ]
    docs, doc_freq, avg_len = build_index(chunks)

    ranked = score_query(
        "какой marketplace playbook для продавцов",
        chunks,
        docs,
        doc_freq,
        avg_len,
        synonyms={},
    )

    assert ranked[0][0] == "docs/13-playbooks/marketplace.md"


def test_render_report_includes_weak_rank_summary_and_best_expected_rank() -> None:
    report = render_report(
        rows=[
            {
                "id": "q-example",
                "passed": True,
                "weak": True,
                "best_expected_rank": 4,
                "expected_paths": ["docs/example.md"],
                "top_results": [("docs/example.md", 1.25)],
            }
        ],
        top_k=5,
        min_precision=0.6,
        precision=1.0,
        warn_rank=3,
        weak_count=1,
    )

    assert "- Weak rank warnings: 1" in report
    assert "| ID | Pass | Weak | Best expected rank | Expected | Top results |" in report
    assert "| q-example | yes | yes | 4 | docs/example.md | docs/example.md (1.250) |" in report
