# Development guide

SoftRise is a native Monkey C Connect IQ watch app targeting only **fr265**. Start with [the README](../README.md) for behavior and limitations. [Architecture](architecture.md) explains the source layout.

Validated toolchain: Connect IQ SDK 9.3.0, Java 17, Garmin Monkey C VS Code extension 1.1.3. Garmin account/login and SDK agreement steps are completed by the developer.

## Toolchain on Mac

1. Install Java and SDK Manager: `brew install openjdk@17` and `brew install --cask connectiq-sdk-manager`.
2. Open SDK Manager from Applications. Complete Garmin login and any developer agreement yourself. Install the latest stable Connect IQ SDK, select it as active, and download **Forerunner 265** device support.
3. Install Garmin's official **Monkey C** VS Code extension (`garmin.monkey-c`). Open this folder and run **Monkey C: Verify Installation**.
4. If VS Code cannot find Java, set **Monkey C: Java Path** to the JDK home from `brew --prefix openjdk@17` plus `/libexec/openjdk.jdk/Contents/Home`. The shell build resolves this automatically; no system-wide Java symlink is needed.
5. Run `bash scripts/create-key.sh`. It creates a private 4096-bit signing key inside ignored `.local/`. Keep both files private and backed up. Point VS Code's **Monkey C: Developer Key Path** to `.local/developer_key.der` using an absolute local path in your own settings.

Official [setup guide](https://developer.garmin.com/connect-iq/connect-iq-basics/getting-started/) and [SDK downloads](https://developer.garmin.com/connect-iq/sdk/). The installed Garmin extension requires SDK 4.0.6 or later. Java 17 successfully compiled this project with SDK 9.3.0.

## Build and simulator

```sh
bash scripts/build.sh             # debug build: bin/SoftRise.prg
bash scripts/build.sh --device    # release device build: bin/SoftRise.prg
bash scripts/build.sh --test      # test-enabled build: bin/SoftRise-tests.prg
```

The script reads SDK Manager's active SDK. `CIQ_SDK_HOME` and `CIQ_DEVELOPER_KEY` can override local locations without changing tracked files. The only product target is `fr265`. The updated device build uses the same app ID: copy `bin/SoftRise.prg` over the existing file in GARMIN/APPS. `bin/SoftRise-lab.prg` is a local backup of the original lab build, not a second app to install alongside it.

To run interactively, open a `.mc` source file in VS Code, choose **Run Without Debugging**, and select **Forerunner 265**. Verify each button, stage transition, automatic completion, cancellation, and exit using the checklist. The simulator cannot establish physical vibration feel, watch firmware timing, or overnight reliability.

## Sideload from this Mac

The 265 uses [MTP](https://support.garmin.com/en-US/?faq=CZqibgTHMb0dAYEaj2UiU7), so it normally **does not appear as a Finder disk**. Use an MTP client such as [OpenMTP](https://openmtp.ganeshrvel.com/), whose maintainer lists Garmin support. The owner successfully used OpenMTP to sideload and run SoftRise on their 265.

1. Build with `bash scripts/build.sh --device` (or VS Code's **Monkey C: Build for Device**, target Forerunner 265).
2. Install OpenMTP if needed: `brew install --cask openmtp`.
3. Quit Garmin Express and other USB/MTP clients so they do not compete for the device.
4. Connect the watch directly with a data-capable Garmin USB cable. If prompted for USB mode, choose **MTP / file transfer**, not charging-only mode.
5. Open OpenMTP, refresh the device pane, and open the watch's internal storage, then `GARMIN/APPS`.
6. Copy **only `bin/SoftRise.prg`** into `GARMIN/APPS`. Wait for the transfer to finish, disconnect cleanly, then open SoftRise from the watch's activity/app list (START from the watch face; add it to the list if needed).
7. If there is no device pane, reconnect, verify the cable/mode, and ensure other MTP clients are closed. Do not assume a Finder `/Volumes/GARMIN` path exists.

Garmin documents copying generated PRG files to `GARMIN/APPS` in [Your First App](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/). Sideloading does not require store publication. Public distribution would require [Garmin review](https://developer.garmin.com/connect-iq/submit-an-app/).


## Automated tests

Build with `bash scripts/build.sh --test`. Start the SDK simulator, then run:

```sh
export JAVA_HOME="$(brew --prefix openjdk@17)/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
# Set CIQ_SDK_HOME to your active SDK directory, or read SDK Manager's setting:
CIQ_SDK_HOME="$(cat "$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg")"
"$CIQ_SDK_HOME/bin/monkeydo" bin/SoftRise-tests.prg fr265 -t
```

On this installed SDK, `monkeydo` has returned exit code 1 even when its explicit report says all tests passed. Read the complete report: every test must pass, with no failures/errors. A nonzero code by itself is not proof of a passing or failing suite. Do not suppress failure output. A future CI runner should parse and validate the explicit result rather than using `|| true`.

Tests replace time/motor/battery boundaries to exercise deadlines, grouping, cancellation, clock changes, UI state and touch coordinate mapping. They do not establish real motor feel, display timeout behavior, touch gesture delivery, or overnight power consumption. Follow [hardware testing](hardware-testing.md) after installing a changed build.

## Before sharing or publishing

- Keep `.local/`, credentials, and signing keys private. The PRG/IQ files are generated artifacts, not source.
- Keep the app manifest ID stable for updates; use the same signing key and back it up privately.
- Source is licensed under MIT; retain the copyright and license notice in redistributed copies. Garmin SDK files are not included.
- Target only hardware with actual evidence; do not add 265S based on similar naming.
- Export a store package using **Monkey C: Export Project** when ready. Garmin reviews public submissions. No upload/push/publication has been performed or authorized here.
- `.gitignore` excludes local keys, environment files, SDK-independent generated builds, and machine settings. Review the staged file list before every public push.
