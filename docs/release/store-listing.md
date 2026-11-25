# Connect IQ listing draft — SoftRise

Listing copy for **0.1.0-rc.3**, a free wake-pattern update for the Forerunner 265 and 265S.

## App name

SoftRise

## Short description

A gentler start: vibration sets that gradually become longer and more frequent. For Forerunner 265 and 265S. Keep SoftRise open while the alarm is set.

## Full description

Wake up with a gentler pattern on your Garmin Forerunner 265 or 265S.

SoftRise starts with your chosen wake pattern, then gradually uses longer taps and shorter pauses between sets. Choose your wake time with touch sliders or physical buttons, set a 1–5 minute ramp, and tap Set alarm.

IMPORTANT: SoftRise is a foreground watch app. It must remain open while the alarm is set. Exiting or switching away cancels the alarm. Launch it from the watch's activity/app list before bed. It does not change Garmin's built-in alarms.

Features:
- Hour and minute touch sliders; five-minute time increments.
- UP adds five minutes; DOWN subtracts five minutes while editing.
- Three wake patterns with a two-set preview.
- Configurable 1–5 minute ramp.
- START or BACK stops the alarm.
- UP or DOWN while ringing snoozes for five minutes and restarts the ramp.
- Automatic stop after ten minutes of ringing.
- Saved wake-time, pattern and ramp settings; no automatic rearming after restart.
- Wake up mode repeats three 200 ms taps after the ramp.

Forerunner vibration strength is fixed. SoftRise changes pulse duration and spacing, not the motor's physical power.

The owner has reported a calmer wake-up and no noticeable battery drop after one overnight test. This is an early personal result, not a guarantee. Additional battery consumption, sleep-tracking impact, and behavior through system interruptions are still being tested. Keep a separate backup alarm while evaluating SoftRise. If the watch time or timezone changes, check and re-set the alarm.

Supported devices: Forerunner 265 and 265S.

No account, phone companion, internet connection, subscription, or payment is required. Settings stay on the watch. The optional battery-drop display is an in-memory snapshot, not a saved battery history.

Source and documentation: https://github.com/antonsec/softrise
Support and bug reports: https://github.com/antonsec/softrise/issues
Privacy notice: docs/release/privacy.md in the source repository (use its public GitHub URL after publishing that file).

## What's new

Choose Gentle, Steady, or Slow pulse and test a pattern before saving it. Ramp options groups the five ramp lengths in one menu. After the ramp, Wake up mode repeats three taps until you stop or snooze, or the ten-minute ringing limit is reached.

## Reviewer notes (not listing copy)

Launch from the activity list. Set the next five-minute time slot using sliders or buttons, then tap Set alarm. Leave the app open and allow the display to time out normally. UP/DOWN during ringing snoozes; START/BACK cancels. Hold UP while idle for Wake pattern and Ramp options. Select a preset and tap Test to preview two opening sets.

The manifest targets fr265 and fr265s and requests no permissions. No background service is included. The app does not keep the backlight on or record an activity. Known limitations are intentionally prominent; approval is not assumed.
