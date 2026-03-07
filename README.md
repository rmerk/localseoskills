# Local SEO Skills for Claude Code

A collection of 34 AI agent skills for local search optimization. Built for agencies, consultants, and multi-location brands managing Google Business Profiles, local rankings, and map pack visibility.

Built by [Garrett Smith](https://gmbgorilla.com) — 13+ years in local SEO, managing GBP optimization for Fortune 500 clients, hospital systems, and multi-location brands.

Inspired by [Corey Haines' Marketing Skills](https://github.com/coreyhaines31/marketingskills).

## What Are Skills?

Skills are markdown files that give AI agents specialized knowledge and workflows for specific tasks. When you add these to your project, Claude Code can recognize when you're working on a local SEO task and apply the right frameworks and best practices.

## Available Skills

| Skill | Description |
| --- | --- |
| [gbp-optimization](skills/gbp-optimization) | Google Business Profile setup, optimization, and map pack visibility |
| [gbp-posts](skills/gbp-posts) | GBP post strategy, templates, and scheduling |
| [gbp-suspension-recovery](skills/gbp-suspension-recovery) | GBP suspension prevention and reinstatement |
| [gbp-api-automation](skills/gbp-api-automation) | GBP API and bulk management for enterprise |
| [geogrid-analysis](skills/geogrid-analysis) | Map pack ranking analysis using geogrid scans and ARP/ATRP/SoLV |
| [local-seo-audit](skills/local-seo-audit) | Comprehensive local search presence audit |
| [local-competitor-analysis](skills/local-competitor-analysis) | Local pack competitor analysis and benchmarking |
| [local-reporting](skills/local-reporting) | Local SEO metrics, multi-location reporting, stakeholder-specific reports, and ROI |
| [local-keyword-research](skills/local-keyword-research) | Local keyword research, geo-modified keywords, intent classification, keyword mapping |
| [client-deliverables](skills/client-deliverables) | Audit reports, proposals, scopes of work, competitive reports, onboarding docs |
| [local-landing-pages](skills/local-landing-pages) | Location pages, service-area pages, and local content strategy |
| [service-area-seo](skills/service-area-seo) | SEO for service-area businesses without a storefront |
| [review-management](skills/review-management) | Review generation, response strategy, and reputation |
| [local-citations](skills/local-citations) | NAP consistency, citation building, and directory management |
| [local-link-building](skills/local-link-building) | Local backlink acquisition and digital PR |
| [local-schema](skills/local-schema) | LocalBusiness structured data and location schema |
| [lsa-ads](skills/lsa-ads) | Google Local Services Ads (pay-per-lead, Google Guaranteed) |
| [local-search-ads](skills/local-search-ads) | Ads inside the Google Maps local pack |
| [local-ppc-ads](skills/local-ppc-ads) | Geographically targeted Google Ads (PPC) |
| [apple-business-connect](skills/apple-business-connect) | Apple Maps optimization and Apple Business Connect |
| [bing-places](skills/bing-places) | Bing Maps optimization and Bing Places for Business |
| [ai-local-search](skills/ai-local-search) | AI Overviews, ChatGPT, Gemini, Copilot for local |
| [multi-location-seo](skills/multi-location-seo) | Managing SEO across 10-500+ locations at scale |

## Foundational Docs

Skills tell agents WHAT to do. These docs explain WHY it works, so agents can reason through edge cases.

| Doc | Description |
| --- | --- |
| [how-local-search-works](docs/how-local-search-works.md) | The ranking model (proximity, relevance, prominence), how the map pack gets assembled, entity resolution, how citations/reviews/links actually affect rankings |
| [local-seo-glossary](docs/local-seo-glossary.md) | Every acronym and concept: ARP, ATRP, SoLV, NAP, SAB, LSA, E-E-A-T, and 80+ more terms |

## Tools Registry

Each tool has a full skill with decision logic — when to use it, what to pull, what the data means, and what to do next. See the [Tools Registry](tools/REGISTRY.md) for the cross-reference guide.

### Tool Skills

| Skill | Tool | MCP Status |
| --- | --- | --- |
| [local-falcon-tool](skills/local-falcon-tool) | Local Falcon — geogrid scans, competitor reports, trend tracking, GBP monitoring | **Connected** |
| [lsa-spy-tool](skills/lsa-spy-tool) | LSA Spy — LSA ranking tracking and competitive intelligence | **Connected** |
| [serpapi-tool](skills/serpapi-tool) | SerpAPI — live SERP data for any query + location | **Connected** |
| [semrush-tool](skills/semrush-tool) | Semrush — keyword research, competitive analysis, site audit | **Available** |
| [ahrefs-tool](skills/ahrefs-tool) | Ahrefs — backlink analysis, link gap, competitive links | **Available** |
| [brightlocal-tool](skills/brightlocal-tool) | BrightLocal — citation audit, citation building, review monitoring | **Available** |
| [dataforseo-tool](skills/dataforseo-tool) | DataForSEO — bulk SERP data, keyword volumes, business data | **Available** |
| [google-search-console-tool](skills/google-search-console-tool) | Google Search Console — organic search performance, indexing | **Available** |
| [google-analytics-tool](skills/google-analytics-tool) | Google Analytics (GA4) — traffic, conversions, user behavior | **Available** |
| [screaming-frog-tool](skills/screaming-frog-tool) | Screaming Frog — technical crawling, site audit at scale | **Available** (community) |
| [whitespark-tool](skills/whitespark-tool) | Whitespark — citation gap analysis, managed citation building | Dashboard only |

## Installation

### Option 1: CLI Install (Recommended)

```bash
# Install all skills
npx skills add gmbgorilla/localseoskills

# Install specific skills
npx skills add gmbgorilla/localseoskills --skill gbp-optimization geogrid-analysis

# List available skills
npx skills add gmbgorilla/localseoskills --list
```

### Option 2: Clone and Copy

```bash
git clone https://github.com/gmbgorilla/localseoskills.git
cp -r localseoskills/skills/* .claude/skills/
cp -r localseoskills/tools/ .claude/tools/
```

### Option 3: Git Submodule

```bash
git submodule add https://github.com/gmbgorilla/localseoskills.git .claude/localseoskills
```

### Option 4: Fork and Customize

1. Fork this repository
2. Customize skills for your agency/clients
3. Clone your fork into your projects

## Usage

Once installed, just ask Claude Code to help with local SEO tasks:

```
"Audit this business's local search presence"
→ Uses local-seo-audit skill

"Optimize this Google Business Profile"
→ Uses gbp-optimization skill

"Analyze our geogrid rankings for 'plumber near me'"
→ Uses geogrid-analysis skill

"Create location pages for our 15 service areas"
→ Uses local-landing-pages skill

"My GBP got suspended, help me get it back"
→ Uses gbp-suspension-recovery skill

"How do I show up in ChatGPT for local searches?"
→ Uses ai-local-search skill

"Do keyword research for a plumber serving Buffalo and surrounding suburbs"
→ Uses local-keyword-research skill

"Create a proposal for managing 25 GBP locations at $150/location/month"
→ Uses client-deliverables skill

"Run a Local Falcon scan for 'emergency plumber' in Buffalo"
→ Uses local-falcon-tool + geogrid-analysis skills

"Who's ranking in LSAs for plumbing in my market?"
→ Uses lsa-spy-tool + lsa-ads skills

"Do keyword research for a plumber in Buffalo"
→ Uses semrush-tool + local-keyword-research skills

"Check my backlink profile vs competitors"
→ Uses ahrefs-tool + local-competitor-analysis skills

"Are my citations consistent?"
→ Uses brightlocal-tool + local-citations skills
```

## Skill Categories

### Google Business Profile
`gbp-optimization` · `gbp-posts` · `gbp-suspension-recovery` · `gbp-api-automation`

### Rankings & Analysis
`geogrid-analysis` · `local-competitor-analysis` · `local-seo-audit` · `local-reporting` · `local-keyword-research`

### Content & Pages
`local-landing-pages` · `service-area-seo`

### Authority & Reputation
`review-management` · `local-citations` · `local-link-building`

### Technical
`local-schema`

### Paid
`lsa-ads` · `local-search-ads` · `local-ppc-ads`

### Platforms
`apple-business-connect` · `bing-places` · `ai-local-search`

### Enterprise
`multi-location-seo`

### Client-Facing
`client-deliverables`

### Tool Skills
`local-falcon-tool` · `lsa-spy-tool` · `serpapi-tool` · `semrush-tool` · `ahrefs-tool` · `brightlocal-tool` · `dataforseo-tool` · `google-search-console-tool` · `google-analytics-tool` · `screaming-frog-tool` · `whitespark-tool`

## Contributing

PRs and issues welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
