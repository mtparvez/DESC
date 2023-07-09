function [domX domY] = makeSegmentedOptimization(contourX, contourY, domX, domY, maxColDis)

    useArea = 0;
    n = length(contourX);
    nd = length(domX);
    domPos = getPos(contourX, contourY, domX, domY);
    domX = [];
    domY = [];
    domXtmp=[];
    domYtmp=[];
    for i = 1 : nd
        if i < nd
            x = contourX(domPos(i):domPos(i+1));
            y = contourY(domPos(i):domPos(i+1));
        else
            x = [contourX(domPos(nd):end) contourX(1:domPos(1))];
            y = [contourY(domPos(nd):end) contourY(1:domPos(1))];
        end
        
        [dx dy] = getBreakPoints(x, y, 2);
        
        if useArea == 0 % use distance threshold for suppression        
            %maxColDis = 1.5;
            colDisArray = 1 : .5 : maxColDis;
            errorMin = 9999;
            for j = 1 : length(colDisArray)
                colDis = colDisArray(j);
                [dx dy] = applyCollinearSuppression(x, y, dx, dy, colDis, 2, 1);
                [CR E WE WE2 WE3 LengthRatio] = getPolApproxMeasures(x, y, dx, dy);
                if WE3 < errorMin
                    thr = colDis;
                    errorMin = WE3;
                    domXtmp = dx;
                    domYtmp = dy;
                end
            end
%              disp(['Threshold: ', num2str(thr), '; StartX: ', ...
%                  num2str(x(1)), '; StartY: ', num2str(y(1))]);
            %thrUsed(thr*2) = thrUsed(thr*2) + 1;
%             thrUsed(thr*2) = 1;
        else
            % use area suppression technique
            totArea = polyarea(x, y);
            domXtmp = dx;
            domYtmp = dy;
            areaSupVA = .5 : .5 : totArea;
            %[CR E WE WE2 WE3] = getPolApproxMeasures(x, y, dx, dy);
            errorMin = 999;
            for j = 1 : length(areaSupVA)
            
                areaSupV= areaSupVA(j);
                [dx dy] = applyPolyAreaSuppression(x, y, ...
                    dx, dy, areaSupV, 2);
                [CR E WE WE2 WE3] = getPolApproxMeasures(x, y, dx, dy);
                if WE2 < errorMin && WE2 > 0
                    errorMin = WE2;
                    domXtmp = dx;
                    domYtmp = dy;
                end
            end
        end        
        if i == 1
            domX = [domX domXtmp];
            domY = [domY domYtmp];
        else if i < nd
                domX = [domX domXtmp(2:end)];
                domY = [domY domYtmp(2:end)];
            else
                domX = [domX domXtmp(2:end-1)];
                domY = [domY domYtmp(2:end-1)];
            end
        end
    end    

        
function domPos = getPos(contourX, contourY, domX, domY)
    n = length(contourX);
    nd = length(domX);    
    domPos = zeros(nd, 1);
    j = 1;
    i = 1;
    while j <= nd
        if domX(j)==contourX(i) && domY(j)==contourY(i)            
            domPos(j) = i;
            j = j + 1;
        end
        i = i + 1;
        if i == n+1
            i = 1;
        end
    end