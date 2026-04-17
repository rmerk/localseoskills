# Task Templates

Fifteen scheduled task templates that run against a client brief on a recurring schedule. Tasks complement the skills: skills describe *what* to do on demand, tasks describe *what to do autonomously on a schedule*.

Each task is a directory containing a `TASK.md` with frontmatter describing its schedule, approval tier, required skills, and required MCP servers. Agents that support the Agent Skills spec discover tasks automatically once the skills are installed.

## Approval tiers

- **Tier 1 (autonomous)** — runs, writes output, no human in the loop. Used for monitoring and drafts the user will review async.
- **Tier 2 (notify)** — runs, writes output, pings the user. No block.
- **Tier 3 (hold for approval)** — runs, drafts the output, pauses until the user approves before anything leaves the agent.

## Catalog

### Execution (drafts, audits, content)

| Task | Cadence | Description |
|------|---------|-------------|
| [e1-gbp-post-drafts](e1-gbp-post-drafts/TASK.md) | Monthly | Drafts 4 GBP posts (service spotlight, seasonal, educational, social proof). Held for approval. |
| [e2-review-response-drafts](e2-review-response-drafts/TASK.md) | Weekly | Drafts personalized responses to unanswered reviews from the last 7 days. Held for approval. |
| [e3-citation-audit](e3-citation-audit/TASK.md) | Quarterly | NAP consistency audit across 20 directories. Report only. |
| [e4-page-content-audit](e4-page-content-audit/TASK.md) | Quarterly | Location page audit for thin content, schema, NAP, and keyword gaps. Drafts improvements for approval. |

### Monitoring (scheduled scans)

| Task | Cadence | Description |
|------|---------|-------------|
| [m1-rankings-monitor](m1-rankings-monitor/TASK.md) | Weekly | Geogrid ranking scan. Tracks ARP, ATRP, SoLV week-over-week. Alerts on degradation. |
| [m2-review-velocity](m2-review-velocity/TASK.md) | Weekly | Review health monitor. Velocity, sentiment, unanswered reviews, rating trend. |
| [m3-gbp-change-monitor](m3-gbp-change-monitor/TASK.md) | Daily | Detects unauthorized GBP edits against a saved baseline. |
| [m4-lsa-rankings-monitor](m4-lsa-rankings-monitor/TASK.md) | Weekly | LSA position tracking. Alerts on drops out of top 3. Requires LSA Spy MCP. |
| [m5-ai-visibility-monitor](m5-ai-visibility-monitor/TASK.md) | Monthly | AI search visibility across Google AI Overviews, ChatGPT, Gemini, Perplexity. |

### Prospecting

| Task | Cadence | Description |
|------|---------|-------------|
| [p1-prospect-audit](p1-prospect-audit/TASK.md) | On demand | Pre-sales-call audit framed as sales prep. Not a client deliverable. |
| [p2-competitor-monitor](p2-competitor-monitor/TASK.md) | Monthly | Competitive landscape snapshot. Map pack, competitor reviews, ad activity. |

### Reporting

| Task | Cadence | Description |
|------|---------|-------------|
| [r1-weekly-report](r1-weekly-report/TASK.md) | Weekly | Narrative performance summary. Rankings + reviews + map pack. Slack on completion. |
| [r2-monthly-client-report](r2-monthly-client-report/TASK.md) | Monthly | Client-facing performance report + email draft. Held for agency approval. |
| [r3-multi-location-rollup](r3-multi-location-rollup/TASK.md) | Monthly | Brand-level rollup across all locations. Reads from existing briefs. |
| [r4-quarterly-business-review](r4-quarterly-business-review/TASK.md) | Quarterly | 90-day business review. Held for agency approval. |

## How to use

- Install the skills (`install.sh` / `install.ps1`).
- Connect the MCP data providers each task requires (listed in the task's frontmatter).
- Wire your agent's scheduler to load the task on the indicated cadence. Details in the specific host agent's docs.
- For Tier 3 tasks, ensure the approval surface is wired (email, Slack, or the agent's approval UI).
