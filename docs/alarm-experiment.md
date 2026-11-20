# Foreground alarm experiment

Authorized 2026-11-18 after the user confirmed that the short taps and ramp felt fine on the actual Forerunner 265. This is evidence of a useful tactile experiment, not an overnight reliability result.

## Operation

SoftRise opens to a single 24-hour wake-time screen. Tap or drag the separate HOUR and MINUTE sliders to choose time. Minutes snap to five-minute increments. UP/DOWN also moves the whole time in five-minute steps with hour/day wraparound. Tap the rounded Set alarm button or press START to arm immediately. Hold UP while idle for ramp-duration options (1–5 minutes) and the original vibration lab. Older saved minutes round down to the nearest five-minute boundary. The saved hour/minute/ramp survive restart; an armed alarm does not.

Leave the app open, launched from the activity list. START or BACK cancels an armed/ringing/snoozed alarm. During ringing, either UP or DOWN snoozes for five minutes, then restarts the ramp. BACK exits while idle. The selected minute already reached schedules tomorrow, not an immediate alarm.

The ramp begins at the selected time, not before it. Its three equal stages use repeating sets of three taps, one second apart (onsets at 0, 1 and 2 seconds, within a three-second window). Stage 1 uses 80 ms taps and waits 5 seconds after the third tap before the next set; stage 2 uses 180 ms taps and a 4-second wait; stage 3 uses 350 ms taps and a 3-second wait. The original vibration lab is unchanged. Default three-minute ramp changes at one and two minutes. These new durations are hypotheses needing watch feedback. At maximum stage, pulses continue until cancellation or ten minutes after ringing started. Each snooze starts a new ten-minute maximum ringing window. These are adjustable hypotheses in LabPlan, not physical intensity settings.

A hidden/exited app cancels and never automatically rearms. Wall-clock jumps over five seconds relative to the monotonic clock, or timezone/DST offset changes detected while active, cancel with “Time changed: rearm”. This intentionally does not promise DST/travel-safe scheduling. Time corrections within five seconds can shift execution. No missed pulse backlog is replayed; an alarm missed by over ten minutes expires silently.

## Battery: unknown until measured

No defensible additional percentage-per-night estimate exists yet. The app checks the deadline with one 1-second timer and redraws the waiting display once per minute. It does not force the display/backlight on, record an activity, request GPS/sensors, or communicate with a phone. These choices reduce unnecessary work but do not prove low power consumption, normal sleep tracking, or screen-timeout behavior on this firmware.

After stopping, the screen shows battery percentage-point drop since arming, including waiting, ringing and snoozing. It is a coarse device-reported difference, not incremental app energy; charging can make it negative. Record duration separately. Cancellation due to hide snapshots the reading if still armed; later idle navigation leaves a completed reading unchanged. Error/cancellation text can take priority over the battery reading; restarting loses this in-memory observation.

1. First set an alarm at the next five-minute slot while awake. Let the screen time out normally. Confirm it rings, escalates, snoozes and stops.
2. Try a 30–60 minute idle interval. Record start/end battery and elapsed time, screen behavior, firmware, DND and sleep settings. No charging during measurements.
3. Only then test overnight with a separate backup alarm. Record the same data plus whether Garmin recorded sleep normally and any system interruptions.
4. Compare to a similar baseline night with SoftRise closed, same duration and settings. Repeat both conditions. Additional drain = SoftRise-night percentage-point drop minus baseline drop; percentages are rounded and individual nights vary.

| Condition | Duration | Start % | End % | Drop (percentage points) | Screen/DND/sleep settings | Alarm fired? | Sleep recorded? |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Baseline, SoftRise closed | Pending | | | | | n/a | |
| SoftRise armed | Pending | | | | | | |

## Smarter alternatives reviewed

| Route | Finding | Consequence |
| --- | --- | --- |
| Foreground watch app | [Activity-list apps run until user backs out](https://developer.garmin.com/connect-iq/articles/user-experience-guidelines/Entry_Points.html); this is not a device-specific overnight guarantee | Current experiment; measure battery, sleep and interruption behavior |
| Background temporal event | [Background services](https://developer.garmin.com/connect-iq/articles/core-topics/Backgrounding.html) are limited to 30 s and temporal intervals no shorter than five minutes; [Attention](https://developer.garmin.com/connect-iq/api-docs/Toybox/Attention.html) does not support background context | Cannot directly generate this vibration ramp |
| Background launching foreground app | [requestApplicationWake](https://developer.garmin.com/connect-iq/api-docs/Toybox/Background.html#requestApplicationWake-instance_function) presents a user confirmation dialog | Requires the sleeping user to accept; unsuitable as a silent automatic transition |
| Custom watch face | [Low-power watch faces](https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/WatchFace.html) restrict timers; Attention does not list watch-face context | Does not provide a documented way to deliver this ramp |
| Modify native Garmin alarms | [DeviceSettings](https://developer.garmin.com/connect-iq/api-docs/Toybox/System/DeviceSettings.html) exposes alarmCount; no supported native alarm creation/pattern-control API found in reviewed documentation | Native alarm remains a separate backup, not something SoftRise controls |
| Phone notifications/companion | No implementation or claim of reliable watch vibration-pattern control; outside current scope | Do not assume it solves background vibration limitations |

If keeping the app open loses sleep tracking, drains too much battery, or misses triggers after normal interruptions, reconsider the design before calling this an everyday alarm. No documented background route found in this review preserves the requested autonomous ramp.
