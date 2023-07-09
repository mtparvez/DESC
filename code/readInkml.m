function [allX, allY, PointCount] = readInkml(fName)
    [X, Y, Label, segmentsIndex, strokeLengths] =  ReadXmlFile(fName);
    allX = X(1:strokeLengths(1));
    allY = Y(1:strokeLengths(1)); 
    allX = allX';
    %allY = allY';%max(allY') - allY';
    allX = max(allX) - allX;
    allY = max(allY') - allY';
    PointCount = length(allX);
end