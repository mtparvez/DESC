
% implements Constrained Collinear Points Suppression (CCS)

function [domX domY endConition] = applyCollinearSuppression(contourX, contourY, domX, domY, disThr, mode, isCCS)

    %isCCS = 0; % is CCS being applied? Make it 0, if only Collinear Suppression wanted
    ndOld = length(domX);

%     [domX domY] = onePassCollinearSuppression(contourX, contourY, domX, domY, disThr);
%     return;
    while 1
        [domX domY endConition] = onePassCollinearSuppression(contourX, contourY, ...
            domX, domY, disThr, mode, isCCS);
        nd = length(domX);
        %if ndOld == nd || endConition == 1
        if ndOld == nd
            break;
        else
            ndOld = nd;
        end            
    end

function [domX domY endConition] = onePassCollinearSuppression(contourX, contourY, ...
                        domX, domY, disThr, mode, isCCS)

    n = length(contourX);
    nd = length(domX);
    [strength domPos] = getStrength(contourX, contourY, domX, domY);
    disCentroid = zeros(nd,1);
    centroidX = mean(contourX);
    centroidY = mean(contourY);
    for j = 1 : nd
        i = domPos(j);
        disCentroid(j) = sqrt(double((contourX(i)-centroidX)^2+(contourY(i)-centroidY)^2));
    end
    %nodes = cat(2, domPos, strength, disCentroid);
    nodes = cat(2, [1:nd]', domPos, strength, disCentroid);
    sNodes = sortrows(nodes, [3 4]);
    
    isDom = zeros(n,1);
    isDom(domPos) = 1;
    index = find(isDom == 1);
    nd = length(index);

    endConition = 1; % means no more update is possible whatever be the threshold
    for i = 1 : nd % for each possible dom point, weakest first           
        j = sNodes(i, 1); 
        if isDom(index(j)) == 0
            continue;
        end
        if mode == 2 % open curve, don't suppress end points
            if index(j) == 1 || index(j) == n
                continue;
            end
        end
        
        jp = j; % find previous dominant point of j
        while 1
            jp = decrease(jp,1,nd);
            Vp = index(jp);
            if isDom(Vp) == 1
                break;
            end
        end
        jn = j;  % find next dominant point of j
        while 1
            jn = increase(jn,1,nd);
            Vn = index(jn);
            if isDom(Vn) == 1
                break;
            end
        end
        dom1X = contourX(Vp);
        dom1Y = contourY(Vp);
        dom2X = contourX(Vn);
        dom2Y = contourY(Vn);
        x = contourX(index(j));
        y = contourY(index(j));

        d = distancetoVector(x, y, dom1X, dom1Y, dom2X, dom2Y, disThr, isCCS);
        if d >= 0 && d < disThr % distance is less than threshold
            % suppression the point, subject to Constraint 2
            supp = 1; % we will suppress, but...
            
            if isCCS == 1 % are we using CCS?
                for k = 1 : nd % check Constraint 2 for all other points
                    if k ~= j && k ~= jn && k ~= jp && isDom(index(k)) == 1
                        x = contourX(index(k));
                        y = contourY(index(k));
                        d2 = distancetoVector(x, y, dom1X, dom1Y, dom2X, dom2Y, disThr, isCCS);
                        if d2 > 0 && d2 <= d % Constraint 2 is violated
                            supp = 0;
                            break;
                        end
                    end
                end
            end
            
            if supp == 1
                isDom(index(j)) = 0;                
                endConition = 0;
            end
        else
            if d >= 0
                endConition = 0;
            end
        end
    end
    index = find(isDom == 1);
    domX = contourX(index);
    domY = contourY(index);

% computes minimum distance from a point to a line segment
    function d = distancetoVector(x, y, sx, sy, ex, ey, disThr, isCCS)

        if isCCS == 1 % are we using CCS
            cosang1 = sum([ex-sx ey-sy].*[x-sx y-sy]);
            cosang2 = sum([sx-ex sy-ey].*[x-ex y-ey]);
            if cosang1 < 0 || cosang2 < 0 % Constraint 1 is violated
                
                % can compute the minimum distance or return very high
                % distance or return some invalid number (like -1)
                
%                 d1 = sqrt(double((x-sx)^2+(y-sy)^2));
%                 d2 = sqrt(double((x-ex)^2+(y-ey)^2));
%                 if d1 < d2
%                     d = d1;
%                 else
%                     d = d2;
%                 end
    
%                 d = disThr + 1;
                d = -1;
                return;
            end
        end
        
        vx = ex - sx;
        vy = ey - sy;
        vtx = -vy;
        vty = vx;
        v = sqrt(double((vx^2 + vy^2)));
        d = double(double(abs(vtx*(x-sx) + vty*(y-sy)))/v);
    
    function [strength domPos] = getStrength(contourX, contourY, domX, domY)
        n = length(contourX);
        nd = length(domX);
        strength = zeros(nd, 1);
        domPos = zeros(nd, 1);
        if nd == 0
            return;
        end
        j = 1;
        i = 1;
        previ = 1;
        while i <= n && j <= nd
            if domX(j)==contourX(i) && domY(j)==contourY(i)
                strength(j) = strength(j) + i - previ;
                domPos(j) = i;
                j = j + 1;
                previ = i+1;
            end
            i = i + 1;
        end
        strength(1) = strength(1) + n - domPos(nd);
        t = strength(1);
        for j = 1 : nd-1
            strength(j) = strength(j) + strength(j+1);
        end
        strength(nd) = strength(nd) + t;
        
        
    function v = increase(v, incr, limit)
        v = v + incr;
        if v > limit
            v = v - limit;
        end

    function v = decrease(v, decr, limit)
        v = v - decr;
        if v <= 0
            v = limit + v;
        end
        
        
        
        
        
        
        
        
        
        
        