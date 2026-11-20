import Toybox.Application;
import Toybox.Attention;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Timer;
import Toybox.WatchUi;

class AlarmView extends WatchUi.View {
    var engine;
    var ticker;
    var visible = false;
    var hour = 7;
    var minute = 0;
    var ramp = 3;
    var message = "Set wake time";
    var batteryStart = 0.0;
    var batteryEnd = 0.0;
    var armedAt = 0;
    var lastDrawMinute = -1;
    var lastWall = 0;
    var lastMono = 0;
    var zoneOffset = 0;
    var screenWidth = 416;
    var screenHeight = 416;
    function initialize() {
        View.initialize();
        engine = new AlarmEngine();
        ticker = new Timer.Timer();
        var settings = null;
        try { settings = Application.Storage.getValue("alarmSettings"); }
        catch (e) { message = "Settings unavailable"; }
        if (settings instanceof Lang.Array && settings.size() == 3) {
            if (settings[0] instanceof Lang.Number && settings[0] >= 0 && settings[0] < 24) { hour = settings[0]; }
            if (settings[1] instanceof Lang.Number && settings[1] >= 0 && settings[1] < 60) { minute = settings[1]; }
            if (settings[2] instanceof Lang.Number && settings[2] >= 1 && settings[2] <= 5) { ramp = settings[2]; }
        }
        minute = (minute / 5) * 5;
    }
    function nowSeconds() { return Time.now().value(); }
    function monotonicMs() { return System.getTimer(); }
    function batteryPercent() { return System.getSystemStats().battery; }
    function emitPulse(length) { Attention.vibrate([new Attention.VibeProfile(100, length)]); }
    function saveSettings() {
        try {
            Application.Storage.setValue("alarmSettings", [hour, minute, ramp]);
            return true;
        } catch (e) {
            message = "Settings not saved";
            WatchUi.requestUpdate();
            return false;
        }
    }
    function offsetAt(now) {
        var local = Gregorian.info(new Time.Moment(now), Time.FORMAT_SHORT);
        return Gregorian.moment({:year=>local.year, :month=>local.month, :day=>local.day,
            :hour=>local.hour, :minute=>local.min, :second=>local.sec}).value() - now;
    }
    function onShow() { visible = true; WatchUi.requestUpdate(); }
    function active() { return engine.state.equals("armed") || engine.state.equals("ringing") || engine.state.equals("snoozed"); }
    function stop(reason) {
        var wasActive = active();
        engine.cancel();
        ticker.stop();
        if (wasActive) { batteryEnd = batteryPercent(); }
        message = reason;
        WatchUi.requestUpdate();
    }
    function onHide() {
        visible = false;
        if (active()) { stop("Hidden: disarmed"); }
        else { ticker.stop(); }
    }
    function change(delta) {
        if (engine.state.equals("ringing")) {
            engine.snooze(nowSeconds());
            message = "Snoozed 5 minutes";
        } else if (!active()) {
            var total = (hour * 60 + minute + delta * 5 + 1440) % 1440;
            hour = total / 60;
            minute = total % 60;
            message = "Set wake time";
        }
        WatchUi.requestUpdate();
    }
    function sliderAt(x, y) {
        if (!visible || active() || x < screenWidth*0.12 || x > screenWidth*0.88) { return -1; }
        if (y >= screenHeight*0.46 && y <= screenHeight*0.57) { return 0; }
        if (y >= screenHeight*0.62 && y <= screenHeight*0.73) { return 1; }
        return -1;
    }
    function setButtonBounds() as Lang.Array<Lang.Numeric> {
        return [screenWidth*0.25, screenHeight*0.76, screenWidth*0.50, screenHeight*0.12];
    }
    function setButtonAt(x, y) {
        if (!visible || active()) { return false; }
        var b = setButtonBounds();
        var radius = b[3]/2;
        var centerX = x;
        if (centerX < b[0]+radius) { centerX = b[0]+radius; }
        if (centerX > b[0]+b[2]-radius) { centerX = b[0]+b[2]-radius; }
        var dx = x-centerX;
        var dy = y-(b[1]+radius);
        return dx*dx + dy*dy <= radius*radius;
    }
    function setSlider(index, x) {
        if (!visible || active()) { return; }
        var ratio = (x - screenWidth*0.20)/(screenWidth*0.60);
        if (ratio < 0.0) { ratio = 0.0; }
        if (ratio > 1.0) { ratio = 1.0; }
        if (index == 0) { hour = Math.round(ratio * 23).toNumber(); }
        else if (index == 1) { minute = Math.round(ratio * 11).toNumber() * 5; }
        else { return; }
        message = "Set wake time";
        WatchUi.requestUpdate();
    }
    function slider(dc, fraction, value, maxValue) {
        var left = screenWidth*0.20;
        var width = screenWidth*0.60;
        var y = screenHeight*fraction;
        dc.setColor(0x344751, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(left, y, width, 4);
        dc.setColor(0xA8DFCA, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(left, y, width*value/maxValue, 4);
        dc.fillCircle(left + width*value/maxValue, y+2, 8);
    }
    function select() {
        if (active()) { stop("Stopped"); return; }
        if (!visible || !(Attention has :vibrate)) { message = "Vibration unavailable"; WatchUi.requestUpdate(); return; }
        var now = nowSeconds();
        var local = Gregorian.info(new Time.Moment(now), Time.FORMAT_SHORT);
        var delay = AlarmPlan.nextDelay(hour, minute, local.hour*3600 + local.min*60 + local.sec);
        engine.arm(now, delay, ramp);
        lastWall = now;
        lastMono = monotonicMs();
        zoneOffset = offsetAt(now);
        armedAt = now;
        batteryStart = batteryPercent();
        batteryEnd = batteryStart;
        message = delay > 43200 ? "Next occurrence" : "Alarm armed";
        lastDrawMinute = -1;
        if (!saveSettings()) { stop("Settings not saved"); return; }
        try {
            ticker.start(method(:tick), 1000, true);
        } catch (e) { stop("Could not arm"); }
        WatchUi.requestUpdate();
    }
    function tick() {
        if (!visible || !active()) { return; }
        var now = nowSeconds();
        var mono = monotonicMs();
        var drift = (now - lastWall) - ((mono - lastMono)/1000);
        if (drift > 5 || drift < -5 || offsetAt(now) != zoneOffset) {
            stop("Time changed: rearm"); return;
        }
        lastWall = now;
        lastMono = mono;
        var before = engine.state;
        var length = engine.tick(now);
        if (length > 0) {
            try { emitPulse(length); }
            catch (e) { stop("Vibration error"); return; }
        }
        if (engine.state.equals("complete")) {
            ticker.stop();
            batteryEnd = batteryPercent();
            message = "Ended after 10 min";
        }
        // Waiting UI redraws once a minute, not on every timer callback.
        var currentMinute = now / 60;
        if (engine.state.equals("ringing") || !before.equals(engine.state) || currentMinute != lastDrawMinute) {
            lastDrawMinute = currentMinute;
            WatchUi.requestUpdate();
        }
    }
    function idleDetail() {
        if (!message.equals("Set wake time") && !message.equals("Stopped")) { return message; }
        return armedAt > 0 ? "Used " + (batteryStart-batteryEnd).format("%.1f") + "%" : "";
    }
    function displayTime() {
        if (active()) {
            var dueTime = Gregorian.info(new Time.Moment(engine.due), Time.FORMAT_SHORT);
            return dueTime.hour.format("%02d") + ":" + dueTime.min.format("%02d");
        }
        return hour.format("%02d") + ":" + minute.format("%02d");
    }
    function dayLabel() {
        var now = Gregorian.info(new Time.Moment(nowSeconds()), Time.FORMAT_SHORT);
        var due = Gregorian.info(new Time.Moment(engine.due), Time.FORMAT_SHORT);
        return now.year == due.year && now.month == due.month && now.day == due.day ? "Today" : "Tomorrow";
    }
    function text(dc, fraction, font, value, color) {
        // Fit each line within the circular display's chord at this height.
        var y = (dc.getHeight()*fraction).toNumber();
        var centerY = y + dc.getFontHeight(font)/2;
        var radius = dc.getWidth()/2 - 22;
        var offset = centerY - dc.getHeight()/2;
        var width = 2 * Math.sqrt(radius*radius - offset*offset);
        if (dc.getTextWidthInPixels(value, font) > width) { font = Graphics.FONT_XTINY; }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2, y, font, value, Graphics.TEXT_JUSTIFY_CENTER);
    }
    function onUpdate(dc) {
        screenWidth = dc.getWidth(); screenHeight = dc.getHeight();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK); dc.clear();
        var mint = 0xA8DFCA;
        var muted = 0xA0ADB5;
        text(dc, 0.16, Graphics.FONT_XTINY, "SoftRise", mint);
        var time = displayTime();
        text(dc, 0.32, Graphics.FONT_MEDIUM, time, Graphics.COLOR_WHITE);
        if (active()) {
            var ringing = engine.state.equals("ringing");
            var label = ringing ? "Waking / " + (engine.stageIndex+1).toString() + " of 3" : engine.state.equals("snoozed") ? "Snoozed" : "Armed / " + dayLabel();
            text(dc, 0.49, Graphics.FONT_SMALL, label, mint);
            text(dc, 0.62, Graphics.FONT_XTINY, ringing ? "UP/DOWN: snooze" : "Leave app open", muted);
            text(dc, 0.73, Graphics.FONT_XTINY, "START/BACK: stop", muted);
        } else {
            text(dc, 0.43, Graphics.FONT_XTINY, "HOUR", muted);
            slider(dc, 0.52, hour, 23);
            text(dc, 0.59, Graphics.FONT_XTINY, "MINUTE / 5 min", muted);
            slider(dc, 0.68, minute/5, 11);
            var button = setButtonBounds();
            dc.setColor(mint, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(button[0], button[1], button[2], button[3], button[3]/2);
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            var labelY = button[1] + (button[3]-dc.getFontHeight(Graphics.FONT_XTINY))/2;
            dc.drawText(screenWidth/2, labelY, Graphics.FONT_XTINY, "Set alarm", Graphics.TEXT_JUSTIFY_CENTER);
            text(dc, 0.23, Graphics.FONT_XTINY, idleDetail(), muted);
        }
    }
}

class AlarmDelegate extends WatchUi.BehaviorDelegate {
    var alarm;
    var draggedSlider = -1;
    function initialize(view) { BehaviorDelegate.initialize(); alarm = view; }
    function onTap(event) {
        var point = event.getCoordinates();
        if (alarm.setButtonAt(point[0], point[1])) {
            alarm.select();
            return true;
        }
        var index = alarm.sliderAt(point[0], point[1]);
        if (index >= 0) { alarm.setSlider(index, point[0]); }
        return true;
    }
    function onDrag(event) {
        var point = event.getCoordinates();
        if (event.getType() == WatchUi.DRAG_TYPE_START) {
            draggedSlider = alarm.sliderAt(point[0], point[1]);
        }
        if (draggedSlider >= 0) { alarm.setSlider(draggedSlider, point[0]); }
        if (event.getType() == WatchUi.DRAG_TYPE_STOP) { draggedSlider = -1; }
        return true;
    }
    function onSwipe(event) { return true; }
    function onSelect() { alarm.select(); return true; }
    function onNextPage() { alarm.change(-1); return true; }
    function onPreviousPage() { alarm.change(1); return true; }
    function onBack() {
        if (alarm.active()) { alarm.stop("Stopped"); return true; }
        return false;
    }
    function onMenu() {
        if (!alarm.active()) {
            var menu = new WatchUi.Menu2({:title=>"Options"});
            for (var i = 1; i <= 5; i += 1) {
                menu.addItem(new WatchUi.MenuItem("Ramp " + i.toString() + " min", null, i, null));
            }
            menu.addItem(new WatchUi.MenuItem("Vibration lab", null, 0, null));
            WatchUi.pushView(menu, new AlarmOptionsDelegate(alarm), WatchUi.SLIDE_UP);
        }
        return true;
    }
}


class AlarmOptionsDelegate extends WatchUi.Menu2InputDelegate {
    var alarm;
    function initialize(view) { Menu2InputDelegate.initialize(); alarm = view; }
    function onSelect(item) {
        var id = item.getId();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        if (id == 0) {
            var lab = new LabView();
            var app = Application.getApp() as SoftRiseApp;
            app.lab = lab;
            WatchUi.pushView(lab, new LabDelegate(lab), WatchUi.SLIDE_UP);
        } else {
            alarm.ramp = id;
            alarm.saveSettings();
            WatchUi.requestUpdate();
        }
    }
}
