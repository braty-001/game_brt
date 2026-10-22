---
name: buneko-godot-audit
description: Audit the Buneko Godot project for architecture, documentation drift, test coverage, runtime safety, and manual validation gaps. Use for project reviews, quality assessments, readiness checks, or requests asking what should improve; do not activate for ordinary implementation tasks.
---

# Buneko Godot Audit

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../../../docs/godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

Produce an evidence-based assessment of the current checkout. Treat an audit as read-only unless the user separately authorizes changes.

## Load project context

1. Read `AGENTS.md` and `docs/foundations.md`.
2. Identify and read the PRD and matching task list relevant to the changed area.
3. Read applicable records in `docs/decisions/`.
4. Confirm that the Godot root is `braty/` and that `braty/project.godot` exists.
5. Inspect `git status` before other work and preserve all unrelated user changes.

## Verify the required Godot MCP

Follow `docs/godot-mcp.md` and ADR 016. Call `get_godot_version` and `get_project_info` for the absolute `braty/` path before Godot investigation. Record availability and results. If unavailable, report the blocker; read-only repository inspection may continue but cannot establish MCP validation. Use supported MCP diagnostics within the authorized scope, inspect both `output` and `errors`, and retain the separate headless, GUT, and manual checks below. GUI operations still require fresh authorization.

## Map the current state

- Inspect the changed files and diff before drawing conclusions.
- Inventory relevant code, scenes, resources, and tests under `braty/`; exclude generated `.godot/` content and vendored addons unless the issue points there.
- Compare documentation, implementation, and tests. Flag claims marked complete when code or manual acceptance does not support them.
- Check domain and scene boundaries, oversized orchestrators, duplicated rules, unnecessary coupling, RAM enforcement, and guards against programs freezing the game.
- Look for tests that pass without proving the intended player-visible behavior.

## Run automated validation

Use a writable temporary Godot data directory so logging failures do not create false results:

```bash
mkdir -p /tmp/buneko-godot-data
XDG_DATA_HOME=/tmp/buneko-godot-data /home/braty/projetos/godot/godot --headless --path braty -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit -ginclude_subdirs -gexit
XDG_DATA_HOME=/tmp/buneko-godot-data /home/braty/projetos/godot/godot --headless --path braty --quit-after 10
git diff --check
```

- Only report a successful test run after the process completes with a successful exit status and the test summary confirms it.
- If Godot cannot write `user://` logs, fix the validation environment and rerun; do not count the failed attempt as validation.
- A headless launch proves loading, not visual quality or playability.

## Respect the GUI boundary

Obtain fresh explicit authorization before opening or focusing a graphical window, taking screenshots, moving the pointer, or clicking. Record UI, physics, collision, visual feedback, and game feel as manually pending until they are actually checked.

## Report the result

Lead with the current project condition and path forward. Include:

1. Automated checks completed and their exact outcomes.
2. Findings ordered by severity, with file and line evidence where possible.
3. The project's current stage, distinguishing implemented, tested, and manually accepted work.
4. A short prioritized next path, separating correctness work from polish or future scope.

Do not recommend speculative systems or hierarchy before the MVP's current editor and gameplay loop have passed their manual acceptance gates.
