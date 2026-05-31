# Changelog

All notable changes to `@keenmate/pure-admin-icons-mcp` are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Fixed

## [1.0.1] - 2026-05-31 [PUBLISHED]

### Changed
- `get_icon_svg` now routes URL fetches through `/api/download/...` so each explicit SVG retrieval is recorded in icons.pureadmin.io usage stats. Direct `/icons/...` URLs returned in search results stay untracked (those are used by `<img>` rendering); only deliberate tool calls count as downloads. Accepts both relative and absolute URLs.
- Documented the existing `get_usage_guide` tool in the README tool table.

## [1.0.0] - 2026-04-08 [PUBLISHED]

### Added
- Initial release. MCP server exposing `get_usage_guide`, `search_icons`, `get_icon_detail`, `get_icon_svg`, and `list_icon_sets` against icons.pureadmin.io.
