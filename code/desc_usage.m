function desc_usage
    % this file demostrates how to extract multiple descriptors using DESC
    % a sample inkml file.
    
    dataFileName = '../data/A0001_2_1_012_E_ee.inkml';
    % read the online shape data
    % use the helper function 'readInkml'
    [strokeX, strokeY, PointCount] = readInkml(dataFileName); 
    
    % intialze theh desc params
    
    descParam.repCount = 3; % maximum how many representations wanted
    descParam.rotationInvariant = 0; % 1 if rotation invariant descriptors
    descParam.repLevel = 1; % this controls perspective: range 1 - 7 
    % for online, use 8 for offline
    descParam.isOffline = 0; % make this 1 of the points are coming from an offline shape
    
    % call the main DESC function to get the descriptors

    [descCount, descShape, descCode, segXYAll, segLenAll] = ...
        getMultipleDescriptions(strokeX, strokeY, descParam);
    
    % print the descriptions
    for i = 1 : descCount
        descShape{i}
    end

end

