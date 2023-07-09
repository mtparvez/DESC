function [cx, cy] = cleanData(x, y)
    dup = zeros(length(x), 1);
    for i = 1 : length(x)-1
        if (x(i+1) == x(i)) && (y(i+1) == y(i))
            dup(i) = 1;
        end
    end
    remPointsIndex = find(dup == 0);
    cx = x(remPointsIndex);
    cy = y(remPointsIndex);
  
end