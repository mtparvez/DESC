function [shapeClass, shapeDesc] = isDirectionChanged(x, y, angle)

    segCode = ['S', 'V', 'C', 'd', 'l', 'r', 's', 't', 'p', 'q', 'm', 'n'];
    segDesc = [{'straight_line'},{'cw_curve'},{'ccw_curve'},{'same_dir'},...
            {'bent_left'},{'bent_right'}, {'bent_left_sharp'},{'bent_right_sharp'}...
            , {'bent_left_perp'},{'bent_right_perp'}, {'bent_left_mod'},{'bent_right_mod'}];
        
    %isCut = 0;    
    % shift the middle point to the origin
    x(1) = x(1) - x(2);
    y(1) = y(1) - y(2);
    x(3) = x(3) - x(2);
    y(3) = y(3) - y(2);
    x(2) = 0;
    y(2) = 0;
    
    [gPos1, sPos1] = locatePosition(x(1), y(1));
    [gPos2, sPos2] = locatePosition(x(3), y(3));

    angleDev = 20;
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
    sharp = 0;
    if gPos1 == mod(gPos2 + 4, 8) 
        shapeClass = 'd'; 
        shapeDesc = 'same_dir';
    else
        if (x(1) <= x(3)) &&  (y(1) >= y(3))
            leftx = x(1) + 1;
            lefty = y(1);
        elseif (x(1) >= x(3)) &&  (y(1) <= y(3))
            leftx = x(1) - 1;
            lefty = y(1);

        elseif (x(1) >= x(3)) &&  (y(1) >= y(3))
            leftx = x(1) + 1;
            lefty = y(1);

        else
        %elseif (x(1) < x(3)) &&  (y(1) < y(3))
            leftx = x(1) - 1;
            lefty = y(1);
        end
        pos = getPointPosition(x(1), y(1), x(3), y(3), 0, 0, leftx, lefty);
        if angle <= 45 %abs(180-angle) > 90
            %disp('Sharp left/right');
            sharp = 1;
        elseif angle <= 90 %abs(180-angle) > 90
            %disp('Sharp left/right');
            sharp = 2;
        else
            sharp = 3;
        end
        
        if pos == 1
            shapeDesc = 'bent_left'; 
        else
            shapeDesc = 'bent_right'; 
        end
        if(sharp == 1)
           shapeDesc = [shapeDesc, '_sharp'];
        elseif(sharp == 2)
           shapeDesc = [shapeDesc, '_perp'];
        elseif(sharp == 3)
           shapeDesc = [shapeDesc, '_mod'];
        end
        index = find(cellfun(@(x) strcmp(x, shapeDesc), segDesc, 'UniformOutput', 1),1);
        shapeClass = segCode(index);
    end
    
    
end
   
function [gPos, sPos] = locatePosition(x, y)
    gPos = -1;
    sPos = 'A';
    xab = abs(x);
    yab = abs(y);
    if x >= 0 && y >= 0
        if y >= x
            gPos = 3;
            yp = xab * tand(67.5);
            if yab < yp
                sPos = 'R';
            else
                sPos = 'L';
            end
            
        else
            gPos = 2;
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
            gPos = 0;
            yp = xab * tand(67.5);
            if yab < yp
                sPos = 'L';
            else
                sPos = 'R';
            end
        else
            gPos = 1;
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
            gPos = 4;
            yp = xab * tand(67.5);
            if yab < yp
                sPos = 'L';
            else
                sPos = 'R';
            end
        else
            gPos = 5;
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
            gPos = 7;
            yp = xab * tand(67.5);
            if yab < yp
                sPos = 'R';
            else
                sPos = 'L';
            end
        else
            gPos = 6;
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
    
    
    