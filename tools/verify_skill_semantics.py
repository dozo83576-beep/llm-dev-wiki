from __future__ import annotations

import argparse
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover - Python < 3.11 is unsupported in CI
    tomllib = None


SCOPE_PATTERN = re.compile(r"полного маршрута|явного вызова", re.IGNORECASE)


def directory_hash(path: Path) -> str:
    rows: list[str] = []
    for item in sorted((entry for entry in path.rglob("*") if entry.is_file()), key=lambda entry: entry.as_posix().casefold()):
        relative = item.relative_to(path).as_posix()
        rows.append(f"{relative}={hashlib.sha256(item.read_bytes()).hexdigest().upper()}")
    return hashlib.sha256("\n".join(rows).encode("utf-8")).hexdigest().upper()


def provider_label(root: Path) -> str:
    normalized = root.as_posix().casefold().rstrip("/")
    if normalized.endswith("/.claude/skills"):
        return "claude"
    if normalized.endswith("/.agents/skills"):
        return "agents"
    if normalized.endswith("/.codex/skills"):
        return "codex"
    return "other"


def verify_runtime(
    root: Path,
    policy: dict,
    codex_config: Path,
    skill_roots: list[Path],
    quarantine_root: Path,
) -> list[str]:
    failures: list[str] = []
    plugin_policy = policy.get("pluginPolicy", {})
    if not codex_config.is_file():
        failures.append(f"Codex config missing: {codex_config}")
    elif tomllib is None:
        failures.append("tomllib is required for runtime plugin verification")
    else:
        with codex_config.open("rb") as stream:
            config = tomllib.load(stream)
        configured_plugins = config.get("plugins", {})
        for name, state in configured_plugins.items():
            expected = plugin_policy.get(name)
            if not isinstance(expected, dict):
                failures.append(f"enabled/configured plugin is not modeled: {name}")
                continue
            actual_enabled = bool(state.get("enabled"))
            if expected.get("enabled") is not actual_enabled:
                failures.append(
                    f"plugin state differs from policy: {name} expected={expected.get('enabled')} actual={actual_enabled}"
                )
        for name, expected in plugin_policy.items():
            if expected.get("managedByConfig") is False:
                continue
            if name not in configured_plugins:
                failures.append(f"policy plugin is missing from Codex config: {name}")
        configured_mcp = set(config.get("mcp_servers", {}))
        for name in policy.get("forbiddenMcpServers", []):
            if name in configured_mcp:
                failures.append(f"forbidden always-on MCP server: {name}")

    catalog = policy.get("catalog", {})
    active = set(catalog.get("activeSkills", []))
    quarantined = set(catalog.get("quarantineSkills", []))
    provider_quarantine = {
        key: set(value) for key, value in catalog.get("providerQuarantine", {}).items()
    }
    forbidden_patterns = [value.casefold() for value in catalog.get("forbiddenInstructionPatterns", [])]
    hashes_by_name: dict[str, set[str]] = {}
    for root in skill_roots:
        if not root.is_dir():
            continue
        provider = provider_label(root)
        for skill_file in root.glob("*/SKILL.md"):
            name = skill_file.parent.name
            if name in provider_quarantine.get(provider, set()) or name in quarantined:
                failures.append(f"quarantined skill remains active: {provider}:{name}")
                continue
            if name not in active:
                failures.append(f"active runtime skill is not classified by policy: {provider}:{name}")
                continue
            text = skill_file.read_text(encoding="utf-8").casefold()
            for pattern in forbidden_patterns:
                if pattern in text:
                    failures.append(f"unsafe active skill instruction: {provider}:{name}: {pattern}")
            hashes_by_name.setdefault(name, set()).add(directory_hash(skill_file.parent))
    for name, variants in hashes_by_name.items():
        if len(variants) > 1:
            failures.append(f"runtime copies differ for active skill: {name}")

    quarantine_verifier = root / "tools" / "manage-skill-catalog.ps1"
    if quarantine_verifier.is_file() and quarantine_root.is_dir():
        result = subprocess.run(
            [
                "pwsh",
                "-NoProfile",
                "-File",
                str(quarantine_verifier),
                "-VerifyQuarantine",
                "-QuarantineRoot",
                str(quarantine_root),
                "-OutputJson",
            ],
            text=True,
            encoding="utf-8",
            capture_output=True,
            check=False,
        )
        if result.returncode != 0:
            failures.append("quarantine restore audit failed")
    return failures


def read_description(text: str) -> str:
    if not text.startswith("---"):
        return ""
    parts = text.split("---", 2)
    if len(parts) < 3:
        return ""
    lines = parts[1].splitlines()
    for index, line in enumerate(lines):
        if not line.startswith("description:"):
            continue
        value = line.split(":", 1)[1].strip()
        if value not in {">", ">-", "|", "|-"}:
            return value.strip('"\' ')
        collected: list[str] = []
        for continuation in lines[index + 1 :]:
            if continuation and not continuation.startswith((" ", "\t")):
                break
            if continuation.strip():
                collected.append(continuation.strip())
        return " ".join(collected)
    return ""


def read_inputs(text: str) -> str:
    match = re.search(r"(?im)^Входы:\s*(.+(?:\n(?!\s*$).+)*)", text)
    return match.group(1).casefold() if match else ""


def verify_phase_skill_inputs(root: Path, policy: dict, actual: dict[str, Path]) -> list[str]:
    contract_path = root / "resources" / "site-pipeline-contract.json"
    if not contract_path.is_file():
        return []
    contract = json.loads(contract_path.read_text(encoding="utf-8"))
    phases = sorted(contract.get("phases", []), key=lambda item: item.get("number", 0))
    aliases = policy.get("phaseInputAliases", {})
    failures: list[str] = []
    for index, phase in enumerate(phases):
        skill_path = actual.get(str(phase.get("executor", "")))
        if skill_path is None:
            continue
        inputs = read_inputs(skill_path.read_text(encoding="utf-8"))
        if not inputs:
            continue
        for future in phases[index + 1 :]:
            artifact = str(future.get("artifact", ""))
            markers = {
                str(future.get("id", "")),
                str(future.get("executor", "")),
                artifact,
                Path(artifact).stem if artifact else "",
                *aliases.get(str(future.get("id", "")), []),
            }
            for marker in {value.casefold() for value in markers if len(value) >= 5}:
                if marker in inputs:
                    failures.append(
                        f"skill input references future phase: {phase.get('id')} -> {future.get('id')}: {marker}"
                    )
                    break
    return failures


def verify(root: Path) -> list[str]:
    failures: list[str] = []
    policy_path = root / "resources" / "skill-capability-policy.json"
    if not policy_path.is_file():
        return ["missing policy: resources/skill-capability-policy.json"]
    policy = json.loads(policy_path.read_text(encoding="utf-8"))

    design_capability = policy.get("designCapability")
    if int(policy.get("schemaVersion", 1)) >= 2:
        if not isinstance(design_capability, dict):
            failures.append("missing designCapability")
        else:
            native_owner = design_capability.get("nativeOwner")
            if not isinstance(native_owner, list) or not native_owner:
                failures.append("designCapability.nativeOwner must be a non-empty list")
            elif len(native_owner) != len(set(native_owner)):
                failures.append("designCapability.nativeOwner contains duplicate capabilities")
            artifact_owner = design_capability.get("localArtifactOwner")
            if not isinstance(artifact_owner, dict):
                failures.append("missing designCapability.localArtifactOwner")
            else:
                if artifact_owner.get("skill") != "site-design":
                    failures.append("design artifact owner must be site-design")
                if artifact_owner.get("artifact") != "DESIGN-DIRECTION.md":
                    failures.append("design artifact must be DESIGN-DIRECTION.md")
                activation = set(artifact_owner.get("activation", []))
                if activation != {"full-pipeline", "explicit"}:
                    failures.append(
                        "site-design activation must be full-pipeline and explicit"
                    )
            expected_precedence = [
                "project-brief",
                "brand-and-accessibility",
                "local-user-preferences",
                "wiki-defaults",
            ]
            if design_capability.get("preferencePrecedence") != expected_precedence:
                failures.append("invalid design preference precedence")

        external_decisions = policy.get("externalSkillDecisions")
        if not isinstance(external_decisions, dict):
            failures.append("missing externalSkillDecisions")
        else:
            for name in ("impeccable", "taste-skill"):
                decision = external_decisions.get(name)
                if not isinstance(decision, dict):
                    failures.append(f"missing external design skill decision: {name}")
                    continue
                if decision.get("decision") != "extract-only":
                    failures.append(f"external design skill must be extract-only: {name}")
                if decision.get("hooks") is not False:
                    failures.append(f"external design skill hooks must be disabled: {name}")
                if decision.get("installed") is not False:
                    failures.append(f"external design skill must not be installed: {name}")

        provider_specific = policy.get("providerSpecificSkills")
        if not isinstance(provider_specific, dict):
            failures.append("missing providerSpecificSkills")
        else:
            codex = provider_specific.get("codex")
            claude = provider_specific.get("claude")
            if not isinstance(codex, dict) or not isinstance(claude, dict):
                failures.append("providerSpecificSkills must define codex and claude")
            else:
                codex_plugins = set(codex.get("pluginManaged", []))
                vercel_helpers = {"vercel:react-best-practices", "vercel:shadcn"}
                if int(policy.get("schemaVersion", 1)) >= 4:
                    if codex_plugins.intersection(vercel_helpers):
                        failures.append("disabled Vercel bundle helpers must not remain capability owners")
                elif not vercel_helpers.issubset(codex_plugins):
                    failures.append("Codex design technology skills must remain namespaced")
                if claude.get("direct") != ["vercel-react-best-practices"]:
                    failures.append("Claude must have one canonical direct React skill")

        broad_plugins = (
            "sites@openai-bundled",
            "superpowers@superpowers-adaptive-lite",
            "build-web-apps@openai-curated",
            "vercel@openai-curated",
        )
        plugin_policy = policy.get("pluginPolicy", {})
        for plugin_name in broad_plugins:
            if plugin_policy.get(plugin_name, {}).get("enabled") is not False:
                failures.append(f"broad plugin must be disabled: {plugin_name}")

        provider_quarantine = policy.get("catalog", {}).get(
            "providerQuarantine", {}
        )
        if "vercel-react-best-practices" not in provider_quarantine.get(
            "agents", []
        ):
            failures.append("shared agents alias must be quarantined")

    if int(policy.get("schemaVersion", 1)) >= 3:
        motion = policy.get("motionMediaCapability")
        if not isinstance(motion, dict):
            failures.append("missing motionMediaCapability")
        else:
            native_owner = motion.get("nativeOwner")
            if not isinstance(native_owner, list) or not native_owner:
                failures.append("motionMediaCapability.nativeOwner must be a non-empty list")
            elif len(native_owner) != len(set(native_owner)):
                failures.append("motionMediaCapability.nativeOwner contains duplicate capabilities")
            if motion.get("globalSkill") is not False:
                failures.append("motion/media must not require a global skill")
            tiers = motion.get("interactionTiers")
            if not isinstance(tiers, dict) or set(tiers) != {"base", "cinematic", "specialized"}:
                failures.append("motion interaction tiers must be base, cinematic and specialized")
            routes = motion.get("routeOwnership")
            if not isinstance(routes, dict):
                failures.append("missing motion route ownership")
            else:
                direct = routes.get("direct", {})
                full = routes.get("full-pipeline", {})
                if direct.get("owner") != "native-model" or direct.get("statusFile") is not False:
                    failures.append("direct motion route must remain native without status file")
                expected_full = {
                    "designOwner": "site-design",
                    "integrationOwner": "site-frontend",
                    "verificationOwner": "site-review",
                }
                if any(full.get(key) != value for key, value in expected_full.items()):
                    failures.append("invalid full-pipeline motion owners")
            package_owner = motion.get("artifactOwners", {}).get("hero-media-package", {})
            if package_owner.get("owner") != "D:\\kontent":
                failures.append("hero media package owner must be D:\\kontent")
            if package_owner.get("manifest") != "media-manifest.json":
                failures.append("hero media package must use media-manifest.json")
            sora = motion.get("providerPolicy", {}).get("sora", {})
            if sora.get("status") != "deprecated" or sora.get("shutsDownAt") != "2026-09-24":
                failures.append("Sora sunset policy is missing or stale")
            if sora.get("replacementRequired") is not True:
                failures.append("deprecated Sora adapter must require replacement")
    if int(policy.get("schemaVersion", 1)) >= 4:
        routing = policy.get("toolRouting")
        if not isinstance(routing, dict):
            failures.append("missing toolRouting")
        else:
            hierarchy = routing.get("browser-hierarchy", [])
            owners = [entry.get("owner") for entry in hierarchy if isinstance(entry, dict)]
            expected_owners = [
                "specialized-connector-or-api",
                "browser@openai-bundled",
                "chrome@openai-bundled",
                "playwright",
                "computer-use@openai-bundled",
            ]
            if owners != expected_owners or len(owners) != len(set(owners)):
                failures.append("invalid or overlapping browser tool hierarchy")
            if routing.get("planning", {}).get("owner") != "native-model":
                failures.append("native model must own general planning")
        owners = policy.get("skillCapabilityOwners")
        if not isinstance(owners, dict) or not owners:
            failures.append("missing skillCapabilityOwners")
        elif any(not isinstance(value, str) or not value.strip() for value in owners.values()):
            failures.append("every capability must have one non-empty owner")

        plugin_policy = policy.get("pluginPolicy", {})
        for name, config in plugin_policy.items():
            if not isinstance(config, dict) or not isinstance(config.get("enabled"), bool):
                failures.append(f"plugin policy must declare boolean enabled state: {name}")
            elif config.get("enabled") and not config.get("activation"):
                failures.append(f"enabled plugin must have a scoped activation: {name}")
    skills_root = root / "agent-skills"
    expected = policy["canonicalSkills"]
    actual = {
        path.parent.name: path
        for path in skills_root.glob("*/SKILL.md")
        if path.is_file()
    }
    missing = sorted(set(expected) - set(actual))
    extra = sorted(set(actual) - set(expected))
    for name in missing:
        failures.append(f"missing canonical skill: {name}")
    for name in extra:
        failures.append(f"unexpected canonical skill: {name}")
    failures.extend(verify_phase_skill_inputs(root, policy, actual))

    total_lines = 0
    aggregate = ""
    forbidden = policy.get("forbiddenSkillPatterns", [])
    for name, config in expected.items():
        path = actual.get(name)
        if path is None:
            continue
        text = path.read_text(encoding="utf-8")
        aggregate += "\n" + text
        line_count = len(text.splitlines())
        total_lines += line_count
        budget = int(config.get("lineBudget", policy["budgets"]["defaultSkillLines"]))
        if line_count > budget:
            failures.append(f"line budget exceeded: {name} has {line_count}, limit {budget}")
        description = read_description(text)
        if not SCOPE_PATTERN.search(description):
            failures.append(f"description must scope activation: {name}")
        artifact = config.get("artifact", "")
        if artifact and artifact not in text:
            failures.append(f"missing artifact marker in {name}: {artifact}")
        lowered = text.casefold()
        for pattern in forbidden:
            if pattern.casefold() in lowered:
                failures.append(f"forbidden pattern in {name}: {pattern}")

    total_budget = int(policy["budgets"]["totalSkillLines"])
    if total_lines > total_budget:
        failures.append(f"total line budget exceeded: {total_lines}, limit {total_budget}")

    aggregate_lower = aggregate.casefold()
    for marker in policy.get("criticalMarkers", []):
        if marker.casefold() not in aggregate_lower:
            failures.append(f"missing critical marker: {marker}")

    for relative in policy.get("requiredFiles", []):
        if not (root / Path(relative)).is_file():
            failures.append(f"missing required file: {relative}")

    documentation_audit = policy.get("documentationAudit", {})
    for relative in documentation_audit.get("files", []):
        path = root / Path(relative)
        if not path.is_file():
            failures.append(f"missing documentation audit file: {relative}")
            continue
        lowered = path.read_text(encoding="utf-8").casefold()
        for pattern in documentation_audit.get("forbiddenPatterns", []):
            if pattern.casefold() in lowered:
                failures.append(
                    f"stale documentation pattern in {relative}: {pattern}"
                )

    design_documentation_audit = policy.get("designDocumentationAudit", {})
    for relative in design_documentation_audit.get("files", []):
        path = root / Path(relative)
        if not path.is_file():
            failures.append(f"missing design documentation audit file: {relative}")
            continue
        lowered = path.read_text(encoding="utf-8").casefold()
        for pattern in design_documentation_audit.get("forbiddenPatterns", []):
            if pattern.casefold() in lowered:
                failures.append(f"forced design pattern in {relative}: {pattern}")

    motion_documentation_audit = policy.get("motionDocumentationAudit", {})
    for relative in motion_documentation_audit.get("files", []):
        path = root / Path(relative)
        if not path.is_file():
            failures.append(f"missing motion documentation audit file: {relative}")
            continue
        lowered = path.read_text(encoding="utf-8").casefold()
        for pattern in motion_documentation_audit.get("forbiddenPatterns", []):
            if pattern.casefold() in lowered:
                failures.append(f"forced motion pattern in {relative}: {pattern}")

    catalog = policy.get("catalog", {})
    active_skills = set(catalog.get("activeSkills", []))
    for name in catalog.get("forbiddenActiveSkills", []):
        if name in active_skills:
            failures.append(f"forbidden active skill: {name}")

    for yaml_path in skills_root.glob("*/agents/openai.yaml"):
        text = yaml_path.read_text(encoding="utf-8").casefold()
        for pattern in policy.get("forbiddenOpenAiPatterns", []):
            if pattern.casefold() in text:
                failures.append(
                    f"forbidden openai prompt pattern in {yaml_path.parent.parent.name}: {pattern}"
                )
    return failures


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path.cwd())
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--verify-runtime", action="store_true")
    parser.add_argument("--codex-config", type=Path, default=Path.home() / ".codex" / "config.toml")
    parser.add_argument("--skill-root", action="append", type=Path, default=[])
    parser.add_argument("--quarantine-root", type=Path, default=Path("D:/Work/.skill-quarantine"))
    args = parser.parse_args()
    root = args.root.resolve()
    failures = verify(root)
    if args.verify_runtime:
        skill_roots = args.skill_root or [
            Path.home() / ".codex" / "skills",
            Path.home() / ".claude" / "skills",
            Path.home() / ".agents" / "skills",
        ]
        failures.extend(
            verify_runtime(
                root,
                json.loads((root / "resources" / "skill-capability-policy.json").read_text(encoding="utf-8")),
                args.codex_config.resolve(),
                [path.resolve() for path in skill_roots],
                args.quarantine_root.resolve(),
            )
        )
    if args.json:
        print(json.dumps({"failures": failures, "failureCount": len(failures)}, ensure_ascii=False))
    else:
        print("Skill semantic verification")
        print(f"Failures: {len(failures)}")
        for failure in failures:
            print(f"- {failure}")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
