# Privacy

Local SEO Skills runs inside your Claude Code or Agent Skills host. The skills themselves are text files; they don't phone home, log telemetry, or exfiltrate anything.

Data movement happens in three places: your MCP data providers, your host agent, and your local filesystem. This doc describes each.

## What the skills read and write locally

The skills read and write under `~/.claude/skills/localseoskills/` (or `LSS_INSTALL_DIR` if you set it).

Client work is stored in `briefs/`:

- `briefs/<client-slug>/brief.md` — persistent client profile Claude reads and updates
- `briefs/<client-slug>/history/` — audit snapshots, ranking pulls, report outputs
- `briefs/<client-slug>/notes.md` — your notes

`briefs/` is in `.gitignore` by default (except `_templates/` and `README.md`), so nothing in it is committed to git unless you change that rule.

Backups: `uninstall.sh` copies `briefs/` to `~/.claude/lss-briefs-backup-<timestamp>` before removing the install directory. The backup stays on your machine until you delete it.

## What the skills send to external services

The skills do not make network calls themselves. They instruct the host agent (Claude Code, Claude Desktop, etc.) to call MCP servers you've already connected. Any data sent leaves your machine through those MCP calls, not through anything in this repo.

Typical MCP providers the skills ask the host to call:

- **LocalSEOData** (default) — sends business name, address, keyword, and location to `https://localseodata.com`. See their privacy policy for retention.
- **Local Falcon, BrightLocal, Whitespark, Semrush, Ahrefs, SerpAPI, DataForSEO, Screaming Frog** — each has its own privacy terms; connecting them is your choice.
- **Google Search Console, Google Analytics** — OAuth scoped to the properties you grant.

If you've wired a non-standard MCP (e.g. a local LLM, a scraper), the skills will use whatever you've configured.

## What the host agent sees

The host agent (Claude, Cursor, Codex, etc.) reads the skill files and any brief or note you point it at during a session. If the host sends prompts to a cloud model, the content of those files travels with the prompt. Review your host's data policy separately; it's outside the scope of this repo.

Do not paste credentials, API keys, or PII into briefs or notes. The skills have no mechanism to redact secrets before they hit the host.

## Telemetry

None. This repo has no analytics, no error reporting, no usage beacons.

## Clearing your data

To remove everything the skills wrote:

```bash
bash ~/.claude/skills/localseoskills/uninstall.sh
rm -rf ~/.claude/lss-briefs-backup-*
```

The first line backs up `briefs/` and removes the install directory. The second removes the backup. After both, the skills have left no data on your machine.

## Changes to this policy

Material changes are announced in `CHANGELOG.md` and via a pinned issue. Minor wording fixes are not.
