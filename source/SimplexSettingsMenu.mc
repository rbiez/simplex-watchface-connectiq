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

        else
        {
            var color = Application.Properties.getValue(menuItem.getId() as String) as Number;

            var new_index = (colorIndex(color) + 1) % colors.size();

            Application.Properties.setValue(menuItem.getId() as String, colors[new_index]);

            menuItem.setSubLabel(color_names[new_index]);
        }

        
    }
}

