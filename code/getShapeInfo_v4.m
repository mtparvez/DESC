function [shapeClass, shapeDesc] = getShapeInfo_v4(x, y, angle)
    isCut = 0;    
    % shift the middle point to the origin
    x(1) = x(1) - x(2);
    y(1) = y(1) - y(2);
    x(3) = x(3) - x(2);
    y(3) = y(3) - y(2);
    x(2) = 0;
    y(2) = 0;
    
    [gPos1, sPos1] = locatePosition(x(1), y(1));
    [gPos2, sPos2] = locatePosition(x(3), y(3));

    angleDev = 10;
%     if gPos1 >= 2 && gPos1 <= 5 && gPos2 >= 4 && gPos2 <= 7 && gPos1 <= gPos2
%         isCut = 1;
%     end
%     
%     t = x(1)/(x(1)-x(3));
%     Midy = y(1) + t * (y(3) - y(1));
%     if Midy < 0
%         isCut = 0;
%     end
   
    
    % get the shape info at x(2), y(2)
    % the shape of interest is either a raa-shape (==1) or a raaInv-shape (==2)
    shapeClass = 0;
    shapeDesc = [];
    %global angleList;
    
    if (gPos1 == 1 && sPos1 == 'R' || gPos1 == 8 && sPos1 == 'L') && (gPos2 == 4 && sPos2 == 'L' || gPos2 == 5 && sPos2 == 'R')
        shapeClass = 'u'; % alif-shape
        shapeDesc = 'vert_up';
    
    elseif (gPos2 == 1 && sPos2 == 'R' || gPos2 == 8 && sPos2 == 'L') && (gPos1 == 4 && sPos1 == 'L' || gPos1 == 5 && sPos1 == 'R')
        shapeClass = 'd'; % alif-shape
        shapeDesc = 'vert_down';
    
    elseif (gPos1 == 2 && sPos1 == 'L' || gPos1 == 3 && sPos1 == 'R') && (gPos2 == 6 && sPos2 == 'L' || gPos2 == 7 && sPos2 == 'R')
        shapeClass = 'l'; % alif-shape
        shapeDesc = 'hori_left';
        
        %disp(num2str(abs(angle-180)));
        %angleList(end+1) = abs(angle-180);
    
    elseif (gPos2 == 2 && sPos2 == 'L' || gPos2 == 3 && sPos2 == 'R') && (gPos1 == 6 && sPos1 == 'L' || gPos1 == 7 && sPos1 == 'R')
        shapeClass = 'r'; % alif-shape
        shapeDesc = 'hori_right';
        %disp(num2str(abs(angle-180)));
        %angleList(end+1) = abs(angle-180);
    
    elseif (x(1) < x(3)) &&  (y(1) > y(3))
        leftx = x(1) + 1;
        lefty = y(1);
        pos = getPointPosition(x(1), y(1), x(3), y(3), 0, 0, leftx, lefty);
        if abs(angle-180) < angleDev
            shapeClass = 'w';
            shapeDesc = 'st_right_down';
        elseif pos == 0 %x(2) >= (x(1)+x(3))/2 %angle >= 90 && angle < 180
            shapeClass = 'A';
            shapeDesc = 'cw_right_down'; 
        else%if angle >= 180 && angle <= 270
            shapeClass = 'F';
            shapeDesc = 'ccw_right_down'; 
        end
    elseif (x(1) > x(3)) &&  (y(1) < y(3))
        leftx = x(1) - 1;
        lefty = y(1);
        pos = getPointPosition(x(1), y(1), x(3), y(3), 0, 0, leftx, lefty);
        if abs(angle-180) < angleDev
            shapeClass = 'y';
            shapeDesc = 'st_left_up';
        elseif pos == 1%x(2) >= (x(1)+x(3))/2  %angle >= 90 && angle < 180
            shapeClass = 'H';
            shapeDesc = 'ccw_left_up'; 
        else%if angle >= 180 && angle <= 270
            shapeClass = 'C';
            shapeDesc = 'cw_left_up'; 
        end
    elseif (x(1) > x(3)) &&  (y(1) > y(3))
        leftx = x(1) + 1;
        lefty = y(1);
        pos = getPointPosition(x(1), y(1), x(3), y(3), 0, 0, leftx, lefty);
        if abs(angle-180) < angleDev
            shapeClass = 'x';
            shapeDesc = 'st_left_down';
        elseif pos == 0 %x(2) >= (x(1)+x(3))/2 %angle >= 90 && angle < 180
            shapeClass = 'B';
            shapeDesc = 'cw_left_down'; 
        else%if angle >= 180 && angle <= 270
            shapeClass = 'E';
            shapeDesc = 'ccw_left_down'; 
        end
  
    elseif (x(1) < x(3)) &&  (y(1) < y(3))
        leftx = x(1) - 1;
        lefty = y(1);
        pos = getPointPosition(x(1), y(1), x(3), y(3), 0, 0, leftx, lefty);
        if abs(angle-180) < angleDev
            shapeClass = 'z';
            shapeDesc = 'st_right_up';
        elseif pos == 1 %x(2) >= (x(1)+x(3))/2 %angle >= 90 && angle < 180
            shapeClass = 'G';
            shapeDesc = 'ccw_right_up'; 
        else%if angle >= 180 && angle <= 270
            shapeClass = 'D';
            shapeDesc = 'cw_right_up'; 
        end
%     elseif (gPos1 == 2 || gPos1 == 3) && (gPos2 == 6 || gPos2 == 7)
%         shapeClass = 'L'; % kashida-shape
%         shapeDesc = 'hori_Left';
%     elseif (gPos2 == 2 || gPos2 == 3) && (gPos1 == 6 || gPos1 == 7)
%         shapeClass = 'R'; % kashida-shape
%         shapeDesc = 'hori_Right';
    elseif (gPos1 == 1 && gPos2 == 8) || (gPos1 == 8 || gPos2 == 1)
        shapeClass = 'N'; % ara8-shape
        shapeDesc = 'ara8-shape';
    elseif (gPos1 == 5 && gPos2 == 4) || (gPos1 == 4 || gPos2 == 5)
        shapeClass = 'V'; % ara8-shape
        shapeDesc = 'ara7-shape';
    else
        shapeClass = 'X'; % other-shape
        %shapeDesc = 'Unknown';
    end
end
   
function [gPos, sPos] = locatePosition(x, y)
    gPos = 0;
    sPos = 'A';
    xab = abs(x);
    yab = abs(y);
    if x >= 0 && y >= 0
        if y >= x
            gPos = 4;
            yp = xab * tand(67.5);
            if yab < yp
                sPos = 'R';
            else
                sPos = 'L';
            end
            
        else
            gPos = 3;
            yp = xab * tand(22.5);
            if yab < yp
                sPos = 'R';
            else
                sPos = 'L';
            end
        end
        return;
    end
    if x >= 0 && y <= 0
        if -y >= x
            gPos = 1;
            yp = xab * tand(67.5);
            if yab < yp
                sPos = 'L';
            else
                sPos = 'R';
            end
        else
            gPos = 2;
            yp = xab * tand(22.5);
            if yab < yp
                sPos = 'L';
            else
                sPos = 'R';
            end
        end
        return;
    end
    
    if x <= 0 && y >= 0
        if y >= -x
            gPos = 5;
            yp = xab * tand(67.5);
            if yab < yp
                sPos = 'L';
            else
                sPos = 'R';
            end
        else
            gPos = 6;
            yp = xab * tand(22.5);
            if yab < yp
                sPos = 'L';
            else
                sPos = 'R';
            end
        end
        return;
    end
    if x <= 0 && y <= 0
        if -y >= -x
            gPos = 8;
            yp = xab * tand(67.5);
            if yab < yp
                sPos = 'R';
            else
                sPos = 'L';
            end
        else
            gPos = 7;
            yp = xab * tand(22.5);
            if yab < yp
                sPos = 'R';
            else
                sPos = 'L';
            end
        end
        return;
    end
end
    
function pos = getPointPosition(x1, y1, x2, y2, x, y, leftx, lefty)
    % find whether (x,y) lies on the left side of the line joining (x1,
    % y1) and (x2, y2)
    % it needs a point (leftx, lefty) which is known to be on the left side
    % of the line
    leftSign = (leftx - x1) * (y2 - y1) - (lefty - y1) * (x2 - x1);
    d = (x - x1) * (y2 - y1) - (y - y1) * (x2 - x1);
    
    if leftSign * d > 0 % same sign
        pos = 0; % on the left
    else
        pos = 1; % on the right
    end
end
    
    
    