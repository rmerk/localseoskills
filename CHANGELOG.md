# Changelog

All notable changes to Local SEO Skills are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versions use [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Individual skill versions are tracked in [VERSIONS.md](VERSIONS.md).

## [Unreleased]

### Added
- Claude Code plugin marketplace manifest (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`). Enables one-command install via `/plugin install local-seo-skills@garrettjsmith-localseo` in Claude Code 1.0.33+ and the Claude Desktop plugin browser.
- Install and uninstall scripts for macOS, Linux, and Windows (`install.sh`, `install.ps1`, `uninstall.sh`, `uninstall.ps1`). Idempotent updates, atomic clone-to-temp-then-move, concurrency lockfile, pre-flight writability check, briefs auto-backup to `$HOME/.claude/lss-briefs-backup-<timestamp>`, and dangerous-path guards on uninstall.
- Brand assets (`assets/`): wordmark, cover image, social preview image, logo mark, and favicons. SVG masters with PNG renders matching localseoskills.com brand tokens.

### Changed
- Full README rebuild: install moved to the top, 5-badge row, table of contents, 6 platform-specific install paths, outcome-driven Quick Start examples, "What Makes This Different" section surfacing the briefs, scheduled tasks, and LocalSEOData moats, 15-row scheduled task template table.

## [1.0.0] — unreleased

Initial tagged release will follow the merge of the above changes to `main`.
