# Release candidate checklist

Current upload candidate: `bin/SoftRise-0.1.0-rc.3.iq` for Forerunner 265 and 265S. Use **Upload New Version** on the existing SoftRise listing. Both simulator suites passed 16 tests. Physical validation of the new patterns is pending.

Initial **0.1.0-rc.1** release checklist, kept for reference. The follow-up **0.1.0-rc.2** package includes the 265 and 265S. See [validation notes](../hardware-testing.md) for the 265S status.

## Prepared locally

- [x] Manifest restricted to Forerunner 265 (`fr265`).
- [x] Stable application ID and existing private signing key retained.
- [x] Store listing draft and privacy/support text written.
- [x] New vector icon/wordmark source prepared.
- [x] Signed store package exported to ignored bin/SoftRise-0.1.0-rc.1.iq.

- [x] Owner supplied hardware photos of app list, time editor, armed screen and first ringing stage; originals remain outside the repo.

## Before submission

- [x] Owner confirmed the transparent on-watch icon looks correct.
- [ ] Approve final store icon and listing wording.
- [x] Confirm the final rendered store icon is 500×500 sRGB and opaque.
- [ ] Capture actual app screenshots: time sliders/Set alarm, armed screen, and ringing/snooze. Do not use mockups as evidence of actual screens.
- [ ] Sideload the exact release candidate and recheck touch, physical buttons, stop, snooze, completion and normal display timeout.
- [ ] Record firmware, chosen ramp, start/end battery percentages and elapsed time for repeat nights and baseline comparison.
- [ ] Check whether sleep tracking remains normal and what happens under DND/sleep mode and system interruptions.
- [ ] Publish the final privacy notice at an accessible URL and supply it to the portal. Draft local text alone is not a live public policy.
- [ ] Verify developer profile/support details and accept any applicable Garmin agreements yourself.
- [ ] Enter the version in the format accepted by the portal and upload the candidate .iq (not the sideload .prg).
- [ ] Review listing and assets, then explicitly authorize submission. No approval or review turnaround is promised.

## Build and artifact handling

`bash scripts/build.sh --package` exports the IQ; `bash scripts/build.sh --device` builds the sideload PRG. VERSION controls the candidate filename and documentation label, not a claim about the store's assigned version. The compiler exports only the products listed in the manifest. Preserve the signing key privately for future updates.

Keep bin/, .local/, private keys and SDK files out of Git. Store only source brand assets, listing text and release notes in version control. A GitHub tag/release is a separate publication action and has not been created for this candidate.

Official guidance: [submission](https://developer.garmin.com/connect-iq/submit-an-app/), [brand assets](https://developer.garmin.com/brand-guidelines/connect-iq/), [review guidelines](https://developer.garmin.com/connect-iq/articles/app-review-guidelines/Overview.html).
