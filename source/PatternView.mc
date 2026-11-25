import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

class PatternView extends WatchUi.Menu2 {
    var alarm;
    var selected;
    var preview;
    var timer;
    var visible = false;
    var testItem;
    var saveItem;

    function initialize(view, pattern) {
        Menu2.initialize({:title=>LabPlan.PATTERNS[pattern]});
        testItem = new WatchUi.MenuItem("Test", null, :test, null);
        saveItem = new WatchUi.MenuItem("Save", null, :save, null);
        addItem(testItem);
        addItem(saveItem);
        alarm = view;
        selected = pattern;
        timer = new Timer.Timer();
    }
    function onShow() { Menu2.onShow(); visible = true; }
    function stopPreview() {
        preview = null;
        timer.stop();
        testItem.setLabel("Test");
        testItem.setSubLabel(null);
        WatchUi.requestUpdate();
    }
    function onHide() { visible = false; stopPreview(); Menu2.onHide(); }
    function toggle() {
        if (preview != null) { stopPreview(); return; }
        if (!visible) { return; }
        testItem.setLabel("Stop");
        testItem.setSubLabel("Preview playing");
        preview = new AlarmEngine();
        preview.pattern = selected;
        preview.arm(System.getTimer() / 1000, 0, 5);
        timer.start(method(:tick), 1000, true);
        tick();
    }
    function tick() {
        if (!visible || preview == null) { return; }
        var length = preview.tick(System.getTimer() / 1000);
        if (length > 0) {
            try { alarm.emitPulse(length); }
            catch (e) { stopPreview(); testItem.setSubLabel("Unavailable"); return; }
            var limit = 2 * AlarmPlan.tapsPerSet(selected);
            if (preview.pulses >= limit) { stopPreview(); }
        }
        WatchUi.requestUpdate();
    }
    function save() {
        stopPreview();
        var previous = alarm.engine.pattern;
        alarm.engine.pattern = selected;
        if (alarm.saveSettings()) { WatchUi.popView(WatchUi.SLIDE_DOWN); }
        else { alarm.engine.pattern = previous; saveItem.setSubLabel("Save failed"); }
    }
}

class PatternDelegate extends WatchUi.Menu2InputDelegate {
    var picker;
    function initialize(view) { Menu2InputDelegate.initialize(); picker = view; }
    function onSelect(item) {
        if (item.getId() == :test) { picker.toggle(); }
        else { picker.save(); }
    }
    function onBack() {
        if (picker.preview != null) { picker.stopPreview(); }
        else { WatchUi.popView(WatchUi.SLIDE_DOWN); }
    }
}
