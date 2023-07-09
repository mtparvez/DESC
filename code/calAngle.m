function [angle, len] = calAngle(x1, y1, x2, y2)

    a = (x1-x2)^2 + (y1-y2)^2;
    len = sqrt(double(a));
    b1 = ((x2 - x1));
    if b1 == 0
        if y1 > y2
            angle = 270;
        else
            angle = 90;
        end
        return
    end
    b2 = abs((y2 - y1));
    if b2 == 0
        if x1 < x2
            angle = 0;
        else
            angle = 180;
        end
        return;
    end
    b = double(b2) / len;
    angle = acos(b)*180/pi;    
    if x2 > x1
        if y1 > y2
            angle = 270 + angle;
        else
            angle = 90 - angle;
        end
    else
        if y1 > y2
            angle = 270 - angle;
        else
            angle = 90 + angle;
        end
    end
    
    if angle == 360
        angle = 0;
    end