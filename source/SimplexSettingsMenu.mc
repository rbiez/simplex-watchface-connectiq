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
        if (menuItem instanceof ToggleMenuItem) 
        {
            Application.Properties.setValue(menuItem.getId() as String, menuItem.isEnabled() as Number);
        }

        // else if((menuItem.getId() as String).equals("TEST"))
        // {
        //     var color_picker;
        //     color_picker = new ColorPickerView();
        //     color_picker.setSettingsName("ForegroundColorOne");

        //     var delegate = new ColorPickerViewDelegate();

        //     delegate.setView(color_picker);

        //     WatchUi.pushView(color_picker, delegate, WatchUi.SLIDE_LEFT);
        // }

        else
        {
            var color_picker;
            
            color_picker = new ColorPickerView();
            
            color_picker.setSettingsName(menuItem.getId() as String);
            color_picker.setMenuItemHandle(menuItem);

            var delegate = new ColorPickerViewDelegate();

            delegate.setView(color_picker);

            WatchUi.pushView(color_picker, delegate, WatchUi.SLIDE_LEFT);            
        }

        // else
        // {
        //     var color = Application.Properties.getValue(menuItem.getId() as String) as Number;

        //     var new_index = (colorIndex(color) + 1) % colors.size();

        //     Application.Properties.setValue(menuItem.getId() as String, colors[new_index]);

        //     menuItem.setSubLabel(color_names[new_index]);
        // }

        
    }
}

