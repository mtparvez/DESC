function [rx, ry] = reSampleData(x, y)
    rx = [];
    ry = [];
    for i = 1 : length(x)-1
        xDiff = abs(x(i+1) - x(i));
        yDiff = abs(y(i+1) - y(i));
        if xDiff > 1 % points are not 8 connected
           
               % interpolate along x
               rx = [rx, x(i)];
               ry = [ry, y(i)];
               slope = (y(i+1) - y(i))/(x(i+1) - x(i));
               p = 1;
               if(x(i)>x(i+1)) 
                   p = -1;
               end
               for xt = x(i)+p : p : x(i+1)-p
                   yt = y(i) + (xt - x(i))*slope;
                   rx = [rx, xt];
                   ry = [ry, yt];
               end
               rx = [rx, x(i+1)];
               ry = [ry, y(i+1)];
        else
            rx = [rx, x(i), x(i+1)];
            ry = [ry, y(i), y(i+1)];
        end
    end
    x = rx;
    y = ry;
    rx = [];
    ry = [];
    for i = 1 : length(x)-1
        xDiff = abs(x(i+1) - x(i));
        yDiff = abs(y(i+1) - y(i));
        if yDiff > 1 % points are not 8 connected
               % interpolate along y
               rx = [rx, x(i)];
               ry = [ry, y(i)];
               slope = (y(i+1) - y(i))/(x(i+1) - x(i));
               p = 1;
               if(y(i)>y(i+1)) 
                   p = -1;
               end
               for yt = y(i)+p : p : y(i+1)-p
                   xt = x(i) + (yt - y(i))/slope;
                   %yt = y(i) + (xt - x(i))*slope;
                   rx = [rx, xt];
                   ry = [ry, yt];
               end
               rx = [rx, x(i+1)];
               ry = [ry, y(i+1)];
        else
            rx = [rx, x(i), x(i+1)];
            ry = [ry, y(i), y(i+1)];
        end
    end
    rx = rx';
    ry = ry';
end

