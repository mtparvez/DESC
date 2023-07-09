function [domX domY maxThreshold] = incrementalLoosening(contourX, contourY, domX, domY)
    domXtmp = domX;
    domYtmp = domY;
    colSupV = 1;
    [domXtmp domYtmp endConition] = applyCollinearSuppression(contourX, contourY, domXtmp, domYtmp, colSupV,1, 1);    
    while 1
        colSupV = colSupV + .5;
        [domXtmp domYtmp endConition] = applyCollinearSuppression(contourX, contourY, domXtmp, domYtmp, colSupV,1, 1);
        if length(domX) == length(domXtmp)
            break;
        else                
            domX = domXtmp;
            domY = domYtmp;
        end
        if endConition == 1
            break;
        end
    end
    maxThreshold = colSupV-.5;