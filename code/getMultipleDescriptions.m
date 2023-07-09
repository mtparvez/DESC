% function that takes as input (x,y) coordinates of a shape contour
% outputs:
% - descCount: how many representations found
% - descShape: list of descriptions using the codebook
% - descCode: same as 'descShape', but each word from codebook is replaced by a code
% - segXYAll: a list that contains the (x,y) coordinates of all segments
% inside each representation
% - segLenAll: a list that contains the the length (in # of points) of all segments
% inside each representation


function [descCount, descShape, descCode, segXYAll, segLenAll] = ...
    getMultipleDescriptions(strokeX, strokeY, matchingParam)

        [strokeX, strokeY] = cleanData(strokeX, strokeY);
        [strokeX, strokeY] = reSampleData(strokeX, strokeY);
        [strokeX, strokeY] = cleanData(strokeX, strokeY);

        noSetting = matchingParam.repCount;
        descShape = cell(noSetting, 1);
        descCode = cell(noSetting, 1);
        segXYAll = cell(noSetting, 1);
        segLenAll = cell(noSetting, 1);
        supParam.descCode = [];
        
        %repLevel = matchingParam.repLevel;
        
        descCount = 0;
        isDebug = 0;
        
        if isDebug == 1
            %figH = figure(1);
        end

        if matchingParam.repLevel == 1
            maxSegLen =    [0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4];
            minSegLen =    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0];%[0.10, 0.15, 0.10, 0.10, 0.10];
            distThrMulti = [1,    3,    3,      4,   4,  5, 4,   6,   6, 6, 6,  6];
            supThr =       [.5,    1,    1.5,   2,  2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6];

        elseif matchingParam.repLevel == 2 % relaxed
            maxSegLen =    [0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6];
            minSegLen =    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0];%[0.10, 0.15, 0.10, 0.10, 0.10];
            distThrMulti = [6,    5,    4,      6,   6,  5, 4,   6,   6, 6, 6,  6];
            supThr =       [.5,    1,    1.5,   2,  2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6];

        elseif matchingParam.repLevel == 3 || matchingParam.repLevel == 4% veryrelaxed
            maxSegLen =    [0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8];
            minSegLen =    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0];%[0.15, 0.15, 0.15, 0.15, 0.15];
            distThrMulti = [6,    5,    4,      6,   6,  5, 4,   6,   6, 6, 6,  6];
            supThr =       [.5,    1,    1.5,   2,  2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6];
            
        elseif matchingParam.repLevel == 5
            maxSegLen =    [0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.4, 0.4, 0.4, 0.4, 0.4];
            minSegLen =    [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.0, 0.0, 0.0, 0, 0];%[0.10, 0.15, 0.10, 0.10, 0.10];
            distThrMulti = [6,    5,    4,      6,   6,  5, 4,   6,   6, 6, 6,  6];
            supThr =       [2,    2.5,    3,   3,  3.5, 3, 3.5, 4, 4.5, 5, 5.5, 6];
        elseif matchingParam.repLevel == 6
            maxSegLen =    [0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.4, 0.4, 0.4, 0.4, 0.4];
            minSegLen =    [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.0, 0.0, 0.0, 0, 0];%[0.10, 0.15, 0.10, 0.10, 0.10];
            distThrMulti = [6,    5,    4,      6,   6,  5, 4,   6,   6, 6, 6,  6];
            supThr =       [3,    4,    3,   3,  3.5, 3, 3.5, 4, 4.5, 5, 5.5, 6];
        
        elseif matchingParam.repLevel == 7 % offline case
            maxSegLen =    [0.5, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4];
            minSegLen =    [0.05, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0];%[0.10, 0.15, 0.10, 0.10, 0.10];
            distThrMulti = [6,    5,    4,      6,   6,  5, 4,   6,   6, 6, 6,  6];
            supThr =       [1,    1,    1.5,   2,  2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6];
        else %if matchingParam.repLevel == 8 % online PAW case
            maxSegLen =    [0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.4, 0.4, 0.4, 0.4, 0.4];
            minSegLen =    [0.05, 0.05, 0.05, 0.05, 0.05, 0.1, 0.1, 0.0, 0.0, 0.0, 0, 0];%[0.10, 0.15, 0.10, 0.10, 0.10];
            distThrMulti = [6,    5,    4,      6,   6,  5, 4,   6,   6, 6, 6,  6];
            supThr =       [1,    1.5,    2,   2.5  3, 3.5, 3.5, 4, 4.5, 5, 5.5, 6];
        end
  
            
        supParam.repLevel = matchingParam.repLevel;
        supParam.rotationInvariant = matchingParam.rotationInvariant;
        for i = 1 : noSetting
            supParam.maxSegLen = maxSegLen(i);
            supParam.minSegLen = 0.05;%minSegLen(i);
            supParam.distThrMulti = distThrMulti(i);
            supParam.supThr = supThr(i);
            supParam.index = i;
            if matchingParam.isOffline == 1   
                [descS, descC, segStartPos, segEndPos, segLenghts, segXY]...
                    = getOfflineShapeDescriptionPA(strokeX, strokeY, [], supParam);
            else
                [descS, descC, segStartPos, segEndPos, segLenghts, segXY]...
                    = getOnlineCharDescriptionPA_v2(strokeX, strokeY, [], supParam);
            end
            %disp(descS);
            if isDebug == 1
                %plotStrokeWithCorners(figH, segXY);
                plotStrokeWithCorners([], segXY, 1);
                hold on;
                %plot(strokeX, strokeY, '--k');
                disp(descS);
                %disp(supParam);
            end
            
            if descCount > 0 % check for repition
                if strcmp(descC, descCode{descCount}) == 1
                    continue;
                end
            end
            descCount = descCount + 1;
            descShape(descCount) = {descS};
            descCode(descCount) = {descC};
            segXYAll{descCount} = segXY;
            segLenAll{descCount} = segLenghts;
        end

           
end
