import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class SimplexApp extends Application.AppBase 
{
    hidden var app_view;

    function initialize() 
    {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void 
    {

    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void 
    {
        
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? 
    {
        app_view = new SimplexView();

        return [ app_view, new $.SimplexDelegate(app_view) ] as Array<Views or InputDelegates>;
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void 
    {
        app_view.loadSettings();
        WatchUi.requestUpdate();       
    }

    // Return the settings view and delegate
    public function getSettingsView() as Array<Views or InputDelegates>? 
    {
        var menu;
        menu = new $.SimplexSettingsMenu();

        var val = Application.Properties.getValue("DrawDate") ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Draw Date", null, "DrawDate", val, null));

        val = Application.Properties.getValue("DrawNumbers") ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Draw Numbers", null, "DrawNumbers", val, null));

        val = Application.Properties.getValue("DrawMinuteTicks") ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Draw Minute Ticks", null, "DrawMinuteTicks", val, null));

        val = Application.Properties.getValue("DrawHourTicks") ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Draw Hour Ticks", null, "DrawHourTicks", val, null));

        val = Application.Properties.getValue("DrawSecondsHand") ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Draw Second Hand", null, "DrawSecondsHand", val, null));

        //only MIP screens allow to have the seconds to be always drawn
        if(WatchUi.WatchFace has :onPartialUpdate)
        {
            val = Application.Properties.getValue("SecondsHandMode") ? true : false;
            menu.addItem(new WatchUi.ToggleMenuItem("Second Hand Mode", {:enabled=>"Draw always", :disabled=>"Draw after gesture"}, "SecondsHandMode", val, null));
        }

        val = Application.Properties.getValue("Mode") ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Mode", {:enabled=>"Mode: Custom", :disabled=>"Mode: Theme"}, "Mode", val, null));

        val = Application.Properties.getValue("Theme") ? true : false;
        menu.addItem(new WatchUi.ToggleMenuItem("Theme", {:enabled=>"Theme: Dark", :disabled=>"Theme: Light"}, "Theme", val, null));

        val = Application.Properties.getValue("BackgroundColor") as Number;
        menu.addItem(new WatchUi.MenuItem("Background Color", color_names[colorIndex(val)], "BackgroundColor", null));

        val = Application.Properties.getValue("ForegroundColorOne") as Number;
        menu.addItem(new WatchUi.MenuItem("Foreground Color 1", color_names[colorIndex(val)], "ForegroundColorOne", null));

        val = Application.Properties.getValue("ForegroundColorTwo") as Number;
        menu.addItem(new WatchUi.MenuItem("Foreground Color 2", color_names[colorIndex(val)], "ForegroundColorTwo", null));

        val = Application.Properties.getValue("SecondsHandColor") as Number;
        menu.addItem(new WatchUi.MenuItem("Second Hand Color", color_names[colorIndex(val)], "SecondsHandColor", null));

        val = Application.Properties.getValue("MinuteHandColorOne") as Number;
        menu.addItem(new WatchUi.MenuItem("Minute Hand Color 1", color_names[colorIndex(val)], "MinuteHandColorOne", null));

        val = Application.Properties.getValue("MinuteHandColorTwo") as Number;
        menu.addItem(new WatchUi.MenuItem("Minute Hand Color 2", color_names[colorIndex(val)], "MinuteHandColorTwo", null));

        val = Application.Properties.getValue("HourHandColorOne") as Number;
        menu.addItem(new WatchUi.MenuItem("Hour Hand Color 1", color_names[colorIndex(val)], "HourHandColorOne", null));

        val = Application.Properties.getValue("HourHandColorTwo") as Number;
        menu.addItem(new WatchUi.MenuItem("Hour Hand Color 2", color_names[colorIndex(val)], "HourHandColorTwo", null));

        //WatchUi.pushView(menu, new $.SimplexSettingsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);

        return [menu, new $.SimplexSettingsMenuDelegate()] as Array<Views or InputDelegates>;
    }

}

function getApp() as SimplexApp 
{
    return Application.getApp() as SimplexApp;
}