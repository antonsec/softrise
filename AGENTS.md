# SoftRise

Native Monkey C Connect IQ watch app for **Forerunner 265 (`fr265`), not 265S**.
Current scope: a foreground alarm experiment plus the vibration lab. Overnight reliability is unverified.

- Read README.md and docs/decisions.md before changing behavior; docs/development.md covers tooling and docs/architecture.md covers source responsibilities.
- Consult official Garmin API docs; distinguish documentation, hypotheses, simulator evidence, and hardware evidence.
- Forerunners have fixed vibration duty cycle. Change pulse duration/spacing, never promise physical intensity control.
- Keep experimental values in source/LabPlan.mc. Use one profile per pulse.
- Stop timers and guard callbacks on cancellation, view hide, and app stop. No automatic resume.
- User authorized foreground alarm work after confirming the short taps and ramp felt fine. Do not add background scheduling, phone/backend/web features, or overnight promises without further evidence.
- Build with `bash scripts/build.sh`; device build: `bash scripts/build.sh --device`.
- Never track signing keys, credentials, SDKs, local absolute paths, or generated binaries. .local/ and bin/ are ignored.
- Do not publish, push, or submit to Garmin without explicit user instruction.
- Record actual validation in docs/hardware-testing.md. Never label unrun checks as passed.
