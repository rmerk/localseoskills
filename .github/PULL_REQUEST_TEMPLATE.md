## What this changes

One sentence on the outcome. Save the detail for the checklist below.

## Why

Link the issue this closes, or describe the motivation if there's no issue.

Closes #

## Scope

- [ ] New skill
- [ ] Existing skill change
- [ ] Task template
- [ ] Install / uninstall script
- [ ] Docs only
- [ ] CI / tooling
- [ ] Other:

## Skill checklist (if touching a skill)

- [ ] `name` in frontmatter matches the directory name
- [ ] `description` is 1-1024 chars and includes trigger phrases
- [ ] SKILL.md is under 500 lines
- [ ] No credentials, API keys, or client PII
- [ ] Tested end-to-end with at least one host agent

## Install / uninstall checklist (if touching these scripts)

- [ ] Guard refuses `/`, `$HOME`, top-level system dirs, and `..`-traversal inputs
- [ ] Both raw input and resolved path are checked against the blocklist
- [ ] Length floor and home-dir guard still present
- [ ] Tested from a clean `/tmp` clone against the dangerous-input battery in `SECURITY.md`
- [ ] CI `ci.yml` passes

## Claude Code contributors

- [ ] Co-authorship trailers disabled (`{"coauthorship": false}` in settings)
- [ ] No references to the AI tool in commit messages, code comments, or docs
