import Toybox.Application;
import Toybox.WatchUi;

class SoftRiseApp extends Application.AppBase {
    var picker;
    var lab;
    var alarm;
    function initialize() { AppBase.initialize(); }
    function getInitialView() {
        alarm = new AlarmView();
        return [alarm, new AlarmDelegate(alarm)];
    }
    function onStop(state) {
        if (picker != null) { picker.onHide(); }
        if (lab != null) { lab.stop("Stopped"); }
        if (alarm != null) { alarm.stop("Exited: disarmed"); }
    }
}
