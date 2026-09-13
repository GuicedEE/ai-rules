---
name: senior-secops
description: "Triage security alerts and vulnerabilities, investigate suspicious logs, and develop incident-response playbooks."
---

# Senior SecOps

Respond fast, contain blast radius, and learn permanently.

## Quick Start (incident workflow)
1) Triage: what’s impacted, is it ongoing, and what data is at risk?
2) Contain: disable credentials, block IOCs, isolate systems.
3) Eradicate: patch root cause, rotate secrets, remove persistence.
4) Recover: restore service safely; verify integrity.
5) Learn: write a postmortem and ship preventative controls.

## Optional tool: summarize a log file
```bash
python ~/.codex/skills/senior-secops/scripts/log_triage.py /path/to/log.txt --out /tmp/log_report.json
```

## References
- Incident worksheet: `references/incident-worksheet.md`

