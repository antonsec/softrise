import Toybox.Attention;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

class LabView extends WatchUi.View {
    var selection = 0;
    var running = false;
    var visible = false;
    var status = "Ready";
    var elapsed = 0;
    var stageIndex = 0;
    var startedAt = 0;
    var nextPulseAt = 0;
    var pulses = 0;
    var ticker;

    function initialize() {
        View.initialize();
        ticker = new Timer.Timer();
    }
    function nowMs() { return System.getTimer(); }
    function emitPulse(lengthMs) {
        Attention.vibrate([new Attention.VibeProfile(100, lengthMs)]);
    }
    function onShow() { visible = true; WatchUi.requestUpdate(); }
    function onHide() { visible = false; stop("Stopped"); }
    function stop(message) {
        // Guard first: even a late callback cannot emit another pulse.
        running = false;
        ticker.stop();
        status = message;
        WatchUi.requestUpdate();
        // Attention has no documented cancel API. An in-flight pulse may
        // finish (at most LONG_MS); never send a zero-duty "stop" pulse.
    }
    function choose(delta) {
        if (!running) {
            selection = (selection + delta + 4) % 4;
            elapsed = 0;
            pulses = 0;
            status = "Ready";
            WatchUi.requestUpdate();
        }
    }
    function toggle() {
        if (running) { stop("Stopped"); return; }
        if (!visible) { return; }
        if (!(Attention has :vibrate)) {
            status = "Vibration unavailable";
            WatchUi.requestUpdate();
            return;
        }
        elapsed = 0;
        pulses = 0;
        stageIndex = LabPlan.stage(selection, 0);
        startedAt = nowMs();
        nextPulseAt = 0;
        running = true;
        status = "Running";
        ticker.start(method(:tick), 100, true);
        tick();
    }
    function tick() {
        if (!running || !visible) { return; }
        elapsed = nowMs() - startedAt;
        if (elapsed < 0 || elapsed >= LabPlan.duration(selection)) {
            elapsed = LabPlan.duration(selection);
            stop("Complete");
            return;
        }
        var newStage = LabPlan.stage(selection, elapsed);
        if (newStage != stageIndex) {
            stageIndex = newStage;
            nextPulseAt = elapsed;
        }
        if (elapsed >= nextPulseAt) {
            try {
                emitPulse(LabPlan.pulseMs(stageIndex));
                pulses += 1;
                var interval = selection == 3 ? LabPlan.intervalMs(stageIndex) : 2000;
                nextPulseAt = elapsed + interval;
            } catch (e) {
                stop("Vibration error");
                System.println(e.getErrorMessage());
                return;
            }
        }
        WatchUi.requestUpdate();
    }
    function line(dc, y, font, text, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2, y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
    }
    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        dc.setColor(0x101C26, 0x101C26);
        dc.clear();
        line(dc, h*0.12, Graphics.FONT_SMALL, "SoftRise", 0xA8DFCA);
        line(dc, h*0.23, Graphics.FONT_XTINY, "VIBRATION LAB", 0xA0ADB5);
        line(dc, h*0.36, Graphics.FONT_MEDIUM, LabPlan.nameOf(selection), 0xFFFFFF);
        var detail = selection == 3 ? "80 / 250 / 600 ms" : LabPlan.pulseMs(selection).toString() + " ms / every 2s";
        if (running) { detail = "Stage " + (stageIndex+1).toString() + " / " + LabPlan.pulseMs(stageIndex).toString() + " ms"; }
        line(dc, h*0.49, Graphics.FONT_XTINY, detail, 0xA8DFCA);
        var seconds = ((LabPlan.duration(selection) - elapsed + 999)/1000).toString();
        line(dc, h*0.59, Graphics.FONT_SMALL, status + (running ? " / " + seconds + "s" : ""), 0xFFFFFF);
        dc.setColor(0x344751, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(w*0.25, h*0.72, w*0.5, 4);
        dc.setColor(0xA8DFCA, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(w*0.25, h*0.72, w*0.5*elapsed/LabPlan.duration(selection), 4);
        line(dc, h*0.78, Graphics.FONT_XTINY, running ? "START / BACK: stop" : "UP/DOWN: choose", 0xA0ADB5);
        if (!running) { line(dc, h*0.85, Graphics.FONT_XTINY, "START: run", 0xA0ADB5); }
    }
}

class LabDelegate extends WatchUi.BehaviorDelegate {
    var lab;
    function initialize(view) { BehaviorDelegate.initialize(); lab = view; }
    function onSelect() { lab.toggle(); return true; }
    function onNextPage() { lab.choose(1); return true; }
    function onPreviousPage() { lab.choose(-1); return true; }
    function onBack() {
        if (lab.running) { lab.stop("Stopped"); return true; }
        return false;
    }
}
