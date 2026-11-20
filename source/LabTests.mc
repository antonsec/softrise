import Toybox.Test;
import Toybox.Lang;

// Test clock and motor boundary only; execute the production tick/cleanup code.
(:test)
class ClockedLab extends LabView {
    var clock = 0;
    var emitted as Lang.Array<Lang.Number> = [];
    function initialize(mode) {
        LabView.initialize();
        selection = mode;
        stageIndex = LabPlan.stage(mode, 0);
        visible = true;
        running = true;
        startedAt = 0;
        nextPulseAt = 0;
    }
    function nowMs() { return clock; }
    function emitPulse(lengthMs) { emitted.add(lengthMs); }
    function advance(time) { clock = time; tick(); }
}

(:test)
function rampDeadlines(logger) {
    var lab = new ClockedLab(3);
    lab.advance(0);
    Test.assertEqual(lab.emitted.size(), 1);
    Test.assertEqual(lab.emitted[0], 80);
    lab.advance(9999);
    Test.assertEqual(lab.stageIndex, 0);
    lab.advance(10000);
    Test.assertEqual(lab.stageIndex, 1);
    Test.assertEqual(lab.emitted[2], 250);
    lab.advance(20000);
    Test.assertEqual(lab.stageIndex, 2);
    Test.assertEqual(lab.emitted[3], 600);
    lab.advance(30000);
    Test.assertEqual(lab.running, false);
    Test.assertEqual(lab.status, "Complete");
    Test.assertEqual(lab.emitted.size(), 4);
    lab.advance(60000);
    Test.assertEqual(lab.emitted.size(), 4);
    return true;
}

(:test)
function cancellationAndHide(logger) {
    var lab = new ClockedLab(3);
    lab.advance(0);
    lab.stop("Stopped");
    lab.advance(20000);
    Test.assertEqual(lab.emitted.size(), 1);
    lab.stop("Stopped");
    lab.onShow();
    lab.advance(25000);
    Test.assertEqual(lab.running, false);
    Test.assertEqual(lab.emitted.size(), 1);

    lab = new ClockedLab(3);
    lab.advance(0);
    lab.onHide();
    lab.advance(10000);
    lab.onShow();
    lab.advance(20000);
    Test.assertEqual(lab.running, false);
    Test.assertEqual(lab.emitted.size(), 1);
    return true;
}

(:test)
function singleAndDelayedCallbacks(logger) {
    for (var mode = 0; mode < 3; mode += 1) {
        var lab = new ClockedLab(mode);
        lab.advance(0);
        lab.advance(100);
        Test.assertEqual(lab.emitted.size(), 1);
        lab.advance(2000);
        lab.advance(4000);
        lab.advance(6000);
        Test.assertEqual(lab.emitted.size(), 3);
        Test.assertEqual(lab.running, false);
    }
    var delayed = new ClockedLab(3);
    delayed.advance(0);
    delayed.advance(25000);
    Test.assertEqual(delayed.emitted.size(), 2);
    Test.assertEqual(delayed.emitted[1], 600);
    delayed.advance(35000);
    Test.assertEqual(delayed.emitted.size(), 2);
    Test.assertEqual(delayed.running, false);
    return true;
}

(:test)
function buttonsAndAppStop(logger) {
    var lab = new ClockedLab(0);
    var input = new LabDelegate(lab);
    input.onNextPage();
    Test.assertEqual(lab.selection, 0); // Locked while running.
    Test.assertEqual(input.onBack(), true);
    Test.assertEqual(lab.running, false);
    Test.assertEqual(input.onBack(), false); // Delegate exit to the system.
    input.onPreviousPage();
    Test.assertEqual(lab.selection, 3);
    input.onNextPage();
    Test.assertEqual(lab.selection, 0);

    lab = new ClockedLab(3);
    lab.advance(0);
    var app = new SoftRiseApp();
    app.lab = lab;
    app.onStop(null);
    lab.advance(20000);
    Test.assertEqual(lab.running, false);
    Test.assertEqual(lab.emitted.size(), 1);
    return true;
}
