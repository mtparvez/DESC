% This function returns a polygonal approximation of a digital planar curve
% Input: 
%       [contourX, contourY] : the (x, y) co-ordinates of the curve
%                               boundary
%       mode : 1 for closed curve, 2 for open curve
%
% Output:
%       [domX domY] : the (x, y) co-ordinates of the vertices of the
%       approximated polygon

function  [domX, domY, mThr] = getPolygonalAppoximation(contourX, contourY, mode)    
%     fname = 'd:\Thesis\_MyCode\PRThesis_level1\data\ae07_012.BMP';
%     mode = 1;
%     I = imread(fname);
%     %I = I';
%     if ~islogical(I)
%         level = graythresh(I);
%         I = im2bw(I, level);
%         %I = im2bw(I, .5);
%     end    
%     [contourX contourY] = getContourML(I, []);
    if size(contourX, 1) > 1 % this is a column vector
        % make it a row vector
        contourX = contourX';
        contourY = contourY';
    end
    [domX, domY] = getBreakPoints(contourX, contourY, mode);
    [domX, domY, mThr] = incrementalLoosening(contourX, contourY, domX, domY);
    %disp(['Ending dcol = ', num2str(mThr)]);    
    
    [domX, domY] = makeSegmentedOptimization(contourX, contourY, domX, domY, mThr);
    
    
   
    
   
    