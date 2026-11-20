import Toybox.Test;

(:test)
function alarmScheduling(logger) {
    Test.assertEqual(AlarmPlan.nextDelay(7, 0, 6*3600+59*60), 60);
    Test.assertEqual(AlarmPlan.nextDelay(0, 1, 23*3600+59*60), 120);
    Test.assertEqual(AlarmPlan.nextDelay(7, 0, 7*3600), 86400);
    var e = new AlarmEngine();
    e.arm(100, 60, 3);
    Test.assertEqual(e.tick(159), 0);
    Test.assertEqual(e.state, "armed");
    Test.assertEqual(e.tick(160), 80);
    Test.assertEqual(e.tick(161), 80);
    Test.assertEqual(e.tick(162), 80);
    Test.assertEqual(e.pulses, 3);
    Test.assertEqual(e.tick(163), 0);
    Test.assertEqual(e.tick(166), 0);
    Test.assertEqual(e.tick(167), 80);
    Test.assertEqual(e.tick(220), 180);
    Test.assertEqual(e.tick(221), 180);
    Test.assertEqual(e.tick(222), 180);
    Test.assertEqual(e.tick(225), 0);
    Test.assertEqual(e.tick(226), 180);
    Test.assertEqual(e.tick(280), 350);
    Test.assertEqual(e.tick(281), 350);
    Test.assertEqual(e.tick(282), 350);
    Test.assertEqual(e.tick(284), 0);
    Test.assertEqual(e.tick(285), 350);
    Test.assertEqual(e.tick(760), 0);
    Test.assertEqual(e.state, "complete");
    return true;
}

(:test)
function alarmSnoozeAndCancel(logger) {
    var e = new AlarmEngine();
    e.arm(0, 60, 3);
    e.tick(200);
    e.snooze(201);
    Test.assertEqual(e.due, 501);
    Test.assertEqual(e.tick(500), 0);
    Test.assertEqual(e.tick(501), 80);
    Test.assertEqual(e.stageIndex, 0);
    e.cancel();
    Test.assertEqual(e.tick(1000), 0);
    Test.assertEqual(e.state, "idle");
    e.arm(1000, 60, 1);
    Test.assertEqual(e.tick(2000), 0); // Stale alarm is expired, no pulse.
    Test.assertEqual(e.state, "complete");
    e.arm(3000, 60, 5);
    e.cancel();
    Test.assertEqual(e.tick(3060), 0);
    return true;
}

(:test)
function alarmRampAndDelayedTick(logger) {
    for (var ramp = 1; ramp <= 5; ramp += 1) {
        var e = new AlarmEngine();
        e.arm(0, 1, ramp);
        Test.assertEqual(e.tick(1), 80);
        var third = ramp * 20;
        Test.assertEqual(e.tick(1+third), 180);
        Test.assertEqual(e.tick(1+third*2), 350);
        var before = e.pulses;
        e.tick(1+ramp*60+20);
        Test.assertEqual(e.pulses, before+1); // No burst after skipped time.
        Test.assertEqual(e.tick(601), 0);
    }
    return true;
}

(:test)
function alarmViewLifecycle(logger) {
    var view = new AlarmView();
    view.engine.arm(0, 100, 3);
    view.onHide();
    view.onShow();
    Test.assertEqual(view.active(), false);
    var input = new AlarmDelegate(view);
    view.hour = 23; view.minute = 55;
    input.onPreviousPage(); // UP increases by five minutes, wrapping midnight.
    Test.assertEqual(view.hour, 0);
    Test.assertEqual(view.minute, 0);
    input.onNextPage(); // DOWN decreases by five minutes.
    Test.assertEqual(view.hour, 23);
    Test.assertEqual(view.minute, 55);
    view.engine.arm(0, 100, 3);
    Test.assertEqual(input.onBack(), true);
    Test.assertEqual(view.active(), false);
    var app = new SoftRiseApp();
    app.alarm = view;
    view.engine.arm(0, 100, 3);
    app.onStop(null);
    Test.assertEqual(view.active(), false);
    return true;
}


(:test)
function touchTimeSliders(logger) {
    var v = new AlarmView();
    v.onShow();
    Test.assertEqual(v.sliderAt(208, 216), 0);
    Test.assertEqual(v.sliderAt(208, 283), 1);
    Test.assertEqual(v.sliderAt(208, 340), -1);
    v.setSlider(0, 83); Test.assertEqual(v.hour, 0);
    v.setSlider(0, 333); Test.assertEqual(v.hour, 23);
    v.setSlider(1, 83); Test.assertEqual(v.minute, 0);
    v.setSlider(1, 333); Test.assertEqual(v.minute, 55);
    v.setSlider(1, 208); Test.assertEqual(v.minute % 5, 0);
    v.setSlider(0, -100); Test.assertEqual(v.hour, 0);
    v.engine.arm(0, 60, 3);
    v.setSlider(0, 333); Test.assertEqual(v.hour, 0);
    Test.assertEqual(v.sliderAt(208, 216), -1);
    v.onHide();
    v.setSlider(0, 333); Test.assertEqual(v.hour, 0);
    return true;
}


(:test)
class ControlledAlarmView extends AlarmView {
    var wall = 100;
    var mono = 0;
    var charge = 80.0;
    var offset = 0;
    var emitted as Toybox.Lang.Array<Toybox.Lang.Number> = [];
    function initialize() { AlarmView.initialize(); }
    function nowSeconds() { return wall; }
    function monotonicMs() { return mono; }
    function batteryPercent() { return charge; }
    function offsetAt(now) { return offset; }
    function emitPulse(length) { emitted.add(length); }
    function prepare() {
        onShow(); engine.arm(wall, 2, 3);
        lastWall = wall; lastMono = mono; zoneOffset = offset;
        armedAt = wall; batteryStart = charge;
    }
}

(:test)
function alarmAdapterAndBattery(logger) {
    var v = new ControlledAlarmView(); v.prepare();
    v.wall = 102; v.mono = 2000; v.tick();
    Test.assertEqual(v.emitted.size(), 1);
    v.charge = 79.0; v.stop("Stopped");
    v.charge = 75.0; v.onHide(); v.onShow();
    Test.assertEqual(v.batteryEnd, 79.0);
    Test.assertEqual(v.idleDetail(), "Used 1.0%");
    v.stop("Vibration error");
    Test.assertEqual(v.idleDetail(), "Vibration error");
    v.onHide(); v.onShow();
    Test.assertEqual(v.idleDetail(), "Vibration error");
    v.tick(); Test.assertEqual(v.emitted.size(), 1);
    return true;
}

(:test)
function clockChangeDisarms(logger) {
    var v = new ControlledAlarmView(); v.prepare();
    v.wall = 120; v.mono = 1000; v.tick();
    Test.assertEqual(v.active(), false);
    Test.assertEqual(v.message, "Time changed: rearm");
    Test.assertEqual(v.emitted.size(), 0);
    v = new ControlledAlarmView(); v.prepare();
    v.offset = 3600; v.wall = 101; v.mono = 1000; v.tick();
    Test.assertEqual(v.active(), false);
    Test.assertEqual(v.emitted.size(), 0);
    return true;
}

(:test)
function snoozeShowsNewTime(logger) {
    var v = new ControlledAlarmView(); v.prepare();
    v.wall = 102; v.mono = 2000; v.tick();
    v.change(1);
    Test.assertEqual(v.engine.state, "snoozed");
    var due = Toybox.Time.Gregorian.info(new Toybox.Time.Moment(402), Toybox.Time.FORMAT_SHORT);
    Test.assertEqual(v.displayTime(), due.hour.format("%02d") + ":" + due.min.format("%02d"));
    return true;
}
