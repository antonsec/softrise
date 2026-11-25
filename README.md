# SoftRise

![SoftRise — A gentler start.](assets/brand/softrise-wordmark.png)

A gradual vibration alarm experiment for the **Garmin Forerunner 265 and 265S**.

SoftRise started with a personal problem: the normal watch alarm felt abrupt. Instead of trying to change the motor's fixed strength, it starts with brief taps and gradually makes them longer and more frequent.

**Status: hardware-tested personal prototype.** The owner reported one overnight use that helped them wake “a lot calmer.” That is one subjective result, not a reliability study. Battery cost, sleep-tracking impact, and behavior across interruptions still need measurement.

## The important limitation

**SoftRise must stay open while armed. Leaving or hiding the app cancels the alarm.** It is a separate Connect IQ app and does not modify Garmin's built-in alarms. Letting the screen time out normally is part of the hardware test; the app never forces the display on. Keep an independent backup alarm while testing.

The current upload candidate is **0.1.0-rc.3** for both models. The 265S awaits physical watch validation.

## Use it

1. Open SoftRise from the watch's activity/app list.
2. Tap or drag **HOUR** and **MINUTE**. Minutes snap to five-minute steps. Physical **UP** adds five minutes; **DOWN** subtracts five minutes.
3. Tap the rounded **Set alarm** button or press **START** to arm. The screen shows the next occurrence of the time and whether it is today or tomorrow. A selected minute already reached schedules tomorrow.
4. Leave SoftRise open. **START or BACK** stops/disarms; either UP or DOWN while ringing snoozes five minutes and restarts the ramp afterward.

**Hold UP while idle** for **Wake pattern** and **Ramp options** (1–5 minutes). In Wake pattern, tap a preset in the list, or highlight it with UP/DOWN and press START. Tap **Test** to feel two opening sets with their normal pause. Tap **Stop** or press BACK to end the preview. Select **Save** to keep the preset. BACK exits while idle. Settings are remembered; an armed alarm is never restored automatically after restart. Touch editing is disabled while armed.

## How the ramp feels

The ramp starts at the selected wake time. Taps within a set start one second apart. The interval runs from the start of the last tap to the start of the next set.

| Preset | Taps per set | Tap length by stage | Interval by stage |
| --- | --- | --- | --- |
| Gentle | 3 | 50 / 75 / 110 ms | 6 / 5 / 4 seconds |
| Steady (default) | 3 | 80 / 180 / 350 ms | 5 / 4 / 3 seconds |
| Slow pulse | 2 | 450 / 650 / 850 ms | 8 / 7 / 6 seconds |

Stages each occupy one third of the configured ramp; after the ramp ends and the current set finishes, the next set starts Wake up mode. All presets then use three 200 ms taps one second apart, with four seconds from the third tap onset to the next set. Ringing ends after ten minutes in total. Snooze waits five minutes and starts a fresh ramp. Delayed callbacks never replay a burst of missed taps.

Forerunners have [fixed vibration duty cycle](https://developer.garmin.com/connect-iq/api-docs/Toybox/Attention.html#vibrate-instance_function). These values change duration and spacing, not physical motor power. Their comfort and timing must be checked on the actual watch. Experimental parameters live in [LabPlan.mc](source/LabPlan.mc).

## Install on a Mac

Release-candidate package and store-copy preparation are tracked in [the release checklist](docs/release/checklist.md).

For building from source, follow [the development guide](docs/development.md).

1. Build the 265 with `bash scripts/build.sh --device` or the 265S with `bash scripts/build.sh --device fr265s`.
2. Connect the watch with a data-capable USB cable and open [OpenMTP](https://openmtp.ganeshrvel.com/). Quit competing MTP clients such as Garmin Express.
3. Copy the matching file (`bin/SoftRise.prg` for 265 or `bin/SoftRise-fr265s.prg` for 265S) into the watch's **GARMIN/APPS** folder. The 265 uses MTP and usually will not appear as a Finder disk.
4. Wait for transfer completion, disconnect, then open SoftRise on the watch. Installed files may be renamed by the watch; do not delete unfamiliar PRGs.

Garmin documents [PRG sideloading](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/). The owner has successfully used this transfer route. Public Connect IQ Store distribution requires [Garmin review](https://developer.garmin.com/connect-iq/submit-an-app/).

## Battery and reliability

After stopping, SoftRise shows the battery percentage-point drop since arming. It is an in-memory snapshot, **not a saved battery log or a measurement of app-only energy**. Error/cancellation messages take priority over the reading. Restarting loses it; charging can make the difference negative.

No additional percentage-per-night estimate is established. The app uses one timer while armed, redraws the waiting screen once a minute, and requests no GPS, activity recording, or network access. Compare several SoftRise nights against similar baseline nights before drawing battery conclusions.

Detected clock jumps or timezone/DST changes disarm the alarm and ask you to rearm. Do not rely on automatic handling across travel or clock changes. System/firmware behavior can still interrupt the foreground app.

## Validation

The reviewed build compiles without warnings with SDK 9.3.0; all **16 automated tests passed on each watch simulator**. Tests cover scheduling, three-tap sets, snooze, cancellation, clock changes, touch mapping, and battery/error reporting. They do not replace hardware tests. The owner has reported one positive overnight outcome; exact build/settings and battery/sleep data were not recorded.

## Project documentation

- [Development](docs/development.md): setup, builds, simulator tests and sideloading.
- [Architecture](docs/architecture.md): state flow and responsibilities in the code.
- [Hardware testing](docs/hardware-testing.md): actual evidence and checks still pending.
- [Alarm experiment](docs/alarm-experiment.md): battery procedure and reviewed platform alternatives.
- [Decisions](docs/decisions.md): dated engineering choices and their evidence.
- [Changelog](CHANGELOG.md): changes to the current unreleased prototype.


## License

Source code is available under the [MIT License](LICENSE). Garmin’s SDK and tools are separate and subject to Garmin’s terms. This project is independent of Garmin.
