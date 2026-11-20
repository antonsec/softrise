# Changelog

## Unreleased

Personal prototype for Forerunner 265. No public release has been made.

### Features

- Foreground alarm with touch hour/minute sliders and five-minute button adjustments.
- Configurable 1–5 minute ramp using repeating three-tap sets.
- Stop, five-minute snooze, saved settings and ten-minute ringing limit.
- Original vibration lab and in-memory battery-drop snapshot.

### Review fixes — 2026-11-20

- Preserve completed battery readings across later idle view changes.
- Keep error/cancellation messages visible instead of hiding them behind battery text.
- Display the actual snooze deadline and today/tomorrow for armed alarms.
- Handle settings access/save failures without an uncaught storage exception.
- Declare API 3.3 minimum to match the touch-drag API used by the app.
- Reorganize documentation into a concise README, development guide, architecture and evidence records.

### Hardware evidence

- The owner confirmed the lab ran on their Forerunner 265 and the taps felt acceptable.
- On 2026-11-20, the owner reported one calmer wake-up after overnight use. Exact build/settings and battery/sleep data were not supplied.
