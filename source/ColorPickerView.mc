using Toybox.System;
using Toybox.WatchUi;

class ColorPickerView extends WatchUi.View 
{
    private var settings_name;

    private var selection_index;

    private var menu_item_handle;

    function initialize() 
    {
        View.initialize();

        selection_index = 0;
        settings_name = "null";

        menu_item_handle = null;

    }

    // Resources are loaded here
    function onLayout(dc) 
    {
        
    }

    // onShow() is called when this View is brought to the foreground
    function onShow() 
    {
        setSelectionIndex(color64Index(loadColorSettings(settings_name)));
    }

    // onUpdate() is called periodically to update the View
    function onUpdate(dc) 
    {
        View.onUpdate(dc);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var screen_width = dc.getWidth();
        var screen_height = dc.getHeight();
        var center_x = screen_width/2;
        var center_y = screen_height/2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        // dc.drawText(50, 50,Graphics.FONT_SMALL,"TEST",Graphics.TEXT_JUSTIFY_VCENTER);

        //draw an arc of all 64 colors
        for (var i = 0; i < all_colors64.size(); i++)
        {
            var arc_length_angle= (i/64.0)*2.0*Math.PI;
            var arc_length_angle_next = ((i+1)/64.0)*2.0*Math.PI;


            var radius_out = screen_width/2 - 5;
            var radius_in = screen_width/4;

            if(i == selection_index)
            {
                radius_out += 10;
                radius_in -= 10;
            }

            var right_out_x = radius_out*Math.cos(arc_length_angle);
            var right_out_y = radius_out*Math.sin(arc_length_angle);

            var left_out_x = radius_out*Math.cos(arc_length_angle_next);
            var left_out_y = radius_out*Math.sin(arc_length_angle_next);

            var right_in_x = radius_in*Math.cos(arc_length_angle_next);
            var right_in_y = radius_in*Math.sin(arc_length_angle_next);

            var left_in_x = radius_in*Math.cos(arc_length_angle);
            var left_in_y = radius_in*Math.sin(arc_length_angle);


            var points = [[center_x + right_out_x, center_y + right_out_y], [center_x + left_out_x, center_y + left_out_y], [center_x + right_in_x, center_y + right_in_y], [center_x + left_in_x, center_y + left_in_y]];

            dc.setColor(all_colors64[i], Graphics.COLOR_BLACK);
            dc.fillPolygon(points);
        }

        dc.setColor(all_colors64[selection_index], Graphics.COLOR_BLACK);
        dc.fillCircle(center_x, center_y, screen_width/5);
    }

    // onHide() is called when this View is removed from the screen
    function onHide() 
    {
        //we save the section
        //we set the custom color value to the selection
        if(colorIndex(all_colors64[selection_index]) == -1)
        {
            Application.Properties.setValue(settings_name + "Custom", all_colors64[selection_index]);

            //we set the list value to -1 (for 'Custom')
            Application.Properties.setValue(settings_name, -1);
        }

        //if a color was selected that is also on the list we set the list value
        else
        {
            Application.Properties.setValue(settings_name, all_colors64[selection_index]);
        }

        if(menu_item_handle != null)
        {
            menu_item_handle.setSubLabel(colorName(all_colors64[selection_index]));

            menu_item_handle.setIcon(generateColorIcon(all_colors64[selection_index]));
            
            WatchUi.requestUpdate();
        }
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
}

class ColorPickerViewDelegate extends WatchUi.InputDelegate
{
    private var picker_view;
    
    //! Constructor
    public function initialize() 
    {
        InputDelegate.initialize();
    }

    function onKey(keyEvent) 
    {
        // System.println(keyEvent.getKey());         // e.g. KEY_MENU = 7
        if(keyEvent.getKey() == KEY_ESC)
        {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return true;
        }

        else if (keyEvent.getKey() == KEY_UP)
        {
            picker_view.setSelectionIndex((picker_view.getSelectionIndex() - 1) % 64 );
            return false;
        }

        else if (keyEvent.getKey() == KEY_DOWN)
        {
            picker_view.setSelectionIndex((picker_view.getSelectionIndex() + 1) % 64 );
            return false;
        }

        return true;



    }

    public function setView(view)
    {
        picker_view = view;
    }

    function onTap(clickEvent) 
    {
        // System.println(clickEvent.getType());      // e.g. CLICK_TYPE_TAP = 0
        //System.println("tapped");
        var screen_width = System.getDeviceSettings().screenWidth;
        var screen_height = System.getDeviceSettings().screenHeight;
        var center_x = screen_width/2;
        var center_y = screen_height/2;

        var x = clickEvent.getCoordinates()[0];
        var y = clickEvent.getCoordinates()[1];

        var angle = Math.atan2(y -center_y, x- center_x);
        
        if(angle < 0)
        {
            angle += 2*Math.PI;
        }

        // System.println(angle);

        var index = (64.0*(angle/(2*Math.PI))).toNumber();

        // System.println(index);
        
        picker_view.setSelectionIndex(index);

        // Application.Properties.setValue("BackgroundColor", all_colors64[index]);

        WatchUi.requestUpdate();

        return true;
    }

    function onSwipe(swipeEvent) 
    {
        // System.println(swipeEvent.getDirection()); // e.g. SWIPE_DOWN = 2
        return true;
    }
}