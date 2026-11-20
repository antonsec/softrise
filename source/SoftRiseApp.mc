import Toybox.Application;
import Toybox.WatchUi;

class SoftRiseApp extends Application.AppBase {
    var lab;
    var alarm;
    function initialize() { AppBase.initialize(); }
    function getInitialView() {
        alarm = new AlarmView();
        return [alarm, new AlarmDelegate(alarm)];
    }
    function onStop(state) {
        if (lab != null) { lab.stop("Stopped"); }
        if (alarm != null) { alarm.stop("Exited: disarmed"); }
    }
}
