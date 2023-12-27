import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class SimplexView extends WatchUi.WatchFace 
{

    var draw_secondshand_bool;
    var draw_ticks_bool;
    var draw_date_bool;
    var draw_numbers_bool;

    var background_color;
    var foreground_color;
    var foreground_alt_color;
    var left_minute_hand_color;
    var right_minute_hand_color;
    var left_hour_hand_color;
    var right_hour_hand_color;


    var seconds_hand_color;

    var batterySaveMode;
    var timeMinLastUpdate;

    function initialize() 
    {
        WatchFace.initialize();

        draw_secondshand_bool = true;

        background_color = Graphics.COLOR_BLACK;
        foreground_color = Graphics.COLOR_WHITE;
        foreground_alt_color = Graphics.COLOR_LT_GRAY;
        left_minute_hand_color = Graphics.COLOR_LT_GRAY;
        right_minute_hand_color = Graphics.COLOR_WHITE;

        seconds_hand_color = Graphics.COLOR_RED;

        draw_numbers_bool = true;
        draw_ticks_bool= true;

        batterySaveMode = false;
        timeMinLastUpdate = 61;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void 
    {
        // setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void 
    {

        //theme mode (code 0)
        if(Application.Properties.getValue("Mode") as Number == 0)
        {
            //black theme (code 1)
            if(Application.Properties.getValue("Theme") as Number == 1)
            {
                background_color = Graphics.COLOR_BLACK;
                foreground_color = Graphics.COLOR_WHITE;
                foreground_alt_color = Graphics.COLOR_LT_GRAY;
                left_minute_hand_color = Graphics.COLOR_LT_GRAY;
                right_minute_hand_color = Graphics.COLOR_WHITE;
                left_hour_hand_color = Graphics.COLOR_LT_GRAY;
                right_hour_hand_color = Graphics.COLOR_WHITE;

                //seconds_hand_color = Graphics.COLOR_RED;

            }

            //white theme (code 0)
            else 
            {
                background_color = Graphics.COLOR_WHITE;
                foreground_color = Graphics.COLOR_BLACK;
                foreground_alt_color = Graphics.COLOR_LT_GRAY;
                left_minute_hand_color = Graphics.COLOR_DK_GRAY;
                right_minute_hand_color = Graphics.COLOR_BLACK;
                left_hour_hand_color = Graphics.COLOR_DK_GRAY;
                right_hour_hand_color = Graphics.COLOR_BLACK;

                //seconds_hand_color = Graphics.COLOR_RED;
            }
        }

        //custom mode (code 1)
        else
        {
            background_color = Application.Properties.getValue("BackgroundColor") as Number; 
            foreground_color = Application.Properties.getValue("ForegroundColorOne") as Number; 
            foreground_alt_color = Application.Properties.getValue("ForegroundColorTwo") as Number; 
            left_minute_hand_color = Application.Properties.getValue("MinuteHandColorOne") as Number; 
            right_minute_hand_color = Application.Properties.getValue("MinuteHandColorTwo") as Number;
            left_hour_hand_color = Application.Properties.getValue("HourHandColorOne") as Number; 
            right_hour_hand_color = Application.Properties.getValue("HourHandColorTwo") as Number;

            seconds_hand_color = Application.Properties.getValue("SecondsHandColor") as Number; 
        }
        
        // seconds_hand_color = getApp().getProperty("SecondsHandColor") as Number;
        // seconds_hand_color = Graphics.COLOR_RED;

        //color of seconds hand is independent of theme
        seconds_hand_color = Application.Properties.getValue("SecondsHandColor") as Number; 

        draw_date_bool = Application.Properties.getValue("DrawDate") as Number;
        draw_secondshand_bool = Application.Properties.getValue("DrawSecondsHand") as Number;
        draw_numbers_bool = Application.Properties.getValue("DrawNumbers") as Number;



    }

    // Update the view
    function onUpdate(dc as Dc) as Void 
    {
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

        //battery save mode redraws only once per minute
        if(clockTime.min != timeMinLastUpdate || batterySaveMode == false)
        {
            timeMinLastUpdate = clockTime.min;
            //clear the screen
            dc.setColor(background_color, background_color);
            dc.clear();

            dc.setColor(foreground_color, background_color);

            var sec_hand_length = screen_width/2.3f;
            var min_hand_length = screen_width/2.3f;
            var hour_hand_length = screen_width/3.3f;

            var screen_ratio = screen_width/260.0f;

            //ticks length
            var length_long = 15*screen_ratio;
            var length_short = 8*screen_ratio;

            //hands width
            var hours_hand_width = 8.0f;
            var minute_hand_width = 5.0f;

            // draw the date
            if(draw_date_bool)
            {
                drawDate(dc,center_x,center_y, screen_width, screen_height);
            }

            // draw the numbers
            if(draw_numbers_bool)
            {
                drawNumbers(dc,center_x,center_y, screen_width, screen_height, draw_date_bool);
            }

            // draw the ticks
            if(draw_ticks_bool)
            {
                drawTicks(dc,center_x,center_y, screen_width, screen_height, length_long, length_short);
            }

            // draw the hours hand
            drawHand(dc, center_x,center_y, hour_hand_length,hours_hand_width,degHour, left_hour_hand_color, right_hour_hand_color, false);

            // draw the minutes hand
            drawHand(dc, center_x,center_y, min_hand_length,minute_hand_width, degMin, left_minute_hand_color, right_minute_hand_color, false);

            if(draw_secondshand_bool && batterySaveMode == false)
            {
                // draw the seconds hand
                drawHand(dc, center_x,center_y ,sec_hand_length,2,degSec, seconds_hand_color, seconds_hand_color, true);
            }

            //draw the center
            drawCenter(dc, center_x,center_y, seconds_hand_color);

            //for debugging
            // dc.drawText(center_x ,center_y + 20 ,Graphics.FONT_SMALL,""+clockTime.sec,Graphics.TEXT_JUSTIFY_VCENTER);
        }

    }

    function drawCenter(dc, center_x, center_y, seconds_hand_color) 
    {
        //all parameters hardcoded, fix
        var outer_diameter = 3;

        if(draw_secondshand_bool)
        {
            dc.setPenWidth(6);
            dc.setColor(seconds_hand_color, background_color);
            dc.drawCircle(center_x, center_y, 4);
        }

        else
        {
            outer_diameter = 4;
        }

        //colors for the ring are hardcoded
        dc.setPenWidth(outer_diameter);
        dc.setColor(Graphics.COLOR_DK_GRAY, background_color);
        dc.drawCircle(center_x, center_y,outer_diameter);

        dc.setPenWidth(3);
        dc.setColor(Graphics.COLOR_LT_GRAY, background_color);
        dc.fillCircle(center_x, center_y,2);

    }

    function drawDate(dc,center_x,center_y, screen_width, screen_height) 
    {
        var now = Time.now();

        var date = Time.Gregorian.info(now, Time.FORMAT_MEDIUM);

        var dateStr=date.day_of_week+" "+date.day;

        var font = Graphics.FONT_TINY;

        var offset = 25*(screen_width/260.0f);

        //draw the date and week day
        dc.drawText(center_x + screen_width/2 - offset,center_y,font,dateStr,Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawHand(dc, center_x, center_y, length, width, degree, color_left, color_right, draw_line) 
    {


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

        var offset = screen_width/2.0 - 5;

        dc.setColor(foreground_color, background_color);

        dc.setPenWidth(3);

        var start_x = 0;
        var end_x = 0;

        var start_y = 0;
        var end_y = 0;

        for (var i = 0 ; i < 12; i++) 
        {   
            //if text is drawn leave space for numbers, draw the tick for 3 explicitly
            if(draw_numbers_bool ==  false || (i % 3 != 0) || (draw_date_bool && i == 3))
            {
                start_x = (offset-length_long)*Math.cos((i/12.0)*Math.PI*2.0 - Math.PI/2);
                end_x = offset*Math.cos((i/12.0)*Math.PI*2.0 - Math.PI/2);

                start_y = (offset-length_long)*Math.sin((i/12.0)*Math.PI*2.0 - Math.PI/2);
                end_y = offset*Math.sin((i/12.0)*Math.PI*2.0 - Math.PI/2);

                dc.drawLine(center_x + start_x ,center_y + start_y, center_x + end_x, center_y + end_y);
            }
        } 

        dc.setPenWidth(1);

        dc.setColor(foreground_alt_color, background_color);

        for (var i = 0 ; i < 60; i++) 
        {
            if(i % 5 != 0 && (draw_numbers_bool == false || (i != 1 && i != 59)))
            {
                start_x = (offset-length_short)*Math.cos((i/60.0)*Math.PI*2.0- Math.PI/2 );
                end_x = offset*Math.cos((i/60.0)*Math.PI*2.0 - Math.PI/2);

                start_y = (offset-length_short)*Math.sin((i/60.0)*Math.PI*2.0 - Math.PI/2);
                end_y = offset*Math.sin((i/60.0)*Math.PI*2.0 - Math.PI/2);


                dc.drawLine(center_x + start_x ,center_y + start_y, center_x + end_x, center_y + end_y);
            }

        } 

    }

    //draws the numbers for each hour
    function drawNumbers(dc, center_x, center_y, screen_width, screen_height, draw_date) 
    {

        dc.setPenWidth(2);

        dc.setColor(foreground_color, background_color);


        var offset = screen_width/2.0f;
        
        var ratio = screen_width/250.0f;

        //these parameters are somewhat hardcoded and depend only on the screen-dimension. Very hacky and needs to be inmproved 
        var i_offset = 6.0f*ratio; 
        var d_offset = 15.0f*ratio;

        var text_steps = 3;

        for (var i = 0; i < 12; i = i + text_steps)
        {
            var hourStr= i;

            var font = Graphics.FONT_LARGE;

            if(i == 0)
            {
                hourStr= "12";
                font = Graphics.FONT_LARGE;
            }

            if(i == 3 &&  draw_date == true)
            {
                continue;
            }

            var text_x = (offset-d_offset)*Math.cos(((i-3)/12.0f)*Math.PI*2.0f);

            var text_y = (offset-d_offset)*Math.sin(((i-3)/12.0f)*Math.PI*2.0f);

            if(i == 0 || i == 6)
            {
             var i_off = i.toFloat() * i_offset; 

             text_x = (offset)*Math.cos(((i-3)/12.0f)*Math.PI*2.0f);
             text_y = (offset)*Math.sin(((i-3)/12.0f)*Math.PI*2.0f);  

             dc.drawText(center_x + text_x, center_y + text_y - i_off ,font,hourStr,Graphics.TEXT_JUSTIFY_CENTER);  
            }

            else if(i  <=6)
            {   
                var i_off = i.toFloat() * i_offset; 
    
                dc.drawText(center_x + text_x, center_y + text_y - i_off ,font,hourStr,Graphics.TEXT_JUSTIFY_CENTER);

            }
                     
            else 
            {
                var j = 6 - (i % 6);

                var i_off = j.toFloat() * i_offset; 

                dc.drawText(center_x + text_x,center_y + text_y -i_off,font,hourStr,Graphics.TEXT_JUSTIFY_CENTER);
            }          
        }
    }
    

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void 
    {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void 
    {
        draw_secondshand_bool = true;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void 
    {
        draw_secondshand_bool = false;
    }

//     //uncomment this for watchface diagnostics
//     function onPartialUpdate( dc ) 
//     {
//     	draw_secondshand_bool = true;
//         onUpdate(dc);
//     }

}