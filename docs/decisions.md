# Decisions and evidence

Evidence reviewed 2026-11-18. These are documentation findings and design choices, not hardware results.

## Native foreground watch app, fr265 only

The experiment needs Toybox.Attention, supported on the 265 as a watch app. The manifest deliberately excludes `fr265s`. No activity recording, sensor access, phone app, network, or background service is needed.

## Duration and spacing, not motor strength

[Attention.vibrate](https://developer.garmin.com/connect-iq/api-docs/Toybox/Attention.html#vibrate-instance_function) documents one to eight profiles and fixed Forerunner duty cycle with no vibration-pattern support. Each timer callback sends one profile at 100 duty cycle; there is no multi-profile on/off sequence. This does not imply physical strength is configurable.

[VibeProfile](https://developer.garmin.com/connect-iq/api-docs/Toybox/Attention/VibeProfile.html) documents duration in milliseconds without a numeric min/max in the reviewed page. 80/250/600 ms are experimental values. Compiler acceptance and simulator execution cannot prove actual motor pulse duration or perceptual gentleness.

## Bounded timing and cancellation

One repeating 100 ms timer drives elapsed-time deadlines from System.getTimer. [Timer](https://developer.garmin.com/connect-iq/api-docs/Toybox/Timer/Timer.html) documents skipped missed callbacks and device-dependent timer limits (default minimum 50 ms). No queued catch-up burst is emitted. Stage is derived from elapsed time. Single tests end after six seconds and the ramp after thirty; a delayed callback checks completion before emitting vibration.

Cancellation first clears the running guard, then stops the timer. onHide and AppBase.onStop use the same cleanup. An already-issued pulse may finish; no documented stop-vibration API was found. Sending a zero-duty profile would be misleading on a fixed-duty device. Returning to the app stays idle.

## Overnight alarm remains an open research question

[Attention](https://developer.garmin.com/connect-iq/api-docs/Toybox/Attention.html) does not list background service context. [Background services](https://developer.garmin.com/connect-iq/articles/core-topics/Backgrounding.html) have a 30-second lifetime and temporal events no more frequent than five minutes. These cannot directly provide our minute-by-minute vibration sequence.

[Entry points](https://developer.garmin.com/connect-iq/articles/user-experience-guidelines/Entry_Points.html) describe activity-list apps remaining active until the user backs out. That general lifecycle statement does not validate unattended overnight timers, interruption handling, sleep tracking, screen/DND behavior, or power consumption on this particular firmware. Do not turn it into an overnight reliability claim.

## Local tooling and distribution

Initial workspace was empty with no AGENTS.md in the project/ancestor paths inspected, and no Git repository. No existing work was changed. This Mac is Apple Silicon with VS Code installed. Java was only a system stub; SDK, device support, and Monkey C extension were absent.

Installed Java 17.0.21.1 through Homebrew, SDK Manager 1.0.16, and Garmin Monkey C VS Code extension 1.1.3. The extension's own README requires SDK >=4.0.6. The user activated SDK 9.3.0 during setup; the real compiler starts with Java 17. The fr265 device definition is installed; debug, test and release builds succeeded without final warnings. All four native behavior tests passed in Garmin’s simulator. Computer Use permission is unavailable. Build evidence belongs in hardware-testing.md once compilation runs. The [official compatible-device table](https://developer.garmin.com/connect-iq/compatible-devices/) lists the 265 as API 5.2, 416×416 AMOLED.

Private development keys and binaries stay ignored. No publication/push is authorized. [Garmin's PRG sideload instructions](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/) plus [265 MTP support](https://support.garmin.com/en-US/?faq=CZqibgTHMb0dAYEaj2UiU7) imply an MTP transfer client is needed on Mac. [OpenMTP's maintainer](https://openmtp.ganeshrvel.com/) documents Mac/Garmin support and recommends closing competing USB clients. The user subsequently connected through OpenMTP and confirmed that the app works on the actual 265.

## Alarm milestone feasibility review — 2026-11-18

The user requested wake-time selection and escalation until cancelled. The documented experimental route is a foreground watch app launched from the activity list, left open while armed. Exiting/hiding cancels; no claim is made that sleep mode, system interruptions, or overnight power behavior preserve it. A background service cannot directly vibrate, and [requestApplicationWake](https://developer.garmin.com/connect-iq/api-docs/Toybox/Background.html#requestApplicationWake-instance_function) displays a confirmation dialog requiring user acceptance rather than silently starting an alarm. DeviceSettings exposes an alarm count, not a documented built-in alarm creation API.

Before implementing the foreground experiment, the user was asked whether leaving the app open is acceptable and whether the short taps/ramp felt useful. Suggested next validation: wake time a few minutes ahead, then a longer idle test with normal screen timeout, followed by DND/sleep/interruption checks and battery measurement. Native backup alarm remains necessary until reliability is established.

## Foreground alarm implementation authorized — 2026-11-18

The user confirmed the short taps and ramp felt fine and asked to start building while considering smarter alternatives. Implemented a separate AlarmEngine for deterministic deadline tests and an AlarmView as the entry screen; the original lab remains accessible. All pulse requests still use one fixed-duty profile. Three equal ramp stages spread over 1–5 minutes, with a ten-minute ring cap and five-minute snooze. Settings persist, armed state does not. Leaving/hiding cancels. Waiting redraws once per minute with one 1-second deadline timer, without forcing backlight on. Clock/timezone changes cancel rather than claiming DST-safe operation. Additional battery drain remains unknown and must be compared to a baseline. See docs/alarm-experiment.md for reviewed alternatives and sources.

## Simpler alarm controls and round-screen layout — 2026-11-19

User reported text crossing the display borders and requested smaller text, less clutter, simpler controls, and five-minute time increments. Replaced the four-step editor with one time selector: UP/DOWN moves five minutes with midnight wrap, START arms immediately, BACK exits while idle. Ramp duration and lab moved to a native options menu (hold UP). Added a button-controlled day slider, smaller fonts, fewer lines, greater edge margins, and text width checks against the round-display chord. Existing saved minutes round down to five-minute boundaries. No touch-drag slider is claimed. Timing, vibration, cancellation, and battery behavior remain unchanged.

## Touch time selection — 2026-11-19

User requested touchscreen sliders. Replaced the day indicator (288 slots too dense for a finger) with separate hour (24 positions) and five-minute (12 positions) rails. Tap/drag maps to the nearest position; drags clamp to rail ends and retain the starting rail. Touch outside the rails is consumed without arming or changing the alarm. START remains the explicit arm/stop action; button adjustments remain available when touch is disabled in watch settings. Touch cannot edit armed/snoozed/ringing alarms or a hidden view. Reviewed official InputDelegate.onDrag and DragEvent APIs, which list Forerunner 265 support (API 3.3+). Hardware gesture delivery remains to be tested.

## More frequent gentle opening — 2026-11-19

User requested gentle but more frequent opening vibrations followed by escalation. Kept the hardware-approved brief 80 ms starting pulse; shortened alarm onset intervals from 10/5/2 seconds to 5/3/2 seconds across the existing three stages. Durations remain 80/250/600 ms and ramp length remains configurable. No stronger physical motor setting is claimed. Centralized alarm spacing constants alongside pulse lengths in source/LabPlan.mc; the original lab keeps its timing. Greater vibration frequency may increase ringing energy use; no battery estimate is established.

## Three gentle taps per set — 2026-11-19

User replaced the continuous-vibration idea with three short taps inside a roughly three-second set, with longer taps in later sets/stages. Implemented repeated three-tap sets per ramp stage: onset spacing 1 second, pulse lengths 80/180/350 ms, and waits of 5/4/3 seconds from each third-tap onset to the next set. Each stage still occupies one third of the configured ramp, and final-stage sets continue until stopped or the ten-minute limit. Late callbacks emit one tap without a catch-up burst. Stage changes and snooze reset the set counter. No physical power adjustment is possible; all new values are hardware-test hypotheses in LabPlan. The lab remains unchanged.

## Reliability review and documentation — 2026-11-20

Preserve the battery end snapshot once stopped: idle menu navigation/hide/exit must not silently include unrelated later battery drain. Give error/cancellation text priority over battery readout. Derive active displayed time from the engine deadline so snooze shows its actual due time; show today/tomorrow when armed. Catch settings read/save failures, retaining validated defaults on failed read and disarming on failed save when arming. Added overridable clock, battery and motor boundaries to test production-view behavior without hardware pulses. Declared min API 3.3 because drag events require it. Twelve native simulator tests pass; no new hardware reliability claim follows from that. README is the public-facing entry point, with setup and source architecture in separate guides and actual evidence retained in hardware-testing.md.

## Button direction preference — 2026-11-20

User requested UP to add five minutes and DOWN to subtract five minutes. Reversed only the alarm time-adjustment mapping; lab navigation and ringing snooze behavior remain the same. Regression checks cover UP wrapping 23:55 to 00:00 and DOWN wrapping back.
