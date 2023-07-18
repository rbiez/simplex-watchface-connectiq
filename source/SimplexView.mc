import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class SimplexView extends WatchUi.WatchFace 
{

    var drawSecondsHand;

    var background_color;
    var foreground_color;
    var left_hand_color;
    var right_hand_color;

    var seconds_hand_color;

    function initialize() 
    {
        WatchFace.initialize();

        drawSecondsHand = true;

        background_color = Graphics.COLOR_BLACK;
        foreground_color = Graphics.COLOR_WHITE;
        left_hand_color = Graphics.COLOR_LT_GRAY;
        right_hand_color = Graphics.COLOR_WHITE;

        seconds_hand_color = Graphics.COLOR_RED;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void 
    {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void 
    {

        //black theme (TODO: chnage to 0)
        if(getApp().getProperty("Theme") as Number == 1)
        {
            background_color = Graphics.COLOR_BLACK;
            foreground_color = Graphics.COLOR_WHITE;
            left_hand_color = Graphics.COLOR_LT_GRAY;
            right_hand_color = Graphics.COLOR_WHITE;
        }

        //white theme
        else 
        {
            background_color = Graphics.COLOR_WHITE;
            foreground_color = Graphics.COLOR_BLACK;
            left_hand_color = Graphics.COLOR_DK_GRAY;
            right_hand_color = Graphics.COLOR_BLACK;
        }

        seconds_hand_color = getApp().getProperty("SecondsHandColor") as Number;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void 
    {

        // // Get the current time and format it correctly
        // var timeFormat = "$1$:$2$";
        // var clockTime = System.getClockTime();
        // var hours = clockTime.hour;
        // if (!System.getDeviceSettings().is24Hour) {
        //     if (hours > 12) {
        //         hours = hours - 12;
        //     }
        // } else {
        //     if (getApp().getProperty("UseMilitaryFormat")) {
        //         timeFormat = "$1$$2$";
        //         hours = hours.format("%02d");
        //     }
        // }
        // var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);

        // // Update the view
        // var view = View.findDrawableById("TimeLabel") as Text;
        // view.setColor(getApp().getProperty("ForegroundColor") as Number);
        // view.setText(timeString);



        // // Call the parent onUpdate function to redraw the layout
        // View.onUpdate(dc);

        var screen_width = dc.getWidth();
        var screen_height = dc.getHeight();
        var center_x = screen_width/2;
        var center_y = screen_height/2;

        var clockTime = System.getClockTime();

        // var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);

        var degSec =  2*Math.PI*(clockTime.sec/60.0) - Math.PI/2.0;
        var degMin =  2*Math.PI*(clockTime.min/60.0) - Math.PI/2.0;

        var degHour = 2*Math.PI*((clockTime.hour + clockTime.min/60.0) /12.0) - Math.PI/2;

        // System.println(degMin);
        // System.println(degHour);

        //clear the screen
        dc.setColor(background_color, background_color);
        dc.clear();

        // // Get and show the current time
        // var clockTime = System.getClockTime();
        // var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        // var view = View.findDrawableById("TimeLabel") as Text;
        // view.setText(timeString);

        // // Call the parent onUpdate function to redraw the layout
        // View.onUpdate(dc);

        dc.setColor(foreground_color, background_color);


        var sec_hand_length = screen_width/2.1;
        var min_hand_length = screen_width/2.3;
        var hour_hand_length = screen_width/3.3;

        var length_long = 15;

        var length_short = 7;

        // draw the date
        drawDate(dc,center_x,center_y, screen_width, screen_height);

        // draw the text
        drawText(dc,center_x,center_y, screen_width, screen_height, true);

        // draw the ticks
        drawTicks(dc,center_x,center_y, screen_width, screen_height, length_long, length_short);

        // draw the hours hand
        drawHand(dc, center_x,center_y, hour_hand_length,8.0,degHour, left_hand_color, right_hand_color, false);

        // draw the minutes hand
        drawHand(dc, center_x,center_y, min_hand_length,4.0, degMin, left_hand_color, right_hand_color, false);

        if(drawSecondsHand)
        {
            // draw the seconds hand
            drawHand(dc, center_x,center_y ,sec_hand_length,2,degSec, seconds_hand_color, seconds_hand_color, true);
        }

        //draw the center
        drawCenter(dc, center_x,center_y, seconds_hand_color);

    }

    function drawCenter(dc, center_x, center_y, seconds_hand_color) {

        var outer_diameter = 3;

        if(drawSecondsHand)
        {
            dc.setPenWidth(6);
            dc.setColor(seconds_hand_color, background_color);
            dc.drawCircle(center_x, center_y, 4);
        }

        else
        {
            outer_diameter = 4;
        }

        dc.setPenWidth(outer_diameter);
        dc.setColor(Graphics.COLOR_DK_GRAY, background_color);
        dc.drawCircle(center_x, center_y,outer_diameter);

        dc.setPenWidth(3);
        dc.setColor(Graphics.COLOR_LT_GRAY, background_color);
        dc.fillCircle(center_x, center_y,2);

    }

    function drawDate(dc,center_x,center_y, screen_width, screen_height) {
        var now = Time.now();

        var date = Time.Gregorian.info(now, Time.FORMAT_MEDIUM);

        var dateStr=date.day_of_week+" "+date.day;

        var font = Graphics.FONT_XTINY;

        //draw the date and week day
        dc.drawText(center_x + screen_width/2 - 25,center_y,font,dateStr,Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawHand(dc, center_x, center_y, length, width, degree, color_left, color_right, draw_line) {


        var target_x = length*Math.cos(degree);
        var target_y = length*Math.sin(degree);

        if(draw_line)
        {
            var tip_deg = 0.2;

            dc.setPenWidth(width);

            dc.setColor(color_left, background_color);
            dc.drawLine(center_x,center_y, center_x + target_x, center_y + target_y);

            var tail_length = length/5.0;

            var left_peak_x = tail_length*Math.cos(Math.PI + degree - tip_deg);
            var left_peak_y = tail_length*Math.sin(Math.PI + degree - tip_deg);

            var right_peak_x = tail_length*Math.cos(Math.PI + degree + tip_deg);
            var right_peak_y = tail_length*Math.sin(Math.PI + degree + tip_deg);

            dc.fillPolygon([[center_x,center_y], [center_x + left_peak_x, center_y + left_peak_y], [center_x + right_peak_x, center_y + right_peak_y]]);


        }

        else
        {
            dc.setPenWidth(1);

            var tip_deg = 0.01 * width;

            var tail_deg = 0.04 * width;


            var tip = length/8.0;

            var left_peak_x = (length - tip)*Math.cos(degree - tip_deg);
            var left_peak_y = (length - tip)*Math.sin(degree - tip_deg);

            var right_peak_x = (length - tip)*Math.cos(degree + tip_deg);
            var right_peak_y = (length - tip)*Math.sin(degree + tip_deg);

            var left_width_x = (width/3.0)*Math.cos(degree - (Math.PI/2.0));
            var left_width_y = (width/3.0)*Math.sin(degree - (Math.PI/2.0));

            var right_width_x = (width/3.0)*Math.cos(degree + (Math.PI/2.0));
            var right_width_y = (width/3.0)*Math.sin(degree + (Math.PI/2.0));

            var tail_length = length/4;

            var tail_left_peak_x = tail_length*Math.cos(Math.PI + degree + tail_deg);
            var tail_left_peak_y = tail_length*Math.sin(Math.PI + degree + tail_deg);

            var tail_right_peak_x = tail_length*Math.cos(Math.PI + degree - tail_deg);
            var tail_right_peak_y = tail_length*Math.sin(Math.PI + degree - tail_deg);

            var tail_end_x = tail_length*Math.cos(Math.PI + degree);
            var tail_end_y = tail_length*Math.sin(Math.PI + degree);

            dc.setColor(color_left, background_color);
            dc.fillPolygon([[center_x,center_y], [center_x  + left_width_x,center_y + left_width_y] ,[center_x + left_peak_x, center_y + left_peak_y], [center_x + target_x, center_y + target_y]]);

            dc.fillPolygon([[center_x,center_y], [center_x  + left_width_x,center_y + left_width_y], [center_x + tail_left_peak_x, center_y + tail_left_peak_y], [center_x + tail_end_x, center_y + tail_end_y]]);


            dc.setColor(color_right, background_color);
            dc.fillPolygon([[center_x,center_y], [center_x  + right_width_x, center_y + right_width_y], [center_x + right_peak_x, center_y + right_peak_y], [center_x + target_x, center_y + target_y]]);
    
            dc.fillPolygon([[center_x,center_y], [center_x  + right_width_x,center_y + right_width_y], [center_x + tail_right_peak_x, center_y + tail_right_peak_y], [center_x + tail_end_x, center_y + tail_end_y]]);


            // dc.fillPolygon([[center_x,center_y], [center_x + tail_left_peak_x, center_y + tail_left_peak_y], [center_x + tail_right_peak_x, center_y + tail_right_peak_y]]);
        }

    }

    function drawTicks(dc, center_x, center_y, screen_width, screen_height, length_long, length_short) {

        var offset = screen_width/2.0;

        // var stats = System.getSystemStats();

        // var battery_percent = stats.battery/100.0;

        // var color_on = Graphics.COLOR_DK_GREEN;

        // color_on = Graphics.COLOR_WHITE;


        // if(battery_percent < 0.2)
        // {
        //     color_on = Graphics.COLOR_RED;
        // }

        // if(battery_percent > 0.2 && battery_percent < 0.5)
        // {
        //     color_on = Graphics.COLOR_YELLOW;
        // }

        // color_on = Graphics.COLOR_WHITE; //for now

        // var color_off = Graphics.COLOR_LT_GRAY;

        // color_off = color_on; //for now

        dc.setColor(foreground_color, background_color);

        dc.setPenWidth(5);

        for (var i = 0 ; i < 12; i++) 
        {
            var start_x = (offset-length_long)*Math.cos((i/12.0)*Math.PI*2.0 - Math.PI/2);
            var end_x = offset*Math.cos((i/12.0)*Math.PI*2.0 - Math.PI/2);

            var start_y = (offset-length_long)*Math.sin((i/12.0)*Math.PI*2.0 - Math.PI/2);
            var end_y = offset*Math.sin((i/12.0)*Math.PI*2.0 - Math.PI/2);

            // if(i/12.0 > battery_percent)
            // {
            //     dc.setColor(foreground_color, background_color);
            // }

            dc.drawLine(center_x + start_x ,center_y + start_y, center_x + end_x, center_y + end_y);
        } 

        dc.setPenWidth(2);

        // dc.setColor(color_on, Graphics.COLOR_BLACK);

        for (var i = 0 ; i < 60; i++) 
        {
            var start_x = (offset-length_short)*Math.cos((i/60.0)*Math.PI*2.0- Math.PI/2 );
            var end_x = offset*Math.cos((i/60.0)*Math.PI*2.0 - Math.PI/2);

            var start_y = (offset-length_short)*Math.sin((i/60.0)*Math.PI*2.0 - Math.PI/2);
            var end_y = offset*Math.sin((i/60.0)*Math.PI*2.0 - Math.PI/2);

            // if(i/60.0 > battery_percent)
            // {
            //     dc.setColor(color_off, Graphics.COLOR_BLACK);
            // }

            dc.drawLine(center_x + start_x ,center_y + start_y, center_x + end_x, center_y + end_y);

        } 

        //System.println(pwr); 
    
    }

    function drawText(dc, center_x, center_y, screen_width, screen_height, draw_date) {

        dc.setPenWidth(2);

        dc.setColor(foreground_color, background_color);


        var offset = screen_width/2.0;

        var length_text = 35;

        var text_steps = 3;

        for (var i = 0; i < 12; i = i + text_steps)
        {
            var hourStr= i;

            if(i == 0)
            {
                hourStr= "12";
            }

            if(i == 3 &&  draw_date == true)
            {
                continue;
            }

            var text_x = (offset-length_text)*Math.cos(((i-3)/12.0)*Math.PI*2.0);

            var text_y = (offset-length_text)*Math.sin(((i-3)/12.0)*Math.PI*2.0);

            if(i == 0 || i == 6)
            {   
                var off = 12-i;

                dc.drawText(center_x + text_x + off,center_y + text_y ,Graphics.FONT_SMALL,hourStr,Graphics.TEXT_JUSTIFY_VCENTER);

            }          
            else 
            {
                dc.drawText(center_x + text_x ,center_y + text_y ,Graphics.FONT_SMALL,hourStr,Graphics.TEXT_JUSTIFY_VCENTER);
            }          
        }
    }
    

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        drawSecondsHand = true;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        drawSecondsHand = false;
    }

}
