# Skill Versions

## Strategy & Optimization Skills

| Skill | Version | Last Updated |
|-------|---------|-------------|
| gbp-optimization | 1.2.0 | 2026-03-01 |
| gbp-posts | 1.1.0 | 2026-03-01 |
| gbp-suspension-recovery | 1.1.0 | 2026-03-01 |
| gbp-api-automation | 1.1.0 | 2026-03-01 |
| geogrid-analysis | 1.2.0 | 2026-03-01 |
| local-seo-audit | 1.2.0 | 2026-03-01 |
| local-competitor-analysis | 1.1.0 | 2026-03-01 |
| local-reporting | 1.1.0 | 2026-03-01 |
| local-landing-pages | 1.2.0 | 2026-03-01 |
| service-area-seo | 1.1.0 | 2026-03-01 |
| review-management | 1.2.0 | 2026-03-01 |
| local-citations | 1.1.0 | 2026-03-01 |
| local-link-building | 1.1.0 | 2026-03-01 |
| local-schema | 1.1.0 | 2026-03-01 |
| lsa-ads | 1.1.0 | 2026-03-01 |
| local-search-ads | 1.1.0 | 2026-03-01 |
| local-ppc-ads | 1.1.0 | 2026-03-01 |
| apple-business-connect | 1.1.0 | 2026-03-01 |
| bing-places | 1.1.0 | 2026-03-01 |
| ai-local-search | 1.1.0 | 2026-03-01 |
| multi-location-seo | 1.1.0 | 2026-03-01 |
| client-deliverables | 1.1.0 | 2026-03-01 |
| local-keyword-research | 1.2.0 | 2026-03-01 |

## Tool Skills

| Skill | Version | Last Updated |
|-------|---------|-------------|
| local-falcon-tool | 1.0.0 | 2026-03-01 |
| lsa-spy-tool | 1.0.0 | 2026-03-01 |
| serpapi-tool | 1.0.0 | 2026-03-01 |
| semrush-tool | 1.0.0 | 2026-03-01 |
| ahrefs-tool | 1.0.0 | 2026-03-01 |
| brightlocal-tool | 1.0.0 | 2026-03-01 |
| dataforseo-tool | 1.0.0 | 2026-03-01 |
| google-search-console-tool | 1.0.0 | 2026-03-01 |
| google-analytics-tool | 1.0.0 | 2026-03-01 |
| screaming-frog-tool | 1.0.0 | 2026-03-01 |
| whitespark-tool | 1.0.0 | 2026-03-01 |

## v1.3.0 — LocalSEOData Integration

**New:**
- Added `localseodata-tool` skill — 36 endpoints covering SERP data, audits, reviews, citations, keywords, AI visibility, competitor analysis, geogrid scans, and more
- LocalSEOData is now the default data source for all LocalSEOSkills

**Updated:**
- `docs/tool-routing` — rewritten to position LocalSEOData as primary, other tools as specialists for gaps
- `skills/dispatch` — all request patterns now route to LocalSEOData first
- 13 strategy skills updated with LocalSEOData data source blocks: `local-seo-audit`, `geogrid-analysis`, `review-management`, `local-citations`, `local-competitor-analysis`, `local-keyword-research`, `ai-local-search`, `local-reporting`, `gbp-optimization`, `local-link-building`, `service-area-seo`, `multi-location-seo`, `lsa-ads`, `client-deliverables`
- 7 tool skills updated with LocalSEOData relationship notes: `serpapi-tool`, `dataforseo-tool`, `brightlocal-tool`, `whitespark-tool`, `local-falcon-tool`, `semrush-tool`, `ahrefs-tool`

**Package stats:** 36 skills, 12 tool integrations, 9,000+ lines of expertise
