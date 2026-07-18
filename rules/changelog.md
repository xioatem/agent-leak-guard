# Rules Changelog

> Rule set is versioned independently from the program. Each change can ship on its own cadence.
> All entries derive from public reports or config audits — no unverified accusations.

## v0.2.0 (2026-07-19)
- **Rule Object schema**: every entry now carries a stable `rule_id` (ALG-EXXX / ALG-IXXX / ALG-CXXX)
  plus governance metadata: `confidence`, `evidence`, `references`, `platforms`, `introduced`, `last_updated`.
- `confidence` levels: `confirmed` (public wire-level evidence) / `observed` (config audit or vendor docs) / `community` (unverified report).
- First 10 rule objects assigned: ALG-E001..003, ALG-I001..004, ALG-C001..003.
- Added `rules/SCHEMA.md` documenting the rule-object contract and PR flow.
- Source basis: cereblab wire-level analysis (2026-07, HN discussion) + user-side config audit.

## v0.1.0 (2026-07-18)
- Initial `exfil_signatures.json` shipped with Release v0.1.
- `exfil_endpoints`: 3 FQDN/host leak indicators (Grok GCS bucket host, Cursor/Copilot telemetry hosts).
- `exfil_indicators`: 4 URI / binary-string features.
- `ai_cli_list`: 3 entries (Grok CLI, Claude Code, Cursor) with config paths + plaintext key fields.
