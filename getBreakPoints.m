
% input: the contour of the character
% output: the break points
function [domX, domY, domPos] = getBreakPoints(contourX, contourY, mode)
    
    n = length(contourX); % total no of contour points
    domI = zeros(n, 1); % index of the dominant points
    
    % for contour not having 4/8 connected nieghbors
    domX = contourX;
    domY = contourY;
    domPos = 1 : n;
    %return;
        
    % get the chain code of the contour
    chainCode = getChainCode(contourX, contourY);
   
    % ======= find initial set of dominant points ==========
    ip = n;
    for i = 1 : n
        if chainCode(ip) ~= chainCode(i)
            domI(ip) = 1;
        end
        ip = i;
    end
    
    if mode == 2 % open curve
        domI(1) = 1;
        domI(end) = 1;
    end   
    
    domPos = find(domI == 1); % index of initial dominant points    
    domX = contourX(domPos);
    domY = contourY(domPos);