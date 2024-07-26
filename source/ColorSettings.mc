using Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;

class ColorSettingsMenu extends WatchUi.Menu2 
{
    private var settings_name;

    private var selection_index;

    private var menu_item_handle;

    function initialize(title, name) 
    {
        View.initialize();

        settings_name = name;

        menu_item_handle = null;
        
        Menu2.initialize({:title=>title});

        // var custom_color = Application.Properties.getValue(settings_name + "Custom") as Number;
        var custom_color = loadColorSettings(settings_name);

        Menu2.addItem(new WatchUi.IconMenuItem("Customize", colorName(custom_color), "CustomColor", generateColorIcon(custom_color), {:alignment=> WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));

        for(var i =0; i < colors.size(); i++)
        {
            Menu2.addItem(new WatchUi.IconMenuItem(colorName(colors[i]), null, colors[i], generateColorIcon(colors[i]), {:alignment=> WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
        }

    }

    // Resources are loaded here
    function onLayout(dc) 
    {
        
    }

    // onShow() is called when this View is brought to the foreground
    function onShow() 
    {
    }

    // onUpdate() is called periodically to update the View
    function onUpdate(dc) 
    {
        View.onUpdate(dc);

        
    }

    // onHide() is called when this View is removed from the screen
    function onHide() 
    {
        
    }

    public function setSettingsName(name)
    {
        settings_name = name;
    }

    public function getSettingsName()
    {
        return settings_name;
    }

    public function setSelectionIndex(index)
    {
        selection_index = index;
    }

    public function getSelectionIndex()
    {
        return selection_index;
    }

    public function setMenuItemHandle(handle)
    {
        menu_item_handle  = handle;
    }

     public function getMenuItemHandle()
    {
        return menu_item_handle;
    }
}

class ColorSettingsMenuDelegate extends WatchUi.Menu2InputDelegate
{
    private var color_settings_menu;
    
    //! Constructor
    public function initialize() 
    {
        Menu2InputDelegate.initialize();
    }

    public function onSelect(menuItem as MenuItem) as Void 
    {
        // if (menuItem.getId() as String == "Custom") 
        if((menuItem.getId() as String).equals("CustomColor"))
        {
            var color_picker;
            
            color_picker = new ColorPickerView();
            
            color_picker.setSettingsName(color_settings_menu.getSettingsName());
            color_picker.setMenuItemHandle(color_settings_menu.getMenuItemHandle());
            color_picker.setColorMenuItemHandle(menuItem);


            var delegate = new ColorPickerViewDelegate();

            delegate.setView(color_picker);

            WatchUi.pushView(color_picker, delegate, WatchUi.SLIDE_LEFT);      
        
        }

        else
        {
            var color_id = menuItem.getId() as Number; 

            Application.Properties.setValue(color_settings_menu.getSettingsName(), color_id);

            if(color_settings_menu.getMenuItemHandle() != null)
            {
                color_settings_menu.getMenuItemHandle().setSubLabel(colorName(color_id));

                color_settings_menu.getMenuItemHandle().setIcon(generateColorIcon(color_id));

                WatchUi.popView(WatchUi.SLIDE_RIGHT);
                
                WatchUi.requestUpdate();
            }

            // System.print(color_id);      
        }

        
    }

    public function setMenu(menu)
    {
        color_settings_menu = menu;
    }

    // function onTap(clickEvent) 
    // {
        
    //     return true;
    // }

    // function onSwipe(swipeEvent) 
    // {
    //     // System.println(swipeEvent.getDirection()); // e.g. SWIPE_DOWN = 2
    //     return true;
    // }
}