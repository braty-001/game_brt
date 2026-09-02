# Buneko repository instructions

## Sources of truth

- Read `docs/foundations.md`, the relevant matching PRD and task list, and applicable ADRs before changing the project.
- Product rules recorded in PRDs, task lists, and ADRs take precedence over implementation assumptions.
- Record decisions that affect multiple PRDs or constrain future work in `docs/decisions/`.

## Workflow

- Before implementing behavior changes, present the affected files, execution order, tests, and risks, then wait for explicit approval.
- Update the relevant PRD and matching task list before changing game behavior. Do not invent product scope.
- Preserve unrelated user changes in a dirty worktree.
- Work as one agent by default. Do not create subagents unless the user explicitly asks for delegation or parallel agent work.

## Godot implementation

- The Godot project root is `braty/`, and its project file is `braty/project.godot`.
- Use English for technical identifiers. Use Portuguese only for useful comments whose intent is not evident from the code.
- Keep scenes focused on composition, presentation, input, and integration. Keep deterministic domain rules independent and testable when practical.
- Prefer small contracts, signals, and adapters over unnecessary direct references or central classes that know every block, sensor, or equipment type.
- Apply SOLID when it improves clarity, testability, or extensibility; do not add artificial layers.

## Validation

- After behavior changes, run:

  ```bash
  /home/braty/projetos/godot/godot --headless --path braty -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit -ginclude_subdirs -gexit
  ```

- Where relevant, cover RAM limits, invalid programs, control flow, sensors, and execution guards with automated tests.
- UI, physics, collision, visual feedback, and game feel require manual validation. Green automated tests do not establish visual or usability acceptance.
- Before opening or focusing a graphical window, taking screenshots, moving the pointer, or clicking, announce the action and obtain fresh explicit authorization.

## Reviews

- Report findings by severity, with concrete evidence and a recommended action.
- Look for regressions, excessive coupling, RAM-rule violations, execution freezes, documentation drift, and missing manual validation.
- A request for an opinion or review alone is read-only and does not authorize edits.
