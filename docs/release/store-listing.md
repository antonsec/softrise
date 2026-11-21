# Connect IQ listing draft — SoftRise

Listing copy for **0.1.0-rc.2**, a free compatibility update for the Forerunner 265 and 265S.

## App name

SoftRise

## Short description

A gentler start: three-tap vibration sets that gradually become longer and more frequent. For Forerunner 265. Keep SoftRise open while the alarm is set.

## Full description

Wake up with a gentler pattern on your Garmin Forerunner 265.

SoftRise begins with three brief taps, then gradually uses longer taps and shorter pauses between sets. Choose your wake time with touch sliders or physical buttons, set a 1–5 minute ramp, and tap Set alarm.

IMPORTANT: SoftRise is a foreground watch app. It must remain open while the alarm is set. Exiting or switching away cancels the alarm. Launch it from the watch's activity/app list before bed. It does not change Garmin's built-in alarms.

Features:
- Hour and minute touch sliders; five-minute time increments.
- UP adds five minutes; DOWN subtracts five minutes while editing.
- Three stages of repeating three-tap sets, with 80, 180 and 350 ms taps.
- Configurable 1–5 minute ramp.
- START or BACK stops the alarm.
- UP or DOWN while ringing snoozes for five minutes and restarts the ramp.
- Automatic stop after ten minutes of ringing.
- Saved wake-time and ramp settings; no automatic rearming after restart.
- A vibration lab for comparing pulse patterns while awake.

Forerunner vibration strength is fixed. SoftRise changes pulse duration and spacing, not the motor's physical power.

The owner has reported a calmer wake-up and no noticeable battery drop after one overnight test. This is an early personal result, not a guarantee. Additional battery consumption, sleep-tracking impact, and behavior through system interruptions are still being tested. Keep a separate backup alarm while evaluating SoftRise. If the watch time or timezone changes, check and re-set the alarm.

Supported devices: Forerunner 265 and 265S.

No account, phone companion, internet connection, subscription, or payment is required. Settings stay on the watch. The optional battery-drop display is an in-memory snapshot, not a saved battery history.

Source and documentation: https://github.com/antonsec/softrise
Support and bug reports: https://github.com/antonsec/softrise/issues
Privacy notice: docs/release/privacy.md in the source repository (use its public GitHub URL after publishing that file).

## What's new — initial candidate

First release candidate: time sliders, rounded Set alarm action, three-tap gradual ramp, stop/snooze, local settings and vibration lab. This candidate has not yet been approved or released on the Connect IQ Store.

## Reviewer notes (not listing copy)

Launch from the activity list. Set the next five-minute time slot using sliders or buttons, then tap Set alarm. Leave the app open and allow the display to time out normally. UP/DOWN during ringing snoozes; START/BACK cancels. Hold UP while idle for ramp settings and the vibration lab. The lab's compressed ramp is useful for checking motor requests without waiting for an alarm.

The manifest targets fr265 and fr265s and requests no permissions. No background service is included. The app does not keep the backlight on or record an activity. Known limitations are intentionally prominent; approval is not assumed.
