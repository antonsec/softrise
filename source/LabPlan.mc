// Experimental values, not perceptual guarantees or documented device limits.
module LabPlan {
    const SHORT_MS = 80;
    const MEDIUM_MS = 250;
    const LONG_MS = 600;
    // Alarm: three taps one second apart, then a pause before the next set.
    const ALARM_FIRST_MS = 80;
    const ALARM_SECOND_MS = 180;
    const ALARM_THIRD_MS = 350;
    const ALARM_TAPS_PER_SET = 3;
    const ALARM_TAP_SPACING = 1;
    const ALARM_FIRST_PAUSE = 5;
    const ALARM_SECOND_PAUSE = 4;
    const ALARM_THIRD_PAUSE = 3;
    const SINGLE_END_MS = 6000;
    const RAMP_END_MS = 30000;

    function nameOf(selection) {
        return ["Short taps", "Medium taps", "Long taps", "Gradual ramp"][selection];
    }
    function duration(selection) {
        return selection == 3 ? RAMP_END_MS : SINGLE_END_MS;
    }
    function stage(selection, elapsed) {
        return selection == 3 ? (elapsed / 10000) : selection;
    }
    function pulseMs(stageIndex) {
        return [SHORT_MS, MEDIUM_MS, LONG_MS][stageIndex];
    }
    // Onset-to-onset intervals. Never enqueue catch-up pulses after a delay.
    function intervalMs(stageIndex) {
        return [3000, 2000, 1000][stageIndex];
    }
}
