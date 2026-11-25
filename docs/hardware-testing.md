# Validation and hardware test record

## Actual validation — 2026-11-18

| Check | Result |
| --- | --- |
| Workspace and ancestor instruction inspection | Empty project; no applicable AGENTS.md found; no existing Git repository |
| Java runtime | Installed OpenJDK 17.0.21.1; direct `java -version` succeeded |
| VS Code extension | Garmin Monkey C 1.1.3 installed successfully |
| SDK Manager | 1.0.16 installed in Applications |
| SDK | SDK Manager installed and activated Connect IQ 9.3.0 |
| fr265 definition | Installed successfully through SDK Manager |
| Monkey C compile / warnings | SDK 9.3.0 debug, test and release builds succeeded; final test/release builds have no warnings. Fixed launcher size (60×60) and test array typing. |
| Build script / resources | Shell syntax, resource XML/SVG, and VS Code JSON parsed successfully; fixed macOS Bash 3.2 empty-array compatibility |
| Signing key | Generated locally with restrictive permissions; private files in ignored .local/ |
| Simulator automated behavior tests | All 4 passed: stage/completion, cancellation/hide, delayed callbacks, buttons/app stop |
| Simulator visual/input checks | App loaded through CLI; interactive inspection unavailable because Computer Use permission was not granted |
| OpenMTP | Version 3.3.0 installed successfully |
| Device PRG | Release build produced bin/SoftRise.prg targeting fr265 (about 15 KB) |
| Mac MTP transfer | User connected the 265 through OpenMTP and subsequently reported the app works on the watch |
| Hardware launch | User reported “perfect app works” on 2026-11-18; specific pulse feel and measured timing not yet reported |
| Physical vibration feel / duration | Detailed feedback pending |
| Overnight reliability / sleep / battery | Not tested; outside this milestone |

## Simulator checklist (pending)

- [ ] Launch on fr265; verify all text fits the round display with no clipping.
- [ ] UP/DOWN select all four tests and wrap at either end.
- [ ] START begins the selected test; state, stage, countdown and progress update.
- [ ] Each single test completes around six seconds with three pulse requests.
- [ ] Ramp progresses at 10 and 20 seconds, completes at 30 seconds, and never restarts itself.
- [ ] START stops a running test; navigation cannot change tests while running.
- [ ] BACK stops first; a subsequent BACK exits.
- [ ] Hide/interruption cancels; returning stays idle with no new pulses.
- [ ] Cancel repeatedly near pulse/stage boundaries; no later pulse requests.
- [ ] Leave idle longer than 30 seconds; no automatic pulses.

Native Monkey C tests in source/LabTests.mc exercise the production tick and cleanup methods with a fake monotonic clock and motor boundary: stage deadlines, completion, late callbacks without bursts, single-test pulse counts, cancellation, hide/show, navigation lock/wrap, BACK behavior, and app-stop cleanup. All four passed in Garmin’s fr265 simulator on 2026-11-18, including after final warning cleanup. The CLI printed `PASSED (passed=4, failed=0, errors=0)` but returned exit code 1; success is based on the explicit report. These tests replace the clock/motor boundary and do not verify actual timer dispatch or vibration feel. After `bash scripts/build.sh --test`, start the SDK simulator and run its `bin/monkeydo bin/SoftRise-tests.prg fr265 -t` with Java on PATH.

## Hardware procedure

Use an awake, seated test first, with normal comfortable strap fit. This is not an alarm to rely on. Record watch firmware and settings before starting. Leave a few seconds between tests so the previous pulse has finished.

1. Install the fr265 device PRG using README's MTP steps; confirm the app opens.
2. Run **Short taps** twice. Record whether all three pulses are perceptible and whether they feel gentle or sharp.
3. Repeat with **Medium taps** and **Long taps**. Rate each 0–5 for noticeability and 0–5 for harshness; compare to a normal Garmin alarm while awake.
4. Run **Gradual ramp**. Record whether the three stages feel progressively more noticeable and whether the first stage would be acceptable as a gentle start.
5. Stop with START during each stage, then wait 35 seconds. Repeat with BACK. There should be no further pulse starts; a pulse already underway may finish (nominal maximum 600 ms).
6. Interrupt/hide the app during the ramp, then reopen. It should remain stopped. Record which interruption you used and any unexpected vibration.
7. Verify automatic completion and repeated start/stop runs. Note missing, merged, overlong, or delayed pulses and any error screen.

## Results to fill after testing

Date / firmware / battery % / wrist fit / DND / sleep mode / vibration setting:

| Test | Perceptible pulses | Noticeability 0–5 | Harshness 0–5 | Notes |
| --- | --- | --- | --- | --- |
| 80 ms / 2 s | Pending | | | |
| 250 ms / 2 s | Pending | | | |
| 600 ms / 2 s | Pending | | | |
| 30 s ramp | Pending | | | |

Cancellation / hide / exit / completion results: **Pending**.

Decision: **Awaiting hardware evidence**. If short taps feel sufficiently gentle and reliable, investigate overnight feasibility next. If not, first tune duration/spacing or reconsider the product; do not assume scheduling will solve the tactile problem.

## User hardware report — 2026-11-18

User confirmed the sideloaded app works and requested scheduled alarms with escalating pulses. This confirms a hardware launch, but does not establish specific pulse ratings, all cancellation cases, or overnight reliability. Foreground-alarm tradeoff and detailed tactile feedback requested before implementing the next milestone.

## Alarm experiment — 2026-11-18

User confirmed the short pulses and compressed ramp felt fine and explicitly authorized a foreground alarm experiment while investigating alternatives. Implemented wake time, saved settings, 1–5 minute ramp, stop, five-minute snooze, ten-minute ringing limit, clock-change cancellation, hide/exit cleanup, and a coarse battery-drop display. New device build compiled with no warnings. Actual scheduled-alarm hardware behavior and incremental battery drain are untested. Follow docs/alarm-experiment.md before overnight use.

Alarm tests cover next-occurrence/midnight scheduling, ramp boundaries for all durations, automatic completion, delayed callbacks, snooze reset, cancellation, view hide/show, button navigation, and app-stop cleanup. Simulator report: `PASSED (passed=8, failed=0, errors=0)` for all four original lab tests plus four new alarm tests. Initial alarm tests exposed string identity comparisons in the state machine; replaced with content equality and reran successfully. Final test and release builds have no warnings. As with the earlier SDK run, monkeydo returned 1 despite its explicit all-pass report. Interactive UI layout and hardware alarm timing are still unverified.

## UI revision — 2026-11-19

User reported text overflowing on the watch. Reduced alarm font sizes and on-screen copy, added circular width-aware text placement and a button-controlled day slider. UP/DOWN now changes the whole time in five-minute steps; START arms in one press. Options menu retains ramp settings and the lab. Both test and device builds completed without warnings after correcting a Monkey C cast-assignment syntax error. All eight simulator tests passed, including updated forward/backward midnight wrap checks. The SDK again returned exit code 1 with an explicit all-pass report. Actual revised layout and options menu need watch confirmation; no visual simulator inspection was performed.

## Touch sliders — 2026-11-19

Implemented separate hour/minute touch rails with tap and drag handlers. Both test/release builds succeed without warnings. Simulator suite reports all nine tests passed, including touch coordinate bounds, clamping, five-minute snapping, and edit lockout while armed/hidden. Initial test caught unsupported Math.min/max helpers; replaced with explicit clamps and reran successfully. As before, SDK process exit code is 1 despite explicit all-pass report. Actual touch gesture routing, slider feel, and revised layout still need the watch; automated tests exercise the production slider mapping methods, not synthetic OS drag events.

## Three-tap sets — 2026-11-19

User chose three short taps per roughly three-second set with longer taps later. Device/test builds succeed without warnings. All nine simulator tests pass, including exact three-tap grouping and quiet pauses at each stage, stage progression, missed callbacks, snooze, cancellation and touch controls. SDK again printed all-pass while exiting 1. Updated 80/180/350 ms tactile feel and real timer spacing remain unverified on hardware. Test a near-term alarm and report whether each set feels distinct and comfortable.

## First reported overnight outcome — 2026-11-20

User reports trying SoftRise last night and waking “a lot calmer,” describing it as working. This is one positive subjective overnight result on their Forerunner 265. Exact installed build/pattern, wake time, ramp settings, firmware, battery readings, screen state, DND/sleep settings, and sleep-tracking outcome were not supplied. Do not infer these or general overnight reliability. Next evidence: repeat-night results, measured battery drop against baseline, and interruption/sleep tracking checks.

## Code review and documentation — 2026-11-20

Reviewed scheduling/grouping, touch/input handling, lifecycle cleanup, persistence, battery reporting, build scripts and documentation. Fixed completed battery snapshots being overwritten by later idle cleanup, error messages hidden behind battery text, and stale displayed time during snooze. Added today/tomorrow context for armed alarms and handled storage access/save exceptions. Manifest minimum API is now 3.3 to match the drag callbacks. No pulse pattern was changed in this review.

Validation: test and release builds both succeeded without warnings on SDK 9.3.0. All **12** simulator tests passed (zero failures/errors), adding production-view adapter checks for actual tick dispatch into the motor boundary, battery snapshot stability, error priority across hide/show, wall-clock/offset changes, and snooze deadline display. The motor is replaced in these adapter tests; no new hardware test or visual layout verification was performed. Storage failure handling was inspected and compiled but actual device-full/read-failure conditions were not reproduced. SDK process again returned exit code 1 despite explicit all-pass report.

Documentation links, manifest XML and shell syntax were checked. New README, development guide, architecture and changelog reflect current behavior and the one owner-reported overnight result. No repository, license, public release, push or Garmin submission was created.

## Button direction — 2026-11-20

Alarm UP now adds five minutes and DOWN subtracts five minutes, per user preference. Test/release builds succeeded without warnings; all 12 simulator tests passed, including the reversed button mapping and midnight wrap. Initial run could not connect because the simulator was closed; reopening resolved it. SDK again returned exit code 1 with its explicit all-pass report. Actual button feel still needs the watch.

## Rounded Set alarm button — 2026-11-20

Replaced START: arm with a rounded mint Set alarm touch button; physical START still works. Debug/test and release compilation succeeded without warnings after a geometry type annotation. All 13 simulator tests passed, including pill hit boundaries, slider isolation, and armed/hidden touch lockout. The initial simulator connection failed because it was closed; reopening resolved it. SDK again returned 1 alongside its explicit all-pass report. Actual watch layout and touch feel need hardware confirmation. No GitHub push was made for this change.

## Owner battery observation — 2026-11-20

Owner described the first overnight test as taking “like 0 battery.” Record this as **no noticeable drop reported**, not zero power consumption. Exact before/after percentages, elapsed time, firmware/settings and measurement resolution were not supplied. No incremental battery drain can be calculated from this observation; controlled baseline measurements remain pending.

## Release candidate 0.1.0-rc.1 — 2026-11-20

Refined the existing vector brand to a sunrise and one horizon, per user feedback. Rendered opaque RGB/sRGB 500×500 and 128×128 store icons and a wordmark, and visually inspected the 500px icon plus wordmark. Rebuilt test, device, and IQ package artifacts successfully without warnings; exporter reported one device built (fr265 only). All 13 simulator tests passed; SDK again returned 1 with its explicit zero-errors all-pass report. Shell syntax, SVG/manifest XML, local documentation links, raster dimensions/profile, and artifact existence were checked. SHA-256 checksums are stored locally in ignored bin/. An attempted ZIP listing was inapplicable because the SDK-produced IQ is not a ZIP archive; no portal validation has occurred. Actual app screenshots and exact-candidate hardware tests remain pending. No public release, Garmin submission, or GitHub push was made.

## Owner photos and transparent launcher — 2026-11-20

Owner supplied IMG_9798, IMG_9799 and IMG_9800 showing the real watch’s app list, touch time editor/Set alarm button, and Armed / Today screen at 18:55. Photos confirm these screens render on hardware; no ringing/snooze state or measured battery interval was shown. The single visible 99% reading is not a before/after battery measurement. Photo originals remain outside the repository.

Restored three-line branding and changed launcher to a transparent PNG. Device and package builds succeeded without warnings. Standalone 500px mark, wordmark and 60px launcher alpha channels were verified (transparent corners; alpha range 0–255), and the mark visually inspected. Native list compositing still needs a watch check after installing the rebuilt PRG. This change did not alter alarm logic; no new automated behavior run was performed.

## Transparent icon confirmed and ringing photo — 2026-11-20

Owner confirmed the updated icon is correct and looks better on the watch. IMG_9801 shows SoftRise displaying 12:45, Waking / 1 of 3, snooze and stop controls on the actual Forerunner 265. This verifies the ringing-stage screen renders; the still image does not verify pulse duration, all three stages, snooze operation or stop operation. Owner is creating their Garmin developer account; no submission is recorded. Photo original remains outside the repository.

## Experimental Forerunner 265S target — 2026-11-21

Added an opt-in local build for `fr265s`. The standard 265 test build compiled successfully, and a 265 release build verified that the temporary project resolves the shared source and resources. The 265S compile stopped because its device definition was missing from this Mac's SDK installation. No 265S simulator or hardware checks have been run.

After the 265S device profile was installed, the 265S release PRG and simulator test PRG both compiled successfully without warnings. The first simulator test invocation could not connect to the simulator. No 265S hardware checks have been performed.

After the owner opened ConnectIQ.app, all 13 tests passed on the Forerunner 265S simulator (zero failures and zero errors). The SDK runner returned exit code 1 alongside its explicit pass report, as on the 265. The automated run exercises alarm logic and input handling. Visual inspection on the 360 × 360 display and physical vibration, screen timeout, and battery behavior still need validation.

The owner subsequently reported that all features worked in the Forerunner 265S simulator, including the vibration event. The earlier reported exit was no longer occurring for them, and its cause remains unknown. This is simulator evidence. Physical vibration and alarm behavior after the 265S display dims remain unverified.

The signed 0.1.0-rc.2 package exported successfully with both declared targets, fr265 and fr265s. This verifies packaging for both models. The physical 265S check is still pending.

## Wake presets · 2026-11-25

Device builds compiled for fr265 and fr265s. Both simulator suites reported 14 passed, zero failures and zero errors, including the new Gentle and Slow pulse timing checks. Visual fit, touch interaction, persistence across a real restart and the feel of each pattern await hands-on verification.

After replacing the custom Test hit area with a native menu action, both simulator suites passed 15 tests. The new regression exercises Test and Stop through the menu delegate and records the requested pulse using a test motor. Actual touch delivery and physical vibration remain unverified.

Updated preset timing and Wake up mode passed all 16 simulator tests on each target. The tests cover fallback cadence across all three presets and snoozing back to the opening stage. Physical feel awaits watch testing.
