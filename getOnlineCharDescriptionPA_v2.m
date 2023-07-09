
function [descShape, descCode, segStartPos, segEndPos, segLenghts, segXY] = ...
    getOnlineCharDescriptionPA_v2(strokeX, strokeY, segLens, repParam)
    isDebug = 0;

    
    descCode = [];
    descShape = [];
    segStartPos = [];
    segEndPos = [];
    %segLenghts = [];
    
%     % read the char data
%     [X, Y, Label, segmentsIndex, strokeLengths] = ReadXmlFile(fName);
% 
%     % find main body index
%     [~, mBodIn] = max(strokeLengths);
% 
% 
%     startIndex = segmentsIndex(mBodIn);            
%     endIndex = segmentsIndex(mBodIn+1) - 1;
% 
%     X = max(X) - X;    
%     Y = max(Y) - Y;
%     strokeX = X(startIndex:endIndex);
%     strokeY = Y(startIndex:endIndex);
% 
%     if isempty(strokeX)
%         disp(['Error for file: ' fName]);
%         return;
%     end
% 
%     [strokeX, strokeY] = cleanData(strokeX, strokeY);
%     %[strokeX, strokeY] = reSampleData(strokeX, strokeY);


    %[domX, domY] = getPolygonalAppoximation(strokeX, strokeY, 2);

    if ~isempty(segLens)
        np = length(strokeX);
        segEnds = cumsum(segLens);
        domPos = [1; int32(cumsum(segLens) * np)];
        domX = strokeX(domPos);
        domY = strokeY(domPos);
    else
        colSupV = repParam.supThr;
        [domX, domY, ~] = applyCollinearSuppression(strokeX, strokeY, strokeX, strokeY, colSupV, 2, 1); 
        % remove any duplicated points - rare case where line may cross
        % itself and both points are selected.
    end


    if isDebug == 1
        figure(1);
        plot(strokeX, strokeY);
        hold on;
        plot(domX, domY, 'ob');
    end

    % hacking for the case with only two dom points
    if length(domX) == 2
        %domX = [domX; domX(end)];
        %domY = [domY; domY(end)];
        mid = idivide(int32(length(strokeX)), int32(2));
        domX = [domX(1); strokeX(mid); domX(2)];
        domY = [domY(1); strokeY(mid); domY(2)];
    end

    % remove points based on minimum segment length
    %[strength, domPos] = getStrength(strokeX, strokeY, domX, domY);
    [domX, domY] = suppressPointUsingSegmLen(strokeX, strokeY, domX, domY, repParam.minSegLen);
    
    % suppress using segment descriptors
    maxThr = repParam.supThr;
    
%     if iscolumn(domY)
%         cornerpoints = [domY, domX];
%     else
%         cornerpoints = [domY', domX'];
%     end
%     CPlength = length(cornerpoints);
%     
%     myparams.CurveModel = 3;
%     myparams.TangentVectorCalc = 1;
%     myparams.OptimizationMethod = 6;
%     myparams.WithIntermediatePts = 0;
%     
%     contours = {[strokeY, strokeX]};
%     mode = 2; % open curve
%     [cornerpoints,CPlength] = applySplineSuppression_v3(contours,{cornerpoints},{CPlength}, myparams, maxThr, mode, repParam);
%     
%     cornerpoints = cornerpoints{1};
%     domPos = cornerpoints(:, 3);
%     domX = strokeX(domPos);
%     domY = strokeY(domPos);
%     
    np = length(strokeX);
    nd = length(domX);
    domPos = getDomPos(strokeX, strokeY, domX, domY);

%     domY = domY + 0 ;
%     strokeY(domPos) = domY;    
%     domX = domX + 0;
%     strokeX(domPos) = domX;
    
    oldShapeClass = 0;

    if isDebug == 1
        disp('** Start of description for connected component **');           
    end
    
    segCount = 0;
    %for idom = 2 : nd -1
    segXY = {};
    descShape = [];
    
    iStrictLevel = repParam.repLevel;
    isRotationInv = repParam.rotationInvariant;
        
    for idom = 1 : nd -1
        %xCord = [domX(idom-1) domX(idom) domX(idom+1)];
        %yCord = [domY(idom-1) domY(idom) domY(idom+1)];
        mid = idivide(int32(domPos(idom)+domPos(idom+1)), int32(2));
        xCord = [domX(idom) strokeX(mid) domX(idom+1)];
        yCord = [domY(idom) strokeY(mid) domY(idom+1)];

        %[shapeClass, shapeDesc] = getShapeInfo(xCord, yCord);
        %[shapeClass, shapeDesc] = getShapeInfo_v3(xCord, yCord);
        angle1 = calAngle(xCord(2), yCord(2), xCord(1), yCord(1));
        angle2 = calAngle(xCord(2), yCord(2), xCord(3), yCord(3));
        diffAng = abs(angle2-angle1);       
        
        
        if isRotationInv == 1
%             idom
%             nPoint = abs(domPos(idom) - domPos(idom+1));
%             nVote = 5;
%             span = idivide(nPoint, int32(nVote));
%             for v = 1 : nVote - 1
%                 mid = domPos(idom) + v*span;
%                 xCordt = [domX(idom) strokeX(mid) domX(idom+1)];
%                 yCordt = [domY(idom) strokeY(mid) domY(idom+1)];            
%                 [shapeClass, shapeDesc] = getRotationInvariantShapeInfo(xCordt, yCordt, []);
%                 shapeDesc
%             end
            [shapeClass, shapeDesc] = getRotationInvariantShapeInfo(xCord, yCord, diffAng);
            % calculate angle with the previous line
            delta = 10;
            if idom > 1
                xCord = [strokeX(max(1,domPos(idom)-delta)) domX(idom) strokeX(min(length(strokeX),domPos(idom)+delta))];
                yCord = [strokeY(max(1,domPos(idom)-delta)) domY(idom) strokeY(min(length(strokeY),domPos(idom)+delta))];
                
                %xCord = [domX(idom-1) domX(idom) domX(idom+1)];
                %yCord = [domY(idom-1) domY(idom) domY(idom+1)];
                angle1 = calAngle(xCord(1), yCord(1), xCord(2), yCord(2));
                angle2 = calAngle(xCord(2), yCord(2), xCord(3), yCord(3));
                diffAng = angle1-angle2;       
                
                % min angle between the line segments
                p1 = [xCord(1), yCord(1)];
                p2 = [xCord(2), yCord(2)];
                p3 = [xCord(3), yCord(3)];
                v1 = p2 - p1; 
                v2 = p2 - p3;                
                a1 = mod(atan2( det([v1;v2;]) , dot(v1,v2) ), 2*pi );
                angleout = 180 * abs((a1>pi/2)*pi-a1) / pi;
                %angleout = min(angleout, abs(360-angleout));
                [midShapeClass, midShapeDesc] = isDirectionChanged(xCord, yCord, angleout);                
            end
        elseif iStrictLevel == 3
            [shapeClass, shapeDesc] = getShapeInfoVeryRelaxed(xCord, yCord, diffAng);
        elseif iStrictLevel == 2
            [shapeClass, shapeDesc] = getShapeInfoRelaxed(xCord, yCord, diffAng);
        elseif iStrictLevel == 1 || iStrictLevel == 7
            [shapeClass, shapeDesc] = getShapeInfo_v4(xCord, yCord, diffAng);
            %[shapeClass, shapeDesc] = getShapeInfo_v3(xCord, yCord, diffAng);
        elseif iStrictLevel == 4
            [shapeClass, shapeDesc] = getShapeInfoUndir(xCord, yCord, diffAng);
        elseif iStrictLevel == 5 || iStrictLevel == 6 || iStrictLevel == 8
            [shapeClass, shapeDesc] = getShapeInfoRelaxed(xCord, yCord, diffAng);
            %[shapeClass, shapeDesc] = getShapeInfo_v4(xCord, yCord, diffAng);  
            %[shapeClass, shapeDesc] = getShapeInfoVeryRelaxed(xCord, yCord, diffAng);
        end
        %segLRatio = (domPos(idom+1) - domPos(idom))/np;
        %if shapeClass == oldShapeClass || isempty(shapeDesc) || segLRatio < 0.1
        %    continue;
        %else
        %    oldShapeClass = shapeClass;
        %end
        if isempty(shapeDesc)
            continue;
        end
        if isDebug == 1 && ~isempty(shapeDesc)
            plot([domX(idom) domX(idom+1)], [domY(idom) domY(idom+1)], '-r');
            disp(shapeDesc);
        end
        if idom > 1 && isRotationInv == 1
            descCode = [descCode, midShapeClass];
            descShape = [descShape, ' #',  midShapeDesc];
            segCount = segCount + 1;
            segX = [strokeX(domPos(idom):domPos(idom+1))];
            segY = [strokeY(domPos(idom):domPos(idom+1))];
            segXY{segCount} = [segY,segX];
            segStartPos = [segStartPos; domPos(idom)];
            segEndPos = [segEndPos; domPos(idom+1)];
        end
        
        %descShape = [descShape, ' ', shapeDesc];
        descCode = [descCode, num2str(shapeClass)];
        descShape = [descShape, ' #',  shapeDesc];
        segCount = segCount + 1;
        segX = [strokeX(domPos(idom):domPos(idom+1))];
        segY = [strokeY(domPos(idom):domPos(idom+1))];
        segXY{segCount} = [segY,segX];
        segStartPos = [segStartPos; domPos(idom)];
        segEndPos = [segEndPos; domPos(idom+1)];
        
       
    end
    segLenghts = segEndPos - segStartPos;
    
    % merge similar consecutive codes together
    %labels = {'vert_Up', 'vert_Down', 'hori_Left', 'hori_Right', 'raaInv-shape', 'raa-shape', 'ara8-shape', 'hflip-raa', 'other'};
    
    if isRotationInv == 1
        segCode = ['S', 'V', 'C', 'd', 'l', 'r', 's', 't', 'p', 'q', 'm', 'n'];
        segDesc = [{'straight_line'},{'cw_curve'},{'ccw_curve'},{'same_dir'},...
            {'bent_left'},{'bent_right'}, {'bent_left_sharp'},{'bent_right_sharp'}...
            , {'bent_left_perp'},{'bent_right_perp'}, {'bent_left_mod'},{'bent_right_mod'}];

    else    
        segCode = ['u', 'd', 'l', 'r', 'w','x','y','z','A','B','C','D','E','F','G','H', 'N', 'V'];
        segDesc = [{'vert_Up'},{'vert_Down'},{'hori_left'},{'hori_right'}, ...
            {'st_right_down'},{'st_left_down'},{'st_left_up'},{'st_right_up'}, ...
            {'cw_right_down'},{'cw_left_down'},{'cw_left_up'},{'cw_right_up'},...
            {'ccw_left_down'},{'ccw_right_down'},{'ccw_right_up'},{'ccw_left_up'},...
            {'ara8-shape'},{'ara7-shape'}];
    end
    
    
    desLen = length(descCode);
    
    mergeSegments = 1;
    
    if mergeSegments == 1
        tdescCode = [];
        tdescShape = [];
        tsegStartPos = [];
        tsegEndPos = [];
        i = 1;
        j = i+1;
        segCount = 0;
        tsegXY = {};
        while i <= desLen      

            if isRotationInv == 0
                j = i+1;
                while j <= desLen && descCode(i) == descCode(j)
                    j = j + 1;
                    segLRatio = sum(segLenghts(i:j-1))/np;
                    if segLRatio > repParam.maxSegLen
                        break;
                    end
                end
            else
                j = i+2;
                while j <= desLen && descCode(i) == descCode(j) && descCode(j-1) == 's'
                    segLRatio = sum(segLenghts(i:2:j))/np;
                    j = j + 2;
                    if segLRatio > repParam.maxSegLen
                        break;
                    end
                end
            end
            %segLRatio = sum(segLenghts(i:j-1))/np;

            %if segLRatio < supParam.minSegLen
            %    i = j;
            %    continue;
            %end
            if isRotationInv == 0
                index = find(segCode == descCode(i));        
                %tdescShape = [tdescShape, ' #',  labels{str2double(descCode(i))}];
                tdescShape = [tdescShape, ' #',  segDesc{index}];
                tdescCode = [tdescCode, descCode(i)];
                segCount = segCount + 1;
                tsegX = [strokeX(segStartPos(i):segEndPos(j-1))];
                tsegY = [strokeY(segStartPos(i):segEndPos(j-1))];
                tsegXY{segCount} = [tsegY,tsegX];
                tsegStartPos = [tsegStartPos; segStartPos(i)];
                tsegEndPos = [tsegEndPos; segEndPos(j-1)];

            else
                index = find(segCode == descCode(i));        
                %tdescShape = [tdescShape, ' #',  labels{str2double(descCode(i))}];
                tdescShape = [tdescShape, ' #',  segDesc{index}];
                tdescCode = [tdescCode, descCode(i)];
                segCount = segCount + 1;
                tsegX = [strokeX(segStartPos(i):segEndPos(j-2))];
                tsegY = [strokeY(segStartPos(i):segEndPos(j-2))];
                tsegXY{segCount} = [tsegY,tsegX];
                tsegStartPos = [tsegStartPos; segStartPos(i)];
                tsegEndPos = [tsegEndPos; segEndPos(j-2)];

                if j <= desLen
                    index = find(segCode == descCode(j-1));        
                    %tdescShape = [tdescShape, ' #',  labels{str2double(descCode(i))}];
                    tdescShape = [tdescShape, ' #',  segDesc{index}];
                    tdescCode = [tdescCode, descCode(j-1)];
                    segCount = segCount + 1;
                    tsegX = [strokeX(segStartPos(j-1):segEndPos(j))];
                    tsegY = [strokeY(segStartPos(j-1):segEndPos(j))];
                    tsegXY{segCount} = [tsegY,tsegX];
                    tsegStartPos = [tsegStartPos; segStartPos(j-1)];
                    tsegEndPos = [tsegEndPos; segEndPos(j-2)];
                end
            end
            i = j;
        end
        descShape = tdescShape;
        descCode = tdescCode;
        segXY = tsegXY;
        segStartPos = tsegStartPos;
        segEndPos = tsegEndPos;
        segLenghts = (segEndPos - segStartPos)/np;
        segLenghts = segLenghts / sum(segLenghts);
    end
    
    % locate prime points on the currve
    
    if isDebug == 1
        disp('** End of description for connected component **'); 
        hold off;
    end
end


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

function [domX, domY] = suppressPointUsingSegmLen(contourX, contourY, domX, domY, minSegLen)
    n = length(contourX);    
    [strength, domPos] = getStrength(contourX, contourY, domX, domY);
    isDom = zeros(n,1);
    isDom(domPos) = 1;
    index = find(isDom == 1);
    nd = length(index);
    if nd == 0
        return;
    end
    domX = contourX(index); % this is needed to clean up any duplicate domianant point
    domY = contourY(index);
    [strength, domPos] = getStrength(contourX, contourY, domX, domY);
    
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
    
    mode = 2;
    %endConition = 1; % means no more update is possible whatever be the threshold
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
        
        if Vp < Vn
            conX = contourX(Vp : Vn);
            conY = contourY(Vp : Vn);
        else
            conX = [contourX(Vp : end); contourX(1 : Vn)];
            conY = [contourY(Vp : end); contourY(1 : Vn)];
        end
        
        lenSeg = length(conX);
        lenSeg1 = abs(index(j)-index(jp));
        lenSeg2 = abs(index(jn)-index(j));
        
        isSup = 0;
        %if lenSeg < 2*n*minSegLen
        if lenSeg1 < n*minSegLen || lenSeg2 < n*minSegLen
            isSup = 1;
        end
        
        if isSup == 1
            isDom(index(j)) = 0;                
        end
    end
    index = find(isDom == 1);
    domX = contourX(index);
    domY = contourY(index);

end
function v = increase(v, incr, limit)
        v = v + incr;
        if v > limit
            v = v - limit;
        end
end
function v = decrease(v, decr, limit)
    v = v - decr;
    if v <= 0
        v = limit + v;
    end
end

function [strength, domPos] = getStrength(contourX, contourY, domX, domY)
        n = length(contourX);
        nd = length(domX);
        strength = zeros(nd, 1);
        domPos = zeros(nd, 1);
        if(nd == 0)
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
                i = i - 1;
            end
            i = i + 1;
            if i == n + 1
                i = 1;
            end
        end
        strength(1) = strength(1) + n - domPos(nd);
        t = strength(1);
        for j = 1 : nd-1
            strength(j) = strength(j) + strength(j+1);
        end
        strength(nd) = strength(nd) + t;
        
end
    