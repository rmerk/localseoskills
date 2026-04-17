# Contributing

## Adding a New Skill

1. Create `skills/your-skill-name/SKILL.md`
2. Include required YAML frontmatter with `name` and `description`
3. `name` must match directory name exactly (lowercase, hyphens only)
4. `description` should include trigger phrases and scope boundaries
5. Keep SKILL.md under 500 lines
6. Submit a PR with branch name `feature/skill-name`

## Improving Existing Skills

1. Branch: `fix/skill-name-description`
2. Keep the same frontmatter `name`
3. Bump version in metadata
4. Describe what you changed in the PR

## Style Guide

- Direct, instructional tone
- Second person ("You are an expert in...")
- Specific over vague — include real examples
- Bold for key terms, code blocks for templates
- No fluff or filler

## Claude Code Settings

If you use Claude Code to contribute, disable co-authorship trailers before committing:

```json
{
  "coauthorship": false
}
```

Add this to `~/.claude/settings.json` (global) or `.claude/settings.json` (project).

The project-level `.claude/settings.json` is checked into this repo with `coauthorship: false`, so commits authored through Claude Code from a clone of this repo preserve single authorship by default. If you use a global `~/.claude/settings.json` as well, the project-level file takes precedence inside this directory.

## Testing install / uninstall safely

Never run `install.sh` or `uninstall.sh` with `--force` against a real path you care about. Recommended sandbox:

1. Clone into `/tmp/lss-test`
2. Point `LSS_INSTALL_DIR` at a disposable path inside `/tmp`
3. Exercise the dangerous-input battery listed in `SECURITY.md` first — every entry must refuse before the happy path is tested
4. For local end-to-end runs, pipe confirmation in (`echo "yes" | bash uninstall.sh`) rather than passing `--force`

While developing the guard itself, substitute `echo "WOULD RUN: ..."` for any destructive line so a bug in the guard can't wipe anything.

## PR Checklist

- [ ] `name` matches directory name
- [ ] `description` is 1-1024 chars with trigger phrases
- [ ] SKILL.md under 500 lines
- [ ] No sensitive data or credentials
- [ ] Co-authorship trailers disabled (see above)
- [ ] Tested with Claude Code
