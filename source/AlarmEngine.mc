// Seconds throughout. All values are hypotheses carried over from the lab.
module AlarmPlan {
    const MAX_RING_SECONDS = 600;
    const SNOOZE_SECONDS = 300;
    function nextDelay(hour, minute, localSeconds) {
        var delay = hour * 3600 + minute * 60 - localSeconds;
        return delay <= 0 ? delay + 86400 : delay;
    }
    function stage(age, rampMinutes) {
        return age >= rampMinutes * 60 ? 2 : (age * 3 / (rampMinutes * 60));
    }
    function lengthMs(stageIndex) {
        return [LabPlan.ALARM_FIRST_MS, LabPlan.ALARM_SECOND_MS, LabPlan.ALARM_THIRD_MS][stageIndex];
    }
    function setPause(stageIndex) {
        return [LabPlan.ALARM_FIRST_PAUSE, LabPlan.ALARM_SECOND_PAUSE, LabPlan.ALARM_THIRD_PAUSE][stageIndex];
    }
}

class AlarmEngine {
    var state = "idle";
    var due = 0;
    var ringAt = 0;
    var nextPulse = 0;
    var stageIndex = 0;
    var rampMinutes = 3;
    var pulses = 0;
    var setTaps = 0;
    function initialize() {}
    function arm(now, delay, ramp) {
        rampMinutes = ramp;
        due = now + delay;
        state = "armed";
        pulses = 0;
        setTaps = 0;
        stageIndex = 0;
    }
    function cancel() { state = "idle"; }
    function snooze(now) {
        if (!state.equals("ringing")) { return; }
        due = now + AlarmPlan.SNOOZE_SECONDS;
        state = "snoozed";
        setTaps = 0;
        stageIndex = 0;
    }
    // Returns requested pulse length, or zero. No motor or timer in this model.
    function tick(now) {
        if (state.equals("armed") || state.equals("snoozed")) {
            if (now < due) { return 0; }
            // A delayed callback must not restart a stale alarm at stage one.
            ringAt = due;
            nextPulse = now;
            setTaps = 0;
            state = "ringing";
        }
        if (!state.equals("ringing")) { return 0; }
        var age = now - ringAt;
        if (age < 0) { cancel(); return 0; }
        if (age >= AlarmPlan.MAX_RING_SECONDS) {
            state = "complete";
            return 0;
        }
        var nextStage = AlarmPlan.stage(age, rampMinutes);
        if (nextStage != stageIndex) { stageIndex = nextStage; nextPulse = now; setTaps = 0; }
        if (now < nextPulse) { return 0; }
        setTaps += 1;
        if (setTaps == LabPlan.ALARM_TAPS_PER_SET) {
            setTaps = 0;
            nextPulse = now + AlarmPlan.setPause(stageIndex);
        } else {
            nextPulse = now + LabPlan.ALARM_TAP_SPACING;
        }
        pulses += 1;
        return AlarmPlan.lengthMs(stageIndex);
    }
}
