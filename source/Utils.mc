var colors =  [ 0x000000,
                0x555555,
                0xAAAAAA,
                0xFFFFFF,
                0x00AAFF,
                0xFF0000,
                0x00FF00,
                0xAA0000,
                0x00AA00,
                0x0000FF,
                0xFF5500,
                0xAA00FF,
                0xFF00FF,
                0xFFFF00,
                0x555500,
                0x00FFFF ]; 


 var color_names =  ["Black", 
                    "Dark Gray", 
                    "Light Gray", 
                    "White", 
                    "Blue", 
                    "Red",  
                    "Green", 
                    "Dark Red",  
                    "Dark Green", 
                    "Dark Blue", 
                    "Orange",  
                    "Purple",       
                    "Pink", 
                    "Yellow",                                       
                    "OliveGreen",     
                    "Turquoise"];   

function colorIndex(code)
{
    return colors.indexOf(code);
}