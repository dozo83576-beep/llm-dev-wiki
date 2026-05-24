"""
Offline retrieval evaluation against golden Q&A.

Uses the text-only corpus snapshot from tools/build_embeddings.py and a local
BM25-style scorer. No network access or external API keys are required.

Usage:
    python tools/build_embeddings.py
    python tools/run_offline_retrieval_evals.py --min-precision 0.6 --top-k 5
"""
from __future__ import annotations

import argparse
import json
import math
import re
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path

try:
    import yaml
except ImportError:
    print("Missing dependency: pyyaml (pip install -r tools/requirements.txt)", file=sys.stderr)
    sys.exit(2)


TOKEN_RE = re.compile(r"[a-zA-Zа-яА-ЯёЁ0-9][a-zA-Zа-яА-ЯёЁ0-9_-]*", re.UNICODE)

STOPWORDS = {
    "a", "an", "and", "are", "as", "by", "for", "from", "how", "in", "is", "of", "or", "the", "to", "with",
    "без", "в", "где", "для", "и", "из", "как", "какая", "какие", "какой", "когда", "ли", "на", "нужна",
    "нужно", "от", "по", "перед", "при", "с", "что",
}

QUERY_EXPANSIONS = {
    "версионировать": ["versioning", "version", "versions"],
    "версионирование": ["versioning", "version", "versions"],
    "версии": ["versioning", "version", "versions"],
    "опытом": ["knowledge", "capture", "post", "project", "lessons", "learned", "case", "studies", "wiki"],
    "опыт": ["knowledge", "capture", "post", "project", "lessons", "learned", "case", "studies", "wiki"],
    "завершения": ["post", "project", "retrospective", "lessons", "learned"],
    "завершении": ["post", "project", "retrospective", "lessons", "learned"],
    "проекта": ["project"],
}


@dataclass(frozen=True)
class Chunk:
    path: str
    chunk_id: str
    text: str
    title: str


def tokenize(text: str) -> list[str]:
    tokens = [m.group(0).lower().replace("ё", "е") for m in TOKEN_RE.finditer(text)]
    return [t for t in tokens if len(t) > 1 and t not in STOPWORDS]


def expand_query_tokens(tokens: list[str]) -> list[str]:
    expanded = list(tokens)
    for token in tokens:
        expanded.extend(QUERY_EXPANSIONS.get(token, []))
    return expanded


def load_snapshot(path: Path) -> list[Chunk]:
    chunks: list[Chunk] = []
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            rec = json.loads(line)
            chunks.append(Chunk(
                path=str(rec["path"]),
                chunk_id=str(rec["chunk_id"]),
                title=str(rec.get("title") or ""),
                text=str(rec.get("text") or ""),
            ))
    return chunks


def load_questions(path: Path) -> list[dict]:
    raw = path.read_text(encoding="utf-8")
    if raw.startswith("---"):
        parts = raw.split("---", 2)
        if len(parts) >= 3:
            raw = parts[2]
    data = yaml.safe_load(raw) or {}
    return data.get("questions") or []


def build_index(chunks: list[Chunk]) -> tuple[list[Counter], dict[str, int], float]:
    docs: list[Counter] = []
    doc_freq: dict[str, int] = defaultdict(int)
    total_len = 0

    for chunk in chunks:
        weighted_text = f"{chunk.title} {chunk.title} {chunk.path} {chunk.text}"
        counts = Counter(tokenize(weighted_text))
        docs.append(counts)
        total_len += sum(counts.values())
        for token in counts:
            doc_freq[token] += 1

    avg_len = total_len / max(len(docs), 1)
    return docs, dict(doc_freq), avg_len


def score_query(query: str, chunks: list[Chunk], docs: list[Counter], doc_freq: dict[str, int], avg_len: float) -> list[tuple[str, float]]:
    query_tokens = expand_query_tokens(tokenize(query))
    if not query_tokens:
        return []

    n_docs = len(docs)
    k1 = 1.5
    b = 0.75
    path_scores: dict[str, float] = defaultdict(float)

    for chunk, counts in zip(chunks, docs):
        doc_len = sum(counts.values()) or 1
        score = 0.0
        for token in query_tokens:
            tf = counts.get(token, 0)
            if tf == 0:
                continue
            df = doc_freq.get(token, 0)
            idf = math.log(1 + (n_docs - df + 0.5) / (df + 0.5))
            denom = tf + k1 * (1 - b + b * doc_len / max(avg_len, 1e-9))
            score += idf * (tf * (k1 + 1) / denom)

        if score > path_scores[chunk.path]:
            path_scores[chunk.path] = score

    return sorted(path_scores.items(), key=lambda item: (-item[1], item[0]))


def render_report(rows: list[dict], top_k: int, min_precision: float, precision: float) -> str:
    lines = [
        "# Offline retrieval evals",
        "",
        f"- Mode: offline-text",
        f"- Questions: {len(rows)}",
        f"- Precision@{top_k}: {precision:.3f}",
        f"- Minimum precision: {min_precision:.3f}",
        "",
        "| ID | Pass | Expected | Top results |",
        "|---|---:|---|---|",
    ]
    for row in rows:
        expected = "<br>".join(row["expected_paths"])
        top = "<br>".join(f"{path} ({score:.3f})" for path, score in row["top_results"])
        lines.append(f"| {row['id']} | {'yes' if row['passed'] else 'no'} | {expected} | {top} |")
    lines.append("")
    return "\n".join(lines)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Run offline retrieval evals on golden Q&A.")
    parser.add_argument("--root", default=".")
    parser.add_argument("--snapshot", default="embeddings/snapshot.jsonl")
    parser.add_argument("--golden", default="docs/14-llm-indexing/golden-qa.yaml")
    parser.add_argument("--top-k", type=int, default=5)
    parser.add_argument("--top-k-strict", type=int, default=10)
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
    questions = load_questions(golden_path)
    if not chunks:
        print("snapshot is empty", file=sys.stderr)
        return 2
    if not questions:
        print("no questions in golden set", file=sys.stderr)
        return 2

    docs, doc_freq, avg_len = build_index(chunks)
    rows: list[dict] = []
    passed = 0
    strict_failures: list[str] = []

    for item in questions:
        qid = str(item.get("id") or "")
        question = str(item.get("question") or "")
        expected_paths = [str(path) for path in item.get("expected_paths") or []]
        ranked = score_query(question, chunks, docs, doc_freq, avg_len)
        top = ranked[:args.top_k]
        strict_top_paths = {path for path, _ in ranked[:args.top_k_strict]}
        hit = any(path in {p for p, _ in top} for path in expected_paths)
        if hit:
            passed += 1
        if expected_paths and not any(path in strict_top_paths for path in expected_paths):
            strict_failures.append(qid)
        rows.append({
            "id": qid,
            "passed": hit,
            "expected_paths": expected_paths,
            "top_results": top,
        })

    precision = passed / len(questions)
    report = render_report(rows, args.top_k, args.min_precision, precision)
    report_path.write_text(report, encoding="utf-8")
    print(report)

    if precision < args.min_precision:
        print(f"precision@{args.top_k} below threshold: {precision:.3f} < {args.min_precision:.3f}", file=sys.stderr)
        return 1
    if strict_failures:
        print(f"expected paths missing from top-{args.top_k_strict}: {', '.join(strict_failures)}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
