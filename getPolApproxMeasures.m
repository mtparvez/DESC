
% computes different measures of polygonal approximation
% needed for comparinf different approximations
function [CR, E, WE, WE2, WE3, LengthRatio, maxE] = getPolApproxMeasures(contourX, contourY, domX, domY)
       
    n = length(contourX);
    nd = length(domX);
    CR = n/nd;
    
    E = 0;
    domPos = getDomPos(contourX, contourY, domX, domY);
    
    zin = find(domPos == 0);
    if ~isempty(zin)
        domPos = domPos(1:zin(1)-1);
        nd = length(domPos);
    end
    
    maxE = 0;
    for i = 1 : nd
        in = i + 1;
        if in > nd
            in = 1;
        end
        p1 = domPos(i);
        p2 = domPos(in);
        if p1 > p2
            [d mE] = getDistance([contourX(p1:end), contourX(1:p2)], ...
                        [contourY(p1:end), contourY(1:p2)]);
        else
            [d mE] = getDistance(contourX(p1:p2), contourY(p1:p2));
        end
        if(~isnan(d))
            E = E + d;
        end
        if mE > maxE
            maxE = mE;
        end
    end
%     [d mE] = getDistance([contourX(domPos(end):end), contourX(1:domPos(1))], ...
%         [contourY(domPos(end):end), contourY(1:domPos(1))]);
%     E = E + d;
%     if mE > maxE
%         maxE = mE;
%     end
    
    WE = E / CR;
    
    WE2 = WE/CR;
    
    WE3 = WE2/CR;
    
    
    % new measure
    cc = getChainCode(contourX, contourY);
    ip = n;
    curveLen = 0;
    for i = 1 : n
        if cc(i) == 0 || cc(i) == 4
            curveLen = curveLen + 1;
        else
            curveLen = curveLen + 1.4142;
        end
    end
    
    polyLen = 0;
    ip = nd;
    for i = 1 : nd
        polyLen = polyLen + sqrt(double((domX(ip)-domX(i))^2+((domY(ip)-domY(i))^2)));
        ip = i;
    end
    LengthRatio = polyLen/curveLen;

function [d mE] = getDistance(x, y)  
    sx = x(1);    
    sy = y(1);
    ex = x(end);
    ey = y(end);
    d = 0;
    mE = 0;
    for i = 1 : length(x)
        e = distancetoVector(x(i), y(i), sx, sy, ex, ey);
        d = d + e^2;
        if e > mE
            mE = e;
        end
    end



        
function d = distancetoVector(x, y, sx, sy, ex, ey)
    vx = ex - sx;
    vy = ey - sy;
    vtx = -vy;
    vty = vx;
    v = sqrt(double((vx^2 + vy^2)));
    d = double(double(abs(vtx*(x-sx) + vty*(y-sy)))/v);