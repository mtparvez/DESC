function segXY = getSegXY(strokeX, strokeY, segStartPos, segEndPos)
    segXY = {};
    segCount = 0;
    nSeg = length(segStartPos);
    for i = 1 : nSeg
        segCount = segCount + 1;
        segX = [strokeX(segStartPos(i):segEndPos(i))];
        segY = [strokeY(segStartPos(i):segEndPos(i))];
        segXY{segCount} = [segY,segX];        
    end
end