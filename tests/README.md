# Tests / Fixtures

Non-executable fixtures to guard against **signature regressions** in PRs.

- `benign/`    — files that MUST NOT trigger a match (false-positive guards)
- `malicious/` — files that SHOULD trigger a match   (detection guards)

Usage (local harness, planned for v0.2):
```bash
./agent-leak-guard.sh scan --fixture tests/benign/sample_config.json    # expect: clean
./agent-leak-guard.sh scan --fixture tests/malicious/sample_leak.json   # expect: >=1 hit
```
All secrets in fixtures are **obviously fake placeholders** (e.g. `xai-XXXXFAKE`).
Never commit real credentials to this directory.
