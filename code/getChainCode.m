function chain = getChainCode(contourX, contourY)
        n = length(contourX);
        chain = zeros(n,1);
        adjustX = [1 1 0 -1 -1 -1 0 1];
        adjustY = [0 1 1 1 0 -1 -1 -1];
        ip = n;
        for i = 1 : n
            for j = 1 : 8
                nx = contourX(ip) + adjustX(j);
                ny = contourY(ip) + adjustY(j);
                if contourX(i) == nx && contourY(i) == ny
                    chain(i) = j - 1;
                    break;
                end
            end
            ip = i;
        end