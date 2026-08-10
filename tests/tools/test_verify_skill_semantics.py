from __future__ import annotations

import json
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tools" / "verify_skill_semantics.py"


def run_verify(root: Path, *extra: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["python", str(SCRIPT), "--root", str(root), *extra],
        text=True,
        encoding="utf-8",
        capture_output=True,
        check=False,
    )


def write_policy(root: Path, *, total_budget: int = 20) -> None:
    resources = root / "resources"
    resources.mkdir(parents=True)
    (resources / "skill-capability-policy.json").write_text(
        json.dumps(
            {
                "schemaVersion": 1,
                "budgets": {"totalSkillLines": total_budget, "defaultSkillLines": 12},
                "canonicalSkills": {
                    "demo-skill": {"artifact": "_demo.md", "lineBudget": 12}
                },
                "criticalMarkers": ["секрет", "подтвержден"],
                "forbiddenSkillPatterns": ["5–6", "senior-backend"],
                "requiredFiles": ["docs/skill-system.md"],
            },
            ensure_ascii=False,
        ),
        encoding="utf-8",
    )
    docs = root / "docs"
    docs.mkdir()
    (docs / "skill-system.md").write_text("ok\n", encoding="utf-8")


def write_skill(root: Path, body: str) -> None:
    skill = root / "agent-skills" / "demo-skill"
    skill.mkdir(parents=True)
    (skill / "SKILL.md").write_text(body, encoding="utf-8")


def test_valid_concise_skill_passes(tmp_path: Path) -> None:
    write_policy(tmp_path)
    write_skill(
        tmp_path,
        "---\nname: demo-skill\ndescription: Фаза только полного маршрута или явного вызова.\n"
        "---\n\n# Demo\n\nАртефакт: `_demo.md`. Секрет не сохранять; результат подтвержден.\n",
    )

    result = run_verify(tmp_path)

    assert result.returncode == 0, result.stdout + result.stderr
    assert "Failures: 0" in result.stdout


def test_forbidden_helper_and_quota_fail(tmp_path: Path) -> None:
    write_policy(tmp_path)
    write_skill(
        tmp_path,
        "---\nname: demo-skill\ndescription: Фаза только полного маршрута или явного вызова.\n"
        "---\n\n# Demo\n\nИспользуй senior-backend и проверь 5–6 вариантов. `_demo.md`.\n"
        "Секрет не сохранять; результат подтвержден.\n",
    )

    result = run_verify(tmp_path)

    assert result.returncode == 1
    assert "forbidden pattern" in result.stdout


def test_broad_description_and_missing_marker_fail(tmp_path: Path) -> None:
    write_policy(tmp_path)
    write_skill(
        tmp_path,
        "---\nname: demo-skill\ndescription: Помогает разрабатывать сайты.\n---\n\n"
        "# Demo\n\nАртефакт: `_demo.md`.\n",
    )

    result = run_verify(tmp_path)

    assert result.returncode == 1
    assert "description must scope activation" in result.stdout
    assert "missing critical marker" in result.stdout


def test_line_budget_fails(tmp_path: Path) -> None:
    write_policy(tmp_path, total_budget=8)
    body = (
        "---\nname: demo-skill\ndescription: Фаза только полного маршрута или явного вызова.\n---\n"
        "# Demo\n" + "строка\n" * 10 + "`_demo.md` секрет подтвержден\n"
    )
    write_skill(tmp_path, body)

    result = run_verify(tmp_path)

    assert result.returncode == 1
    assert "line budget" in result.stdout


def test_stale_documentation_reference_fails(tmp_path: Path) -> None:
    write_policy(tmp_path)
    policy_path = tmp_path / "resources" / "skill-capability-policy.json"
    policy = json.loads(policy_path.read_text(encoding="utf-8"))
    policy["documentationAudit"] = {
        "files": ["docs/skill-system.md"],
        "forbiddenPatterns": ["REMOVED-WORKFLOW.md"],
    }
    policy_path.write_text(json.dumps(policy, ensure_ascii=False), encoding="utf-8")
    (tmp_path / "docs" / "skill-system.md").write_text(
        "Use REMOVED-WORKFLOW.md\n", encoding="utf-8"
    )
    write_skill(
        tmp_path,
        "---\nname: demo-skill\ndescription: Фаза только полного маршрута или явного вызова.\n"
        "---\n\n# Demo\n\n`_demo.md` секрет подтвержден\n",
    )

    result = run_verify(tmp_path)

    assert result.returncode == 1
    assert "stale documentation pattern" in result.stdout


def test_design_policy_requires_single_owners_and_extract_only_decisions(tmp_path: Path) -> None:
    write_policy(tmp_path)
    policy_path = tmp_path / "resources" / "skill-capability-policy.json"
    policy = json.loads(policy_path.read_text(encoding="utf-8"))
    policy["schemaVersion"] = 2
    policy["designCapability"] = {
        "nativeOwner": ["brief-inference", "design-direction", "frontend-code"],
        "localArtifactOwner": {
            "skill": "site-design",
            "artifact": "DESIGN-DIRECTION.md",
            "activation": ["full-pipeline", "explicit"],
        },
        "preferencePrecedence": [
            "project-brief",
            "brand-and-accessibility",
            "local-user-preferences",
            "wiki-defaults",
        ],
    }
    policy["externalSkillDecisions"] = {
        "impeccable": {"decision": "install", "hooks": True},
        "taste-skill": {"decision": "extract-only", "hooks": False},
    }
    policy_path.write_text(json.dumps(policy, ensure_ascii=False), encoding="utf-8")
    write_skill(
        tmp_path,
        "---\nname: demo-skill\ndescription: Фаза только полного маршрута или явного вызова.\n"
        "---\n\n# Demo\n\n`_demo.md` секрет подтвержден\n",
    )

    result = run_verify(tmp_path)

    assert result.returncode == 1
    assert "external design skill must be extract-only: impeccable" in result.stdout
    assert "external design skill hooks must be disabled: impeccable" in result.stdout


def test_design_documentation_rejects_forced_defaults(tmp_path: Path) -> None:
    write_policy(tmp_path)
    policy_path = tmp_path / "resources" / "skill-capability-policy.json"
    policy = json.loads(policy_path.read_text(encoding="utf-8"))
    policy["designDocumentationAudit"] = {
        "files": ["docs/design.md"],
        "forbiddenPatterns": ["обязательный GSAP", "3–4 направления"],
    }
    policy_path.write_text(json.dumps(policy, ensure_ascii=False), encoding="utf-8")
    (tmp_path / "docs" / "design.md").write_text(
        "Для каждого сайта нужен обязательный GSAP.\n", encoding="utf-8"
    )
    write_skill(
        tmp_path,
        "---\nname: demo-skill\ndescription: Фаза только полного маршрута или явного вызова.\n"
        "---\n\n# Demo\n\n`_demo.md` секрет подтвержден\n",
    )

    result = run_verify(tmp_path)

    assert result.returncode == 1
    assert "forced design pattern in docs/design.md: обязательный GSAP" in result.stdout


def test_catalog_rejects_overlapping_direct_design_skills(tmp_path: Path) -> None:
    write_policy(tmp_path)
    policy_path = tmp_path / "resources" / "skill-capability-policy.json"
    policy = json.loads(policy_path.read_text(encoding="utf-8"))
    policy["catalog"] = {
        "activeSkills": ["demo-skill", "shadcn-ui"],
        "forbiddenActiveSkills": ["impeccable", "design-taste-frontend", "shadcn-ui"],
    }
    policy_path.write_text(json.dumps(policy, ensure_ascii=False), encoding="utf-8")
    write_skill(
        tmp_path,
        "---\nname: demo-skill\ndescription: Фаза только полного маршрута или явного вызова.\n"
        "---\n\n# Demo\n\n`_demo.md` секрет подтвержден\n",
    )

    result = run_verify(tmp_path)

    assert result.returncode == 1
    assert "forbidden active skill: shadcn-ui" in result.stdout


def test_design_provider_policy_rejects_shared_alias_and_enabled_broad_plugins(
    tmp_path: Path,
) -> None:
    write_policy(tmp_path)
    policy_path = tmp_path / "resources" / "skill-capability-policy.json"
    policy = json.loads(policy_path.read_text(encoding="utf-8"))
    policy["schemaVersion"] = 2
    policy["designCapability"] = {
        "nativeOwner": ["brief-inference"],
        "localArtifactOwner": {
            "skill": "site-design",
            "artifact": "DESIGN-DIRECTION.md",
            "activation": ["full-pipeline", "explicit"],
        },
        "preferencePrecedence": [
            "project-brief",
            "brand-and-accessibility",
            "local-user-preferences",
            "wiki-defaults",
        ],
    }
    policy["externalSkillDecisions"] = {
        "impeccable": {"decision": "extract-only", "hooks": False, "installed": False},
        "taste-skill": {"decision": "extract-only", "hooks": False, "installed": False},
    }
    policy["providerSpecificSkills"] = {
        "codex": {"pluginManaged": ["vercel:react-best-practices"]},
        "claude": {"direct": ["vercel-react-best-practices"]},
    }
    policy["pluginPolicy"] = {
        "sites@openai-bundled": {"enabled": True},
        "superpowers@superpowers-adaptive-lite": {"enabled": True},
    }
    policy["catalog"] = {
        "activeSkills": ["demo-skill", "vercel-react-best-practices"],
        "forbiddenActiveSkills": [],
        "providerQuarantine": {},
    }
    policy_path.write_text(json.dumps(policy, ensure_ascii=False), encoding="utf-8")
    write_skill(
        tmp_path,
        "---\nname: demo-skill\ndescription: Фаза только полного маршрута или явного вызова.\n"
        "---\n\n# Demo\n\n`_demo.md` секрет подтвержден\n",
    )

    result = run_verify(tmp_path)

    assert result.returncode == 1
    assert "broad plugin must be disabled: sites@openai-bundled" in result.stdout
    assert "shared agents alias must be quarantined" in result.stdout


def test_motion_policy_requires_native_direct_route_and_sunset(tmp_path: Path) -> None:
    write_policy(tmp_path)
    policy_path = tmp_path / "resources" / "skill-capability-policy.json"
    policy = json.loads(policy_path.read_text(encoding="utf-8"))
    policy["schemaVersion"] = 3
    policy["motionMediaCapability"] = {
        "nativeOwner": ["motion-direction"],
        "globalSkill": True,
        "interactionTiers": {"base": "css"},
        "routeOwnership": {
            "direct": {"owner": "site-design", "statusFile": True},
            "full-pipeline": {},
        },
        "artifactOwners": {
            "hero-media-package": {"owner": "site-design", "manifest": "video.json"}
        },
        "providerPolicy": {"sora": {"status": "active", "shutsDownAt": "", "replacementRequired": False}},
    }
    policy_path.write_text(json.dumps(policy, ensure_ascii=False), encoding="utf-8")
    write_skill(
        tmp_path,
        "---\nname: demo-skill\ndescription: Фаза только полного маршрута или явного вызова.\n"
        "---\n\n# Demo\n\n`_demo.md` секрет подтвержден\n",
    )

    result = run_verify(tmp_path)

    assert result.returncode == 1
    assert "motion/media must not require a global skill" in result.stdout
    assert "direct motion route must remain native without status file" in result.stdout
    assert "Sora sunset policy is missing or stale" in result.stdout


def test_motion_documentation_rejects_forced_library(tmp_path: Path) -> None:
    write_policy(tmp_path)
    policy_path = tmp_path / "resources" / "skill-capability-policy.json"
    policy = json.loads(policy_path.read_text(encoding="utf-8"))
    policy["motionDocumentationAudit"] = {
        "files": ["docs/motion.md"],
        "forbiddenPatterns": ["обязательный GSAP"],
    }
    policy_path.write_text(json.dumps(policy, ensure_ascii=False), encoding="utf-8")
    (tmp_path / "docs" / "motion.md").write_text("Нужен обязательный GSAP.\n", encoding="utf-8")
    write_skill(
        tmp_path,
        "---\nname: demo-skill\ndescription: Фаза только полного маршрута или явного вызова.\n"
        "---\n\n# Demo\n\n`_demo.md` секрет подтвержден\n",
    )

    result = run_verify(tmp_path)

    assert result.returncode == 1
    assert "forced motion pattern" in result.stdout


def test_runtime_verifier_rejects_unmodeled_plugin_and_generic_taskmaster(tmp_path: Path) -> None:
    write_policy(tmp_path)
    policy_path = tmp_path / "resources" / "skill-capability-policy.json"
    policy = json.loads(policy_path.read_text(encoding="utf-8"))
    policy["pluginPolicy"] = {}
    policy["forbiddenMcpServers"] = ["taskmaster-ai"]
    policy["catalog"] = {
        "activeSkills": ["demo-skill"],
        "quarantineSkills": [],
        "providerQuarantine": {},
        "forbiddenInstructionPatterns": [],
    }
    policy_path.write_text(json.dumps(policy, ensure_ascii=False), encoding="utf-8")
    write_skill(
        tmp_path,
        "---\nname: demo-skill\ndescription: Фаза только полного маршрута или явного вызова.\n"
        "---\n\n# Demo\n\n`_demo.md` секрет подтвержден\n",
    )
    config = tmp_path / "config.toml"
    config.write_text(
        '[plugins."unexpected@vendor"]\nenabled = true\n\n[mcp_servers.taskmaster-ai]\ncommand = "taskmaster"\n',
        encoding="utf-8",
    )

    result = run_verify(
        tmp_path,
        "--verify-runtime",
        "--codex-config",
        str(config),
        "--skill-root",
        str(tmp_path / "agent-skills"),
        "--quarantine-root",
        str(tmp_path / "quarantine"),
    )

    assert result.returncode == 1
    assert "configured plugin is not modeled: unexpected@vendor" in result.stdout
    assert "forbidden always-on MCP server: taskmaster-ai" in result.stdout


def test_skill_inputs_cannot_reference_future_phase(tmp_path: Path) -> None:
    write_policy(tmp_path)
    policy_path = tmp_path / "resources" / "skill-capability-policy.json"
    policy = json.loads(policy_path.read_text(encoding="utf-8"))
    policy["phaseInputAliases"] = {"future-phase": ["future design"]}
    policy_path.write_text(json.dumps(policy, ensure_ascii=False), encoding="utf-8")
    (tmp_path / "resources" / "site-pipeline-contract.json").write_text(
        json.dumps(
            {
                "phases": [
                    {"number": 1, "id": "demo", "executor": "demo-skill", "artifact": "_demo.md", "dependsOn": []},
                    {"number": 2, "id": "future-phase", "executor": "future", "artifact": "FUTURE.md", "dependsOn": ["demo"]},
                ]
            }
        ),
        encoding="utf-8",
    )
    write_skill(
        tmp_path,
        "---\nname: demo-skill\ndescription: Фаза только полного маршрута или явного вызова.\n"
        "---\n\n# Demo\n\nВходы: future design.\n\n`_demo.md` секрет подтвержден\n",
    )

    result = run_verify(tmp_path)

    assert result.returncode == 1
    assert "skill input references future phase: demo -> future-phase" in result.stdout
