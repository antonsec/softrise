# SoftRise privacy notice

Draft for release candidate 0.1.0-rc.1. Updated 2026-11-20.

SoftRise is an independent watch app for the Garmin Forerunner 265. It does not require an account and does not send app data to its developer or any server. It contains no analytics, advertising, network communication, or phone companion.

## On-watch information

SoftRise saves the selected alarm hour, minute, and ramp duration in the app's local watch storage. It uses the watch's clock and local time offset to schedule the alarm and detect time changes. It reads the device-reported battery percentage to display the difference since the alarm was set.

The active alarm state and battery readings are held in memory and are not saved as a history. Restarting the app discards them. The app does not request GPS, health sensor, or activity-recording access and does not read sleep history.

Settings remain on the watch between launches. You can overwrite them by choosing and saving new settings. Uninstalling removes the app; management of device backups or platform records is governed by Garmin's systems and policies.

## Support

Support is available through https://github.com/antonsec/softrise/issues. GitHub issues are public, so do not include private health information, passwords, signing keys, or other sensitive information. If you submit an issue, its content is processed by GitHub under GitHub's own privacy policies.

Garmin and GitHub operate their own platforms. This notice describes SoftRise's application behavior, not those platforms' data practices.
