%input: String: Path to the Xml File
%output: [X Y Label]: List that contians the coordinates in the XML file,
%and the label that represents that text
%and segmentsIndex: The index of the starting point in each segment

function [X, Y, Label, segmentsIndex, strokeLengths] = ReadXmlFile(fileName)

    path = fileName;
    %path = [fileName '.inkml'];
    xmlDocSample = xmlread(path);
    allTraceItems = xmlDocSample.getElementsByTagName('trace');
    x=[];
    y=[];
    segmentsIndex=[];
    strokeLengths = [];
    for k = 0:allTraceItems.getLength-1
        txtCoordinates=allTraceItems.item(k).getTextContent;
        [tmpX, tmpY, dummy1,dummy2] = strread(char(txtCoordinates),'%d %d %d %d','delimiter',',');
        x=[x; tmpX];
        y=[y; tmpY];
        strokeLengths = [strokeLengths length(tmpX)];
        segmentsIndex=[segmentsIndex length(x)+1];
    end

    segmentsIndex=[1 segmentsIndex];
    X=x;
    Y=y;
    
    Label = [];

%     path = strrep(path, 'inkml', 'upx');
%     
%     if exist(path, 'file')
%         xmlDocSample = xmlread(path);
%         allTraceItems = xmlDocSample.getElementsByTagName('alternate');
%         tLabel=allTraceItems.item(0).getAttribute('value');
%         Label=char(tLabel);
%     else
%         [pathstr, name, ext] = fileparts(path);
%         %[lbls]=textread('Data\MySet\Lables.txt','%s','delimiter', '\n');
%         [lbls lbInds]=textread('Data\MySet\Lables.txt','%s%d','delimiter', '\t');  % To-Do: Update the path (Make relative)
%         LInd=find(lbInds==str2num(name));
%         Label=char(lbls(LInd));
%     end
    
    
end

