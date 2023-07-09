function domPos = getDomPos(contourX, contourY, domX, domY)
    n = length(contourX);
    nd = length(domX);
    domPos = zeros(nd, 1);
    j = 1;
    i = 1;
    %while i <= n && j<=nd
    while j<=nd
        if contourX(i) == domX(j) && contourY(i) == domY(j)
            domPos(j) = i;
            j = j + 1;
        end
        i = i + 1;
        if i > n
            i = i - n;
        end
    end