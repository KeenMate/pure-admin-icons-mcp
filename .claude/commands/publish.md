---
description: Prepare @keenmate/pure-admin-icons-mcp for npm publish — verify registry sync, bump version, finalize CHANGELOG/README, validate, commit
argument-hint: rc|release|patch|minor|major
---

# /publish — prepare an npm release of @keenmate/pure-admin-icons-mcp

You are preparing the MCP server package for `npm publish`. **Do not run `npm publish`** — the user logs in and publishes manually.

## Argument

The release type: **$ARGUMENTS**

Must be one of:

- `rc` — bump the rc counter, or start a new rc cycle.
  - If `PKG_VERSION` is `X.Y.Z-rc.N`, `NEW_VERSION = X.Y.Z-rc.(N+1)`.
  - If `PKG_VERSION` is plain `X.Y.Z`, **default to** `NEW_VERSION = X.(Y+1).0-rc.1` (next minor, rc.1) and **ask the user to confirm** before proceeding. If they want a different bump kind (patch / major) for the rc cycle, they can answer and you re-compute. Don't pick silently.
- `release` — promote an rc to a final release. `PKG_VERSION` must be `X.Y.Z-rc.N` → `NEW_VERSION = X.Y.Z`. If `PKG_VERSION` is already a plain release, stop and ask (they probably wanted `patch`/`minor`/`major`).
- `patch` — SemVer patch bump. Drops any `-rc.N` suffix. `1.0.1-rc.N` → `1.0.1`, `1.0.0` → `1.0.1`.
- `minor` — SemVer minor bump. Drops `-rc.N`. Resets patch.
- `major` — SemVer major bump. Drops `-rc.N`. Resets minor and patch.

If missing or invalid, stop and ask which one to use (don't guess).

## Repo layout

Single npm package, published from the root:

- `package.json` — defines the package; `"version"` field is the source of truth
- `CHANGELOG.md` — at the repo root (may not exist yet on first run — see bootstrap note)
- `README.md` — at the repo root, may have 0–2 `## What's new in vX.Y.Z` blocks below the intro
- `src/index.ts` — source (TypeScript)
- `dist/` — built JS artefact published to npm (the `files:` array in package.json restricts the upload to this)

The package is consumed primarily via `npx -y @keenmate/pure-admin-icons-mcp` from MCP client configs, so any post-publish consumer needs to either wait for the npx cache to expire or clear it. Worth mentioning in the final report.

## CHANGELOG convention (Keep-a-Changelog + `[PUBLISHED]` marker)

Two-part shape:

- **`## [Unreleased]`** — always present at the very top of the CHANGELOG. Active work accumulates here under `### Added` / `### Changed` / `### Fixed` / `### Removed` subsections. No date, no version.
- **`## [X.Y.Z] - YYYY-MM-DD [PUBLISHED]`** — past releases that are confirmed on npmjs.com. The `[PUBLISHED]` tag at the end of the heading is what `/publish` writes to mark a version as having actually shipped.

Example:

```
## [Unreleased]

### Added
- Something the next release will ship.

## [1.1.0] - 2026-05-31 [PUBLISHED]

### Added
- ...

## [1.0.0] - 2026-05-15 [PUBLISHED]

### Added
- Initial release.
```

Publishing means:

1. Renaming `## [Unreleased]` to `## [NEW_VERSION] - <today> [PUBLISHED]` (in-place — the bullet content under it carries over unchanged).
2. Inserting a fresh empty `## [Unreleased]` block above it (with empty `### Added` / `### Changed` / `### Fixed` subsections) so the next dev cycle has somewhere to land.

**Bootstrap (first ever /publish run, no CHANGELOG.md present):** create `CHANGELOG.md` with the two-block shape — an empty `## [Unreleased]` at top, then `## [PKG_VERSION] - <today> [PUBLISHED]` for the version currently in `package.json` (i.e. the one already on npm), with a single bullet like `- Initial release.` under `### Added` if you have no better information. Then continue the normal flow as if CHANGELOG had been there all along. Confirm with the user before writing if you're unsure what the baseline release content should be.

## Resolve versions

- `PKG_VERSION` — read `"version"` from `package.json`.
- `CHANGELOG_LATEST_PUBLISHED` — the topmost `## [X.Y.Z] - YYYY-MM-DD [PUBLISHED]` entry in `CHANGELOG.md` (after bootstrap if needed).
- `NPM_LATEST` — `dist-tags.latest` field from `https://registry.npmjs.org/@keenmate/pure-admin-icons-mcp`.
- `NEW_VERSION` — computed from the argument per the table above.

## Steps (in order)

### 0. npm registry sync check (PREREQUISITE)

Verify that what the local CHANGELOG and `package.json` say agrees with what's actually on npmjs.com. This is a guard against drift — e.g. a version that was prepared and `[PUBLISHED]`-tagged locally but never actually pushed to npm.

- Fetch `https://registry.npmjs.org/@keenmate/pure-admin-icons-mcp`. Parse `dist-tags.latest`; that's `NPM_LATEST`.
  - If the request 404s, this is a first-time publish — skip the comparison and proceed to step 1.
  - If the request fails for transient reasons (network), stop and ask whether to retry or proceed without the check.
- Find `CHANGELOG_LATEST_PUBLISHED` — the topmost `## [X.Y.Z] - YYYY-MM-DD [PUBLISHED]` in `CHANGELOG.md` (after bootstrap-handling above if applicable).
- Compare `NPM_LATEST` and `CHANGELOG_LATEST_PUBLISHED`:
  - **If they match**, continue.
  - **If `CHANGELOG_LATEST_PUBLISHED` is newer than `NPM_LATEST`** (e.g. CHANGELOG claims `1.3.0 [PUBLISHED]` but npm only has `1.1.0`), CHANGELOG is overclaiming. Stop and report:
    - List every CHANGELOG `[PUBLISHED]` version newer than `NPM_LATEST`.
    - Ask the user whether to (a) re-publish those versions to npm before continuing, or (b) un-mark them in CHANGELOG (remove `[PUBLISHED]`, optionally merging the bullets back into `[Unreleased]`).
    - Do not auto-fix; this is a writing decision.
  - **If `NPM_LATEST` is newer than `CHANGELOG_LATEST_PUBLISHED`**, npm has a version not reflected locally. Stop and ask the user to manually add a `## [NPM_LATEST] - <publish-date> [PUBLISHED]` heading to CHANGELOG before rerunning.
- Also sanity-check `PKG_VERSION` against the others. The expected state at this point is `PKG_VERSION == NPM_LATEST == CHANGELOG_LATEST_PUBLISHED` for a plain release, or `PKG_VERSION` is an rc whose base `X.Y.Z` is newer than those (when iterating rcs). If `PKG_VERSION` is at neither the published version nor a forward rc, stop and report — something was edited manually.

### 1. Sanity checks

- Run `git status`. If the working tree has uncommitted changes **other than** `package.json`, `CHANGELOG.md`, `README.md`, and `src/**` (which you're about to touch or just changed), warn and ask before continuing.
- Confirm the `## [Unreleased]` section has at least one bullet of substantive content under `### Added`, `### Changed`, `### Fixed`, or `### Removed`. If empty, stop — there's nothing meaningful to release.

### 2. Compute `NEW_VERSION` and confirm if needed

Apply the version logic from the argument table above. The only branch that requires user confirmation **before** mutating files:

- **`rc` on a plain `X.Y.Z` package.json**: default to `X.(Y+1).0-rc.1` and ASK: _"Starting a new rc cycle. Default is `<X.(Y+1).0-rc.1>`. Confirm, or pick `patch` / `major` instead?"_ Wait for the answer; compute accordingly.

All other branches are deterministic — no prompt needed.

### 3. Bump `package.json`

If `NEW_VERSION != PKG_VERSION`, edit `package.json`:

```
"version": "PKG_VERSION"   →   "version": "NEW_VERSION"
```

Don't touch anything else in `package.json`. Don't run `npm version <bump>` — that command auto-creates a git tag, and tagging is something the user does **after** a successful `npm publish` (see step 10).

### 4. Finalize CHANGELOG

In `CHANGELOG.md`:

- Rename `## [Unreleased]` → `## [NEW_VERSION] - YYYY-MM-DD [PUBLISHED]` (today's date — pull from system context, don't guess).
- Leave the bullet content under the renamed heading untouched.
- Insert a fresh `## [Unreleased]` block at the very top of the changelog (above the just-renamed heading), with empty subsections:

```
## [Unreleased]

### Added

### Changed

### Fixed
```

### 5. Refresh README "What's new"

In `README.md`:

- Find the existing `## What's new in vX.Y.Z` blocks just below the intro/badges. There should be 0–2 of them. If 0 (first run), no prior block exists — that's fine.
- Add a new `## What's new in vNEW_VERSION` section at the top of that block (just before the most recent existing one). Place it above the first `## Tools` / `## Quick Start` / equivalent existing section, but below the package name and intro paragraph.
- Populate it with **3–5 concise bullets** summarising the most user-facing changes from the just-finalised CHANGELOG section. Prioritise: **Breaking** > **Added** > **Changed** > **Fixed**. Pick highlights, not everything.
- After adding the new section, **delete older ones so only the two most recent remain** (the new one plus the one before it). Don't accumulate.
- If there were 0 prior blocks, that's fine — the new one becomes the only block.
- Don't touch publish dates on prior blocks.

### 6. Validate README reflects CHANGELOG

Read both the finalised CHANGELOG section and the new README "What's new" block. Every **Breaking**, **Added**, or **Changed** CHANGELOG bullet that represents a user-facing feature or behaviour change should have a corresponding hit in the README block (paraphrased, not verbatim). Pure internal refactors and Fixed-only entries don't need coverage.

If a significant CHANGELOG entry isn't reflected, add a bullet for it. If you end up with more than ~5 bullets after this pass, condense — the section should be scannable.

### 7. Validate CHANGELOG matches recent work

Run `git log --oneline` from the previous published version's commit (find the previous `## [X.Y.Z] - YYYY-MM-DD [PUBLISHED]` heading in `CHANGELOG.md` to anchor the range — if you bootstrapped CHANGELOG in this run, skip this step). Also `git diff` for uncommitted work.

For every substantive commit or uncommitted change, verify the CHANGELOG section now under the renamed heading mentions it. If something significant is missing, **stop and ask the user** before finalising — don't invent entries on their behalf.

### 8. Run validation

In repo root, run **in parallel** where possible:

- `npm run build` — must pass clean. Catches TypeScript errors and writes the `dist/` that will be published.
- `npm pack --dry-run` — dry-run the package build; surfaces missing `files:` entries or bad `package.json` config. Read the file list and confirm only `dist/` (and metadata files npm always includes — `package.json`, `README.md`, `LICENSE` if present) are in the upload. **No `src/`, no `node_modules/`, no `.claude/`.**

If either fails, stop and report. Don't try to "fix and continue" without telling the user — a build failure or unexpected files in the pack means the release isn't ready.

### 9. Commit

Stage `package.json`, `CHANGELOG.md`, `README.md`. Create a commit using a HEREDOC for the message:

```
vNEW_VERSION — <one-line summary of the release's headline change>

<2–4 line description of what this version delivers, drawn from the CHANGELOG highlights>

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

Match whatever Co-Authored-By convention shows up in recent commits (`git log -5`) — don't introduce or strip one against the local style.

### 10. Report

Report back with:

- The new version number (`vX.Y.Z` or `vX.Y.Z-rc.N`)
- The commit SHA
- A note if the npm sync check surfaced any drift the user had to resolve before this run, or if CHANGELOG was bootstrapped in this run.
- Exactly what the user needs to run to publish, in this order:
  ```
  make publish    # or: npm publish --access public
  git tag vX.Y.Z
  git push origin <branch> vX.Y.Z
  ```
- A note that npx-based MCP clients (the typical install path: `npx -y @keenmate/pure-admin-icons-mcp`) cache packages. After a successful publish, end users may need to clear their npx cache or wait for it to expire before the new version is picked up. Worth restarting the MCP host process / clearing `~/.npm/_npx` if testing locally.
- A reminder that if `npm publish` fails:
  - `package.json` is already at `NEW_VERSION` and CHANGELOG already says `[PUBLISHED]` — neither matches reality yet.
  - They should either retry the publish (no file changes needed if npm transiently failed), OR revert the commit (or at minimum: revert `package.json` `"version"` back to `PKG_VERSION` and rename the CHANGELOG heading back to `## [Unreleased]`, dropping `[PUBLISHED]`) before attempting a different release.
  - The new empty `## [Unreleased]` block above can stay either way — it becomes the next release's WIP.

## Things not to do

- **Do not run `npm publish`.** The user publishes manually (interactive prompt + 2FA on npm).
- **Do not run `npm version <bump>`.** It edits `package.json` AND creates a git tag in one step — but tagging needs to wait until after a successful publish.
- **Do not push to git remote.** The commit stays local until the user pushes.
- **Do not tag.** The user tags after a successful `npm publish` — a failed publish would otherwise leave an orphan tag.
- **Do not skip the npm sync check (step 0).** Drift between CHANGELOG and the npm registry is the single most common source of confused future publishes; catching it before the next release is the whole point.
- **Do not invent CHANGELOG entries** to cover commits you find — ask the user if something's missing.
- **Do not touch publish dates on prior `## [...]` headings**, even to "normalise" them.
- **Do not exceed two `## What's new in vX.Y.Z` blocks in the README.** Delete the oldest to make room.
- **Do not include `src/` in the published package.** The `files:` array in `package.json` should keep this scoped to `dist/`; if `npm pack --dry-run` shows otherwise, stop and fix `package.json` rather than continuing the release.
- **Do not auto-fix npm sync drift** — adding/removing `[PUBLISHED]` tags or merging bullets back into `[Unreleased]` is a writing decision, not a mechanical one.
