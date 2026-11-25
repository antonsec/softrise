# Changelog

## 0.1.0-rc.3

Choose Gentle, Steady, or Slow pulse and test a pattern before saving it. Ramp options groups the five ramp lengths in one menu. After the ramp, Wake up mode repeats three taps until you stop or snooze, or the ten-minute ringing limit is reached. The preset preview replaces the vibration lab menu.

## 0.1.0-rc.2 — package prepared locally

- Added Forerunner 265S to the package alongside the Forerunner 265. All 13 tests passed on the 265S simulator. Physical 265S validation is pending.

## 0.1.0-rc.1 — approved on Connect IQ

- Three-line sunrise logo, transparent 60px launcher and reusable PNG mark/wordmark; opaque 500px store and 128px device-store icons.
- Draft store listing, privacy/support notice, and release checklist.
- Signed IQ export using `bash scripts/build.sh --package`; generated packages remain ignored.
- Owner reports no noticeable battery drop after one night; exact readings remain unrecorded.

## Unreleased

Initial development for Forerunner 265.

### Features

- Rounded, tappable Set alarm button with physical START support.

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
