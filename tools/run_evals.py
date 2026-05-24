"""
Retrieval evaluation against golden Q&A.

Reads:
- embeddings/snapshot.jsonl (chunk records, possibly with vectors)
- docs/14-llm-indexing/golden-qa.yaml (questions + expected_paths)

Embeds each question via OpenAI text-embedding-3-small, computes cosine similarity
against snapshot chunks, and reports precision@K / recall@K based on whether any
expected_path appears in top-K results.

Fails (exit 1) if:
  - precision@5 < --min-precision (default 0.6), or
  - any expected_path is missing from top-10 for its question (configurable).

Usage:
    OPENAI_API_KEY=sk-... python tools/run_evals.py
    python tools/run_evals.py --min-precision 0.7 --top-k 5
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Iterable

try:
    import yaml  # pyyaml
    import numpy as np
except ImportError as e:
    print(f"Missing dependency: {e} (pip install -r tools/requirements.txt)", file=sys.stderr)
    sys.exit(2)

EMBED_MODEL_DEFAULT = "text-embedding-3-small"


def load_snapshot(path: Path) -> list[dict]:
    chunks: list[dict] = []
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            chunks.append(json.loads(line))
    return chunks


def load_questions(path: Path) -> list[dict]:
    raw = path.read_text(encoding="utf-8")
    # Skip wiki front matter if present
    if raw.startswith("---"):
        parts = raw.split("---", 2)
        if len(parts) >= 3:
            raw = parts[2]
    data = yaml.safe_load(raw) or {}
    return data.get("questions") or []


def cosine_matrix(query_vec: np.ndarray, matrix: np.ndarray) -> np.ndarray:
    q = query_vec / (np.linalg.norm(query_vec) + 1e-12)
    n = matrix / (np.linalg.norm(matrix, axis=1, keepdims=True) + 1e-12)
    return n @ q


def embed_questions(questions: list[str], model: str) -> np.ndarray:
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        print("OPENAI_API_KEY not set — cannot run retrieval evals.", file=sys.stderr)
        sys.exit(3)
    try:
        from openai import OpenAI
    except ImportError:
        print("Missing dependency: openai (pip install -r tools/requirements.txt)", file=sys.stderr)
        sys.exit(2)
    client = OpenAI(api_key=api_key)
    resp = client.embeddings.create(model=model, input=questions)
    return np.array([item.embedding for item in resp.data], dtype=np.float32)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Run retrieval evals on golden Q&A.")
    parser.add_argument("--root", default=".")
    parser.add_argument("--snapshot", default="embeddings/snapshot.jsonl")
    parser.add_argument("--golden", default="docs/14-llm-indexing/golden-qa.yaml")
    parser.add_argument("--model", default=EMBED_MODEL_DEFAULT)
    parser.add_argument("--top-k", type=int, default=5)
    parser.add_argument("--top-k-strict", type=int, default=10, help="If any expected path is missing from top-K-strict, fail.")
    parser.add_argument("--min-precision", type=float, default=0.6)
    parser.add_argument("--report", default="evals-report.md")
    args = parser.parse_args(argv)

    root = Path(args.root).resolve()
    snapshot_path = root / args.snapshot
    golden_path = root / args.golden
    report_path = root / args.report

    if not snapshot_path.exists():
        print(f"snapshot not found: {snapshot_path}", file=sys.stderr)
        return 2
    if not golden_path.exists():
        print(f"golden Q&A not found: {golden_path}", file=sys.stderr)
        return 2

    chunks = load_snapshot(snapshot_path)
    if not chunks:
        print("snapshot is empty", file=sys.stderr)
        return 2
    if not chunks[0].get("embedding"):
        print("snapshot has no vectors — re-run build_embeddings.py with OPENAI_API_KEY set.", file=sys.stderr)
        return 2

    matrix = np.array([c["embedding"] for c in chunks], dtype=np.float32)
    paths = [c["path"] for c in chunks]

    questions = load_questions(golden_path)
    if not questions:
        print("no questions in golden set", file=sys.stderr)
        return 2

    qtexts = [q["question"] for q in questions]
    qvecs = embed_questions(qtexts, args.model)

    lines: list[str] = []
    hits_at_k = 0
    strict_failures: list[tuple[str, list[str]]] = []
    per_question_recall: list[float] = []

    for q, qvec in zip(questions, qvecs):
        sims = cosine_matrix(qvec, matrix)
        top_idx = np.argsort(-sims)[: args.top_k_strict]
        top_paths_strict = [paths[i] for i in top_idx]
        top_paths_k = top_paths_strict[: args.top_k]
        expected = set(q.get("expected_paths") or [])
        hit_k = bool(expected & set(top_paths_k))
        if hit_k:
            hits_at_k += 1
        missing_strict = [p for p in expected if p not in top_paths_strict]
        if missing_strict:
            strict_failures.append((q["id"], missing_strict))
        recall = (len(expected & set(top_paths_k)) / len(expected)) if expected else 0.0
        per_question_recall.append(recall)

        lines.append(f"### {q['id']}")
        lines.append("")
        lines.append(f"- Question: {q['question']}")
        lines.append(f"- Expected: {sorted(expected)}")
        lines.append(f"- Top-{args.top_k}: {top_paths_k}")
        lines.append(f"- Hit@{args.top_k}: {'✅' if hit_k else '❌'}; recall@{args.top_k}={recall:.2f}")
        if missing_strict:
            lines.append(f"- Missing in top-{args.top_k_strict}: {missing_strict}")
        lines.append("")

    precision_at_k = hits_at_k / len(questions)
    mean_recall = sum(per_question_recall) / len(per_question_recall)

    report = [
        "# Retrieval evals report",
        "",
        f"- Questions: **{len(questions)}**",
        f"- Top-K used: **{args.top_k}** (strict top-K: {args.top_k_strict})",
        f"- Precision@{args.top_k}: **{precision_at_k:.2%}**",
        f"- Mean recall@{args.top_k}: **{mean_recall:.2f}**",
        f"- Strict failures (expected path missing from top-{args.top_k_strict}): **{len(strict_failures)}**",
        "",
    ]
    if strict_failures:
        report.append("## Strict failures")
        report.append("")
        for qid, missing in strict_failures:
            report.append(f"- `{qid}` — missing: {missing}")
        report.append("")
    report.append("## Per-question detail")
    report.append("")
    report.extend(lines)

    report_path.write_text("\n".join(report), encoding="utf-8")
    print(f"Wrote {report_path.relative_to(root)}; precision@{args.top_k}={precision_at_k:.2%}; strict-failures={len(strict_failures)}")

    if precision_at_k < args.min_precision:
        print(f"FAIL: precision@{args.top_k} {precision_at_k:.2%} < min {args.min_precision:.2%}", file=sys.stderr)
        return 1
    if strict_failures:
        print(f"FAIL: {len(strict_failures)} expected paths missing from top-{args.top_k_strict}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
