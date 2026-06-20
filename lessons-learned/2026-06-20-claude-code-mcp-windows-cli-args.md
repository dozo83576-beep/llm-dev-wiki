---
title: "Claude Code MCP on Windows: npx flags and router package names"
category: "lessons-learned"
updated: "2026-06-20"
status: "active"
tags: ["mcp", "claude-code", "windows", "npm"]
source_priority: "internal"
---

# Claude Code MCP on Windows: npx flags and router package names

## Context

While adding Context7, Playwright MCP and Task Master to Claude Code on Windows, `claude mcp add <name> -- npx -y <package>` failed because the installed Claude Code CLI parsed `-y` as its own option.

## Lesson

- If `claude mcp add` rejects `npx -y`, avoid fighting the parser.
- Prefer installing the MCP package globally and registering its bin command:
  - `context7-mcp` for `@upstash/context7-mcp`
  - `playwright-mcp` for `@playwright/mcp`
  - `task-master-ai` for `task-master-ai`
- For Codex TOML config, `args = ["-y", "..."]` remains fine because the args are passed to the subprocess, not parsed by `claude`.
- Do not assume `claude-code-router` and `@musistudio/claude-code-router` are the same npm package. Check both names before reporting the latest version.

## Verification

- `claude mcp list` must show the new MCP servers as connected.
- `specify self check` should confirm Spec Kit is current.
- `ccr -v` should be used for the installed Router package actually providing the `ccr` bin.
