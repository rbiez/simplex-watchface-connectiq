import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;

//! The app settings menu
class SimplexSettingsMenu extends WatchUi.Menu2 
{

    //! Constructor
    public function initialize() 
    {
        Menu2.initialize({:title=>"Settings"});
    }
}

//! Input handler for the app settings menu
class SimplexSettingsMenuDelegate extends WatchUi.Menu2InputDelegate
{

    //! Constructor
    public function initialize() 
    {
        Menu2InputDelegate.initialize();
    }

    //! Handle a menu item being selected
    //! @param menuItem The menu item selected
    public function onSelect(menuItem as MenuItem) as Void 
    {
        var version = Lang.format("$1$$2$$3$",System.getDeviceSettings().monkeyVersion).toNumber();

        if (menuItem instanceof ToggleMenuItem) 
        {
            Application.Properties.setValue(menuItem.getId() as String, menuItem.isEnabled() as Number);
        }

        else if((menuItem.getId() as String).equals("Mode"))
        {
            var val = Application.Properties.getValue("Mode") ? true : false;

            val = !val;
            
            // {:enabled=>"Mode: Custom", :disabled=>"Mode: Theme"}

            if(val)
            {
                menuItem.setSubLabel("Custom Colors");
            }

            else
            {
                menuItem.setSubLabel("Theme Colors");
            }

            Application.Properties.setValue(menuItem.getId() as String, val);

        }

        else if((menuItem.getId() as String).equals("Theme"))
        {
            var val = Application.Properties.getValue("Theme") ? true : false;

            val = !val;
            
            // {:enabled=>"Mode: Custom", :disabled=>"Mode: Theme"}

            if(val)
            {
                menuItem.setSubLabel("Dark Theme");
            }

            else
            {
                menuItem.setSubLabel("Light Theme");
            }

            Application.Properties.setValue(menuItem.getId() as String, val);

        }

        else if((menuItem.getId() as String).equals("MinuteHandWidth"))
        {
            var value = Application.Properties.getValue("MinuteHandWidth") as Number;

            var new_value = 2 + (((value-2) + 1) % 14);

            Application.Properties.setValue("MinuteHandWidth", new_value);

            menuItem.setSubLabel(new_value.toString());

        }

        else if((menuItem.getId() as String).equals("HourHandWidth"))
        {
            var value = Application.Properties.getValue("HourHandWidth") as Number;

            var new_value = 2 + (((value-2) + 1) % 14);

            Application.Properties.setValue("HourHandWidth", new_value);

            menuItem.setSubLabel(new_value.toString());
        }

        else if((menuItem.getId() as String).equals("SecondsHandLength"))
        {
            var value = Application.Properties.getValue("SecondsHandLength") as Number;

            var new_value = (value + 1) % 9;

            Application.Properties.setValue("SecondsHandLength", new_value);

            menuItem.setSubLabel(new_value.toString());

        }

        else if((menuItem.getId() as String).equals("MinuteHandLength"))
        {
            var value = Application.Properties.getValue("MinuteHandLength") as Number;

            var new_value = (value + 1) % 9;

            Application.Properties.setValue("MinuteHandLength", new_value);

            menuItem.setSubLabel(new_value.toString());

        }

        else if((menuItem.getId() as String).equals("HourHandLength"))
        {
            var value = Application.Properties.getValue("HourHandLength") as Number;

            var new_value = (value + 1) % 9;

            Application.Properties.setValue("HourHandLength", new_value);

            menuItem.setSubLabel(new_value.toString());
        }


        else if((menuItem.getId() as String).equals("MinuteHandThinning"))
        {
            var value = Application.Properties.getValue("MinuteHandThinning") as Number;

            var new_value = (value + 1) % 9;

            Application.Properties.setValue("MinuteHandThinning", new_value);

            menuItem.setSubLabel(new_value.toString());
        }

        else if((menuItem.getId() as String).equals("HourHandThinning"))
        {
            var value = Application.Properties.getValue("HourHandThinning") as Number;

            var new_value = (value + 1) % 9;

            Application.Properties.setValue("HourHandThinning", new_value);

            menuItem.setSubLabel(new_value.toString());
        }

        else
        {
            // var color_picker;
            
            // color_picker = new ColorPickerView();
            
            // color_picker.setSettingsName(menuItem.getId() as String);
            // color_picker.setMenuItemHandle(menuItem);

            // var delegate = new ColorPickerViewDelegate();

            // delegate.setView(color_picker);

            // WatchUi.pushView(color_picker, delegate, WatchUi.SLIDE_LEFT);      

            if(version > 420)
            {
                var color_menu = new ColorSettingsMenu(menuItem.getId() as String, menuItem.getId() as String);
                var delegate = new ColorSettingsMenuDelegate();

                color_menu.setMenuItemHandle(menuItem);
                delegate.setMenu(color_menu);

                WatchUi.pushView(color_menu, delegate, WatchUi.SLIDE_LEFT);       
            }

            //these are the old settings, they still take up too much memory
            else 
            {
                var color = Application.Properties.getValue(menuItem.getId() as String) as Number;

                var new_index = (colorIndex(color) + 1) % colors.size();

                Application.Properties.setValue(menuItem.getId() as String, colors[new_index]);

                menuItem.setSubLabel(color_names[new_index]);
            }
        }

        
    }
}

