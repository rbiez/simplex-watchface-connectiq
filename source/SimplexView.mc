import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class SimplexView extends WatchUi.WatchFace 
{

    private var draw_secondshand_bool;
    private var draw_minuteticks_bool;
    private var draw_hourticks_bool;
    private var draw_date_bool;
    private var draw_numbers_bool;

    private var secondshand_mode;

    private var background_color;
    private var foreground_color;
    private var foreground_alt_color;
    private var left_minute_hand_color;
    private var right_minute_hand_color;
    private var left_hour_hand_color;
    private var right_hour_hand_color;
    private var seconds_hand_color;

    private var is_in_sleepmode;


    private var offscreen_buffer as BufferedBitmap?;

    private var clip_x_old;
    private var clip_y_old;
    private var clip_height_old;
    private var clip_width_old;

    private var hour_hand_width;
    private var minute_hand_width;

    private var hour_hand_length_setting;
    private var minute_hand_length_setting;
    private var seconds_hand_length_setting;

    private var hour_hand_thinning;
    private var minute_hand_thinning;

    private var version as Number;
    private var is_touch as Boolean;

    function loadSettings()
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
            // background_color = Application.Properties.getValue("BackgroundColor") as Number; 
            // foreground_color = Application.Properties.getValue("ForegroundColorOne") as Number; 
            // foreground_alt_color = Application.Properties.getValue("ForegroundColorTwo") as Number; 
            // left_minute_hand_color = Application.Properties.getValue("MinuteHandColorOne") as Number; 
            // right_minute_hand_color = Application.Properties.getValue("MinuteHandColorTwo") as Number;
            // left_hour_hand_color = Application.Properties.getValue("HourHandColorOne") as Number; 
            // right_hour_hand_color = Application.Properties.getValue("HourHandColorTwo") as Number;

            // seconds_hand_color = Application.Properties.getValue("SecondsHandColor") as Number; 

            background_color = loadColorSettings("BackgroundColor") as Number; 
            foreground_color = loadColorSettings("ForegroundColorOne") as Number; 
            foreground_alt_color = loadColorSettings("ForegroundColorTwo") as Number; 
            left_minute_hand_color = loadColorSettings("MinuteHandColorOne") as Number; 
            right_minute_hand_color = loadColorSettings("MinuteHandColorTwo") as Number;
            left_hour_hand_color = loadColorSettings("HourHandColorOne") as Number; 
            right_hour_hand_color = loadColorSettings("HourHandColorTwo") as Number;

            seconds_hand_color = loadColorSettings("SecondsHandColor") as Number; 
        }
        
        // seconds_hand_color = getApp().getProperty("SecondsHandColor") as Number;
        // seconds_hand_color = Graphics.COLOR_RED;

        hour_hand_width = Application.Properties.getValue("HourHandWidth") as Number;
        minute_hand_width = Application.Properties.getValue("MinuteHandWidth") as Number;

        hour_hand_length_setting = Application.Properties.getValue("HourHandLength") as Number;
        minute_hand_length_setting = Application.Properties.getValue("MinuteHandLength") as Number;
        seconds_hand_length_setting = Application.Properties.getValue("SecondsHandLength") as Number;

        hour_hand_thinning = Application.Properties.getValue("HourHandThinning") as Number;
        minute_hand_thinning = Application.Properties.getValue("MinuteHandThinning") as Number;

        //color of seconds hand is independent of theme
        seconds_hand_color = loadColorSettings("SecondsHandColor") as Number; 

        draw_date_bool = Application.Properties.getValue("DrawDate") as Number;
        draw_secondshand_bool = Application.Properties.getValue("DrawSecondsHand") as Number;
        secondshand_mode = Application.Properties.getValue("SecondsHandMode") as Number;
        draw_numbers_bool = Application.Properties.getValue("DrawNumbers") as Number;
        draw_minuteticks_bool = Application.Properties.getValue("DrawMinuteTicks") as Number;
        draw_hourticks_bool = Application.Properties.getValue("DrawHourTicks") as Number;

        //if the watch does not support partial updates we force the second hand mode to gesture mode
        if(! (WatchUi.WatchFace has :onPartialUpdate))
        {
            //System.println("Has no partial update");
            secondshand_mode = 0;
        }


    }


    function createOffscreenBuffer(dc as Dc)
    {
        var offscreen_buffer_options = {
                :width=>dc.getWidth(),
                :height=>dc.getHeight()
            };

        //offscreen_buffer = new Graphics.BufferedBitmap(offscreen_buffer_options);

        //offscreen_buffer = Graphics.createBufferedBitmap(offscreen_buffer_options).get();

        if (Graphics has :createBufferedBitmap) 
        {
            // System.println("has createBufferedBitmap");
            offscreen_buffer = Graphics.createBufferedBitmap(offscreen_buffer_options).get();
        } 

        else 
        {   
            //older devices, this is somewhat less efficient and use smore heap
            // System.println("does not have createBufferedBitmap");
            offscreen_buffer = new Graphics.BufferedBitmap(offscreen_buffer_options);
        }
    }

    function initialize() 
    {
        WatchFace.initialize();

        draw_secondshand_bool = true;
        draw_date_bool = true;

        background_color = Graphics.COLOR_BLACK;
        foreground_color = Graphics.COLOR_WHITE;
        foreground_alt_color = Graphics.COLOR_LT_GRAY;
        left_minute_hand_color = Graphics.COLOR_LT_GRAY;
        right_minute_hand_color = Graphics.COLOR_WHITE;

        seconds_hand_color = Graphics.COLOR_DK_RED;

        draw_numbers_bool = true;
        draw_minuteticks_bool= true;
        draw_hourticks_bool= true;
        
        hour_hand_width = 7.0f;
        minute_hand_width = 4.0f;

        hour_hand_length_setting = 3.0f;
        minute_hand_length_setting = 7.0f;
        seconds_hand_length_setting = 7.0f;

        hour_hand_thinning = 8.0f;
        minute_hand_thinning = 4.0f;

        secondshand_mode = 0;

        is_in_sleepmode = false;

        clip_x_old = 0;
        clip_y_old = 0;
        clip_height_old = 0;
        clip_width_old = 0;

        version = 0;

        is_touch = false;

        version = Lang.format("$1$$2$$3$",System.getDeviceSettings().monkeyVersion).toNumber();

        is_touch = System.getDeviceSettings().isTouchScreen;

        // System.println(is_touch);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void 
    {
        createOffscreenBuffer(dc);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void 
    {
        loadSettings();
    }

    function drawOffscreenBuffer(dc as Dc)
    {
        dc.drawBitmap(0, 0, offscreen_buffer);
    }

    // Update the view
    function onUpdate(targetDc as Dc) as Void 
    {
        //we do a full redraw
        targetDc.clearClip();

        //we first draw background and minute and hour hand into the buffer
        var dc = offscreen_buffer.getDc();

        var screen_width = dc.getWidth();
        var screen_height = dc.getHeight();
        var center_x = Math.round(screen_width/2.0).toNumber();
        var center_y = Math.round(screen_height/2.0).toNumber();

        var clockTime = System.getClockTime();

        var degMin =  2*Math.PI*(clockTime.min/60.0) - Math.PI/2.0;
        var degHour = 2*Math.PI*((clockTime.hour + clockTime.min/60.0) /12.0) - Math.PI/2;

        //clear the screen
        dc.setColor(background_color, background_color);
        dc.clear();

        var min_hand_length = screen_width/(3.3f + 0.25*(3.0 - minute_hand_length_setting));
        var hour_hand_length = screen_width/(3.3f + 0.25*(3.0 - hour_hand_length_setting));
        // var sec_hand_length = screen_width/2.3f;

        var screen_ratio = screen_width/260.0f;

        //ticks length
        var length_long = 15*screen_ratio;
        var length_short = 8*screen_ratio;


        // draw the date
        if(draw_date_bool)
        {
            drawDate(dc, center_x, center_y, screen_width, screen_height);
        }

        // draw the numbers
        if(draw_numbers_bool)
        {
            drawNumbers(dc,center_x,center_y, screen_width, screen_height, draw_date_bool);
        }


        drawTicks(dc,center_x,center_y, screen_width, screen_height, length_long, length_short);


        // draw the hours hand
        drawHand(dc, center_x,center_y, hour_hand_length,hour_hand_width, hour_hand_thinning,degHour, left_hour_hand_color, right_hour_hand_color);

        // draw the minutes hand
        drawHand(dc, center_x,center_y, min_hand_length,minute_hand_width, minute_hand_thinning ,degMin, left_minute_hand_color, right_minute_hand_color);

        //draw buffer containing the background and hour and minute hand  
        drawOffscreenBuffer(targetDc);

        if(is_in_sleepmode ==  false && draw_secondshand_bool)
        {
            //draw without clipping
            drawSecondsHand(targetDc, false, seconds_hand_length_setting);

            // System.println("case 1");
        }

        else if(is_in_sleepmode ==  true && draw_secondshand_bool && secondshand_mode == 1)
        {
            //when we enter sleepmode we start clippng
            drawSecondsHand(targetDc, true, seconds_hand_length_setting);

            // System.println("case 2");
        }

        //draw the center
        drawCenter(targetDc, center_x,center_y, seconds_hand_color);


        //for debugging
        // dc.drawText(center_x ,center_y + 20 ,Graphics.FONT_SMALL,""+clockTime.sec,Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawCenter(dc, center_x, center_y, seconds_hand_color) 
    {

        var screen_width = dc.getWidth();

        var ratio =  screen_width/260.0f;

        //all parameters hardcoded, fix
        var outer_diameter = (3*ratio + 0.5f).toNumber();

        //colors for the ring are hardcoded
        dc.setPenWidth(outer_diameter);
        dc.setColor(Graphics.COLOR_DK_GRAY, background_color);
        dc.drawCircle(center_x, center_y,outer_diameter);

        dc.setPenWidth(outer_diameter);
        dc.setColor(Graphics.COLOR_LT_GRAY, background_color);
        dc.fillCircle(center_x, center_y,2);

    }

    function drawDate(dc,center_x,center_y, screen_width, screen_height) 
    {
        var now = Time.now();

        var date = Time.Gregorian.info(now, Time.FORMAT_MEDIUM);

        var dateStr = date.day_of_week + " " + date.day;

        var font = Graphics.FONT_TINY;

        var offset = 25*(screen_width/260.0f);

        dc.setColor(foreground_color, background_color);

        //draw the date and week day
        dc.drawText(center_x + screen_width/2 - offset, center_y, font, dateStr, Graphics.TEXT_JUSTIFY_VCENTER);

    }

    function drawHand(dc, center_x, center_y, length, width, thinning, degree, color_left, color_right) 
    {
        var screen_width = dc.getWidth();
        
        var target_x = length*Math.cos(degree);
        var target_y = length*Math.sin(degree);

    
        dc.setPenWidth(1);

        var tip_deg = 0.01 * width;

        var tail_deg = 0.04 * width;


        var tip = length/8.0;


        thinning = (thinning/4.0f) + 1;

        var left_peak_x = (length - tip )*Math.cos(degree - tip_deg);
        var left_peak_y = (length - tip )*Math.sin(degree - tip_deg);

        var right_peak_x = (length - tip)*Math.cos(degree + tip_deg);
        var right_peak_y = (length - tip)*Math.sin(degree + tip_deg);

        var left_width_x = ((width/thinning )*Math.cos(degree - (Math.PI/2.0)));
        var left_width_y = ((width/thinning )*Math.sin(degree - (Math.PI/2.0)));

        var right_width_x = ((width/thinning)*Math.cos(degree + (Math.PI/2.0)));
        var right_width_y = ((width/thinning)*Math.sin(degree + (Math.PI/2.0)));

        var tail_length = length/4;

        var tail_left_peak_x = (tail_length)*Math.cos(Math.PI + degree + tail_deg);
        var tail_left_peak_y = (tail_length)*Math.sin(Math.PI + degree + tail_deg);

        var tail_right_peak_x = tail_length*Math.cos(Math.PI + degree - tail_deg);
        var tail_right_peak_y = tail_length*Math.sin(Math.PI + degree - tail_deg);

        var tail_end_x = tail_length*Math.cos(Math.PI + degree);
        var tail_end_y = tail_length*Math.sin(Math.PI + degree);

        dc.setPenWidth(1);

        dc.setColor(color_left, background_color);
        dc.fillPolygon([[center_x,center_y], [center_x  + left_width_x, center_y + left_width_y] ,[center_x + left_peak_x, center_y + left_peak_y], [center_x + target_x, center_y + target_y]]);

        dc.fillPolygon([[center_x,center_y], [center_x  + left_width_x, center_y + left_width_y], [center_x + tail_left_peak_x, center_y + tail_left_peak_y], [center_x + tail_end_x, center_y + tail_end_y]]);


        // //shift the center to draw the other part of the hand
        var shift_x = Math.round(Math.cos(degree + (Math.PI/2.0)));
        var shift_y = Math.round(Math.sin(degree + (Math.PI/2.0)));
        
        //for (small screens on) older versions we do not shift due to rendering bugs
        if((version <= 420) || (is_touch == false))
        {
            shift_x = 0;
            shift_y = 0;
            //System.println("no shift");
        }

        center_x = center_x + shift_x;
        center_y = center_y + shift_y;

        dc.setColor(color_right, background_color);
        dc.fillPolygon([[center_x,center_y], [center_x  + right_width_x, center_y + right_width_y], [center_x + right_peak_x, center_y + right_peak_y], [center_x + target_x, center_y + target_y]]);

        dc.fillPolygon([[center_x,center_y], [center_x  + right_width_x, center_y + right_width_y], [center_x + tail_right_peak_x, center_y + tail_right_peak_y], [center_x + tail_end_x, center_y + tail_end_y]]);

        // dc.fillPolygon([[center_x,center_y], [center_x + tail_left_peak_x, center_y + tail_left_peak_y], [center_x + tail_right_peak_x, center_y + tail_right_peak_y]]);
    
    }

    function drawTicks(dc, center_x, center_y, screen_width, screen_height, length_long, length_short) 
    {

        var offset = screen_width/2.0f - 5;

        var ratio = screen_width/200.0f;

        var width_hour_ticks = (3*ratio).toNumber();
        var width_minute_ticks = (1*ratio).toNumber();

        var start_x = 0;
        var end_x = 0;

        var start_y = 0;
        var end_y = 0;

        // var width_hour_ticks = 3;
        // var width_minute_ticks = 1;
        // System.println(width_hour_ticks);
        // System.println(width_minute_ticks);

        if(draw_hourticks_bool)
        {
            dc.setColor(foreground_color, background_color);

            dc.setPenWidth(width_hour_ticks);

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
        }

        if(draw_minuteticks_bool)
        {
            dc.setPenWidth(width_minute_ticks);

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

    }

    //draws the numbers for each hour
    function drawNumbers(dc, center_x, center_y, screen_width, screen_height, draw_date) 
    {

        //dc.setPenWidth(2);

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
        is_in_sleepmode = false;
        WatchUi.requestUpdate();   
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void 
    {   
        is_in_sleepmode = true;
        WatchUi.requestUpdate();
    }

    function drawSecondsHand(dc, do_clipping, length)
    {
        var screen_width = dc.getWidth();
        var screen_height = dc.getHeight();
        var clockTime = System.getClockTime();

        var center_x = screen_width/2.0f;
        var center_y = screen_height/2.0f;
        var degSec =  2*Math.PI*(clockTime.sec/60.0f) - Math.PI/2.0f;
        // var sec_hand_length = screen_width/2.3f;
        var sec_hand_length = screen_width/(3.3f + 0.25f*(3.0f - seconds_hand_length_setting));

        //dc.clear();

        //compute the clipping region
        var target_x = center_x + sec_hand_length*Math.cos(degSec);
        var target_y = center_y + sec_hand_length*Math.sin(degSec);

        var clip_x = 0;
        var clip_y = 0;
        var clip_height = 0;
        var clip_width = 0;

        var ratio = screen_width/260.0f;

        var width = (2*(screen_width/200.0f)).toNumber();
        var tip_deg = 0.2f;

        var tail_length = sec_hand_length/5.0f;

        var left_peak_x = center_x + tail_length*Math.cos(Math.PI + degSec - tip_deg);
        var left_peak_y = center_y + tail_length*Math.sin(Math.PI + degSec - tip_deg);

        var right_peak_x = center_x + tail_length*Math.cos(Math.PI + degSec + tip_deg);
        var right_peak_y = center_y + tail_length*Math.sin(Math.PI + degSec + tip_deg);

        var ring_radius = (7*ratio).toNumber();
        
        //compute the clipping area around the seconds hand
        if(clockTime.sec == 0)
        {
            clip_x = center_x - ring_radius;
            clip_y = target_y;
            clip_width = ring_radius*2 + width;
            clip_height = left_peak_y - target_y + width;
        }

        else if(clockTime.sec > 0 && clockTime.sec < 15)
        {   
            clip_x = right_peak_x;
            clip_y = target_y;
            clip_width = target_x - right_peak_x + width;
            clip_height = left_peak_y - target_y + width;

            // System.println("1");
            
        }

        else if(clockTime.sec == 15)
        {
            clip_x = right_peak_x;
            clip_y = center_y - ring_radius;
            clip_width = target_x -left_peak_x;
            clip_height = ring_radius*2;
        }

        else if(clockTime.sec > 15 && clockTime.sec < 30)
        {   
            clip_x = left_peak_x;
            clip_y = right_peak_y; 
            clip_width = target_x -left_peak_x + width;
            clip_height = target_y - right_peak_y + width;
            // clip_height = max(target_y - right_peak_y, left_peak_y - right_peak_y);

            // System.println("2");
            
        }

        else if(clockTime.sec == 30)
        {
            clip_x = center_x - ring_radius;
            clip_y = left_peak_y;
            clip_width = ring_radius*2 + width;
            clip_height = target_y - right_peak_y;
        }

        else if(clockTime.sec > 30 && clockTime.sec < 45)
        {   
            clip_x = target_x;
            clip_y = left_peak_y;
            // clip_width = max(right_peak_x - target_x, right_peak_x - left_peak_x);
            clip_width = right_peak_x - target_x;
            clip_height = target_y - left_peak_y + width;

            // System.println("3");
            
        }

        else if(clockTime.sec == 45)
        {
            clip_x = target_x;
            clip_y = center_y - ring_radius;
            clip_width = left_peak_x - target_x;
            clip_height = ring_radius*2 + width;
        }

        else if(clockTime.sec > 45 && clockTime.sec < 60)
        {   
            clip_x = target_x;
            clip_y = target_y - width;
            clip_width = left_peak_x - target_x;
            clip_height = right_peak_y - target_y + width;

            // System.println("4");
        }

        if(do_clipping)
        {
            dc.setClip(clip_x_old, clip_y_old, clip_width_old , clip_height_old);

            //draw the saved buffer in the previous clipping area to overdraw the old hand
            drawOffscreenBuffer(dc);

            //set the new clipping area around the new location of the seconds hand
            dc.setClip(clip_x, clip_y, clip_width , clip_height);
        }

        //for debugging to draw a rectangle around the clipping area
        // dc.setColor(foreground_color, background_color);
        // dc.drawRectangle(clip_x+2, clip_y+2, clip_width-2, clip_height-2);

        dc.setPenWidth(width);

        dc.setColor(seconds_hand_color, background_color);

        //this draws the line pof the second hand
        dc.drawLine(center_x,center_y, target_x, target_y);

        //this draws the tail
        dc.fillPolygon([[center_x,center_y], [left_peak_x, left_peak_y], [right_peak_x, right_peak_y]]);

        //draw the ring around seconds hand
        //dc.setPenWidth(6);
        dc.setColor(seconds_hand_color, background_color);
        dc.fillCircle(center_x, center_y, ring_radius);

        //draw the center
        drawCenter(dc, center_x,center_y, seconds_hand_color);

        clip_x_old = clip_x;
        clip_y_old = clip_y;
        clip_height_old = clip_height;
        clip_width_old = clip_width;
    }

    function onPartialUpdate( dc ) 
    {        
        if(secondshand_mode == 1 && draw_secondshand_bool)
        {
            drawSecondsHand(dc, true, seconds_hand_length_setting);
        }

        //for debugging to check execution time of whole redraw routine
        //onUpdate(dc);
    }

}

//! Receives watch face events
class SimplexDelegate extends WatchUi.WatchFaceDelegate 
{
    private var _view as SimplexView;

    //! Constructor
    //! @param view The analog view
    public function initialize(view as SimplexView) 
    {
        WatchFaceDelegate.initialize();
        _view = view;
    }

    //! The onPowerBudgetExceeded callback is called by the system if the
    //! onPartialUpdate method exceeds the allowed power budget. If this occurs,
    //! the system will stop invoking onPartialUpdate each second, so we notify the
    //! view here to let the rendering methods know they should not be rendering a
    //! second hand.
    //! @param powerInfo Information about the power budget
    public function onPowerBudgetExceeded(powerInfo as WatchFacePowerInfo) as Void 
    {
        System.println("Average execution time: " + powerInfo.executionTimeAverage);
        System.println("Allowed execution time: " + powerInfo.executionTimeLimit);
        
        //if we exceed the powerbudget we set the seconds hand mode to draw only after a gesture
        Application.Properties.setValue("SecondsHandMode", 0);


        //for debugging
        // Application.Properties.setValue("NeededExTime", powerInfo.executionTimeAverage);
        // Application.Properties.setValue("AllowedExTime", powerInfo.executionTimeLimit);

        _view.loadSettings();
    }
}