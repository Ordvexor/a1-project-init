# A1 Score


## Evidence
- CI: <paste-latest-run-URL>
- Log: evidence/logs/bootstrap.log
- SBOM: evidence/reports/sbom.json
- Perf: /evidence/reports/perf.csv

## Checks
- [ ] CI green on pre-commit, tests, sbom
- [ ] detect-secrets clean; baseline tracked
- [ ] Make verify non-zero on drift
- [ ] ADR present and linked

## TODO
- Blocker: pip-compile fails due to use_pep517 removal (pip 25.3 vs pip-tools 7.5.1)
- Next step: EITHER downgrade pip<24.1 OR switch pinning to uv.
