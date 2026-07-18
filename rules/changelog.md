# Rules Changelog

> Rule set is versioned independently from the program. Each change here can be
> released on its own cadence (see VERSION). All entries are derived from public
> reports or config audits — no unverified accusations.

## v0.1.0 (2026-07-18)
- Initial `exfil_signatures.json` shipped with Release v0.1.
- `exfil_endpoints`: 3 FQDN/host leak indicators (Grok GCS bucket host, Claude/Cursor telemetry hosts).
- `exfil_indicators`: 4 URI / binary-string features (`repo_state.upload`, `before_codebase`, etc.).
- `ai_cli_list`: 3 entries (Grok CLI, Claude Code, Cursor) with config paths + plaintext key fields.
- Source basis: cereblab wire-level analysis (2026-07, HN discussion) + user-side config audit.

## Upcoming (v0.2)
- Add Gemini CLI / Codex / Aider endpoint & indicator features.
- Extend Scan beyond config key fields to env / shell history / .netrc.
- Add process-memory scan for `exfil_indicators` strings.
