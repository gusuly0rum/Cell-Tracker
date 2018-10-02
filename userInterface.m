%%%%% Initialisation %%%%%
function varargout = userInterface(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @userInterface_OpeningFcn, ...
                   'gui_OutputFcn',  @userInterface_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);

if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State,varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

%%%%% Display Window %%%%%
function userInterface_OpeningFcn(hObject,~,handles,varargin)

%%%%% Window Settings %%%%%
set(0,'DefaultFigureWindowStyle','normal')
warning('off','Images:initSize:adjustingMag')
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame')
warning('off','images:imshow:magnificationMustBeFitForDockedFigure')

%%%%% Axes Settings %%%%%
box(handles.plotDisplay,'on')
box(handles.imageDisplay,'on')
set(handles.plotDisplay,'XTickLabel',{})
set(handles.plotDisplay,'YTickLabel',{})

%%%%% Table Settings %%%%%
colNames = cell(1,10);
colNames{1} = sprintf('Label');
for k = 2:11
    colNames{k} = ['Frame ',num2str(k-1)];
end
set(handles.dataTable,'ColumnName',colNames)
set(handles.dataTable,'RowName',1:150)

%%%%% Handle Variables Initialisation %%%%%
handles.speed = 0;
handles.channel = -3;
set(handles.speedStatic,'String',handles.speed)

%%%%% Status Window Messages %%%%%
handles.messages = cell(1,50);
handles.messages{1} = sprintf('>> Application Initialisation Complete');
handles.messages{2} = sprintf('>> File Extension Not Supported');
handles.messages{3} = sprintf('>> Reading Images..');
handles.messages{4} = sprintf('Reading Images Complete');
handles.messages{5} = sprintf('Expected File Extension .tif');
handles.messages{6} = sprintf('>> Not Enough Input Arguments');
handles.messages{7} = sprintf('>> Files Not Loaded');
handles.messages{8} = sprintf('>> Performing Segmentation..');
handles.messages{9} = sprintf('Tracking Complete');
handles.messages{10} = sprintf('>> No Output Arguments Detected');
handles.messages{11} = sprintf('By Donguk Kim, MSc');
handles.messages{12} = sprintf('Imperial College London,');
handles.messages{13} = sprintf('>> All Data Cleared');
handles.messages{14} = sprintf('Department of Bioengineering');
handles.messages{15} = sprintf('>> Expected Input to be Numerical');
handles.messages{16} = sprintf('>> Gathering Cytometric Data..');
handles.messages{17} = sprintf('Cytometric Data Acquistion Complete');
handles.messages{18} = sprintf('>> Selected Label Index Unavailable');
handles.messages{19} = sprintf('>> Exporting to Excel..');
handles.messages{20} = sprintf('Export Complete');
handles.messages{21} = sprintf('>> Aborting Process on Next Iteration..');
handles.messages{22} = sprintf('Process Aborted');
handles.messages{23} = sprintf('>> Saving Current Axes Handle');
handles.messages{24} = sprintf('Image Save Complete');
handles.messages{25} = sprintf('>> Files Cleared');
handles.messages{26} = sprintf('>> Table Cleared');
handles.messages{27} = sprintf('>> Graph Cleared');

%%%%% Opening Messages %%%%%
openingMessages = [cellstr(handles.messages{1});
                   cellstr(handles.messages{11});
                   cellstr(handles.messages{12});
                   cellstr(handles.messages{14})];

set(handles.filenamePop,'String','Filenames')
set(handles.statusList,'String',openingMessages)

%%%%% Tracking Variables Initialisation %%%%%
handles.updateID = 1;
handles.trackWorkspace = struct('labelIndex',    {},...
                                'kalmanFilter',  {},...
                                'boundingBox',   {},...
                                'longevity',     {},...
                                'visibleCount',  {},...
                                'invisibleCount',{},...
                                'pixelIndex',    {},...
                                'intensityGFP',  {},...
                                'intensityRFP',  {},...
                                'intensityDIV',  {},...
                                'centroidGrn',   {},...
                                'centroidRed',   {});

%%%%% User Segmentation Input Variables Defaults %%%%%
set(handles.colourEdit,'String',num2str([2 2 1]))
set(handles.brightEdit,'String',num2str(7))
set(handles.tophatEdit,'String',num2str(15))
set(handles.tilesEdit,'String',num2str(50))
set(handles.conlimEdit,'String',num2str(0.01))
set(handles.gaussEdit,'String',num2str(2))
set(handles.threshEdit,'String',num2str(0.3))
set(handles.sizeAEdit,'String',num2str([500 500 100]))
set(handles.sizeBEdit,'String',num2str(4000))
set(handles.dilateEdit,'String',num2str([2 2 1]))
set(handles.hminEdit,'String',num2str([10 10 5]))
set(handles.visEdit,'String',num2str(0.8))
set(handles.invisEdit,'String',num2str(0))
set(handles.ageEdit,'String',num2str(8))

%%%%% User Segmentation Input Variables Defaults %%%%%
set(handles.costEdit,'String',num2str(8))
set(handles.marker,'Value',1)

%%%%% Box and Index Colour Defaults %%%%%
set(handles.boxcolPop,'Value',7)
set(handles.indcolPop,'Value',4)

%%%%% Box and Index Colour Initialisation %%%%%
boxColours = {'m','y','g','w','c','k','b','r'};
indColours = {'m','y','g','w','c','k','b','r'};
boxColour = get(handles.boxcolPop,'Value');
indColour = get(handles.indcolPop,'Value');
handles.boxColour = boxColours{boxColour};
handles.indColour = indColours{indColour};

handles.output = hObject;
guidata(hObject,handles);

%%%%% "Open Files" Push Button %%%%%
function openPush_Callback(hObject,~,handles)

zoom(handles.imageDisplay,'off')

handles.updateID = 1;
handles.trackWorkspace = struct('labelIndex',    {},...
                                'kalmanFilter',  {},...
                                'boundingBox',   {},...
                                'longevity',     {},...
                                'visibleCount',  {},...
                                'invisibleCount',{},...
                                'pixelIndex',    {},...
                                'intensityGFP',  {},...
                                'intensityRFP',  {},...
                                'intensityDIV',  {},...
                                'centroidGrn',   {},...
                                'centroidRed',   {});

%%%%% Extract Brightness Settings %%%%%
handles.bright(1,1:3) = str2num(get(handles.brightEdit,'String'));
if numel(handles.bright) == 1
   handles.bright(1,1:3) = repmat(handles.bright(1),[1 3]);
end

%%%%% Open Files Directory %%%%%
[fileName,pathName] = uigetfile('*.*','MultiSelect','on');

%%%%% No Files Selected %%%%%
if isequal(fileName,0)
    return
end

%%%%% Update Filename Listbox %%%%%
tempStatus = cellstr(get(handles.filenamePop,'String'));
initStatus = [tempStatus ; cellstr(fileName)];
set(handles.filenamePop,'String',initStatus)

%%%%% Extract File Extension %%%%%
fullFileName = fullfile(pathName,fileName);
if ischar(fullFileName)
    fullFileName = {fullFileName};
end
[~,~,handles.extension] = fileparts(fullFileName{1});

%%%%% Image Reading Depending on Extension %%%%%
if strcmp(handles.extension,'.tif')
    
    %%%%% "Reading Images" Message %%%%%
    tempStatus = cellstr(get(handles.statusList,'String'));
    initStatus = [tempStatus ; handles.messages{3}];
    set(handles.statusList,'String',initStatus)
    lastMsg = numel(get(handles.statusList,'String'));
    set(handles.statusList,'Value',lastMsg)
    drawnow
    refresh
    
    %%%%% Read Images %%%%%
    if numel(get(handles.filenamePop,'String')) == 2
    
        %%%%% Read Phase-Contrast Images %%%%%
        imageListPhs = fullfile(pathName,fileName);
        handles.nImages = size(imfinfo(imageListPhs),1);
        handles.imageListPhs = cell(1,handles.nImages);
        for k = 1:handles.nImages
            handles.imageListPhs{k} = imread(imageListPhs,k);
        end
        %%%%% Display First Frame %%%%%
        imagesc(handles.imageListPhs{1}*handles.bright(1),'Parent',handles.imageDisplay);
        set(handles.imageDisplay,'XTick',[],'YTick',[])
        set(handles.filenamePop,'Value',2)
        drawnow
        
        %%%%% Update Frame Chooser Edit Text %%%%%
        set(handles.fromEdit,'String',1)
        set(handles.toEdit,'String',handles.nImages)
        
    elseif numel(get(handles.filenamePop,'String')) == 3
        
        %%%%% Read GFP Images %%%%%
        imageListGrn = fullfile(pathName,fileName);
        handles.nImages = size(imfinfo(imageListGrn),1);
        handles.imageListGrn = cell(1,handles.nImages);
        for k = 1:handles.nImages
            handles.imageListGrn{k} = imread(imageListGrn,k);
        end
        %%%%% Display First Frame %%%%%
        imagesc(handles.imageListGrn{1}*handles.bright(2),'Parent',handles.imageDisplay);
        set(handles.imageDisplay,'XTick',[],'YTick',[])
        set(handles.filenamePop,'Value',3)
        drawnow
        
    elseif numel(get(handles.filenamePop,'String')) == 4
        
        %%%%% Read RFP Images %%%%%
        imageListRed = fullfile(pathName,fileName);
        handles.nImages = size(imfinfo(imageListRed),1);
        handles.imageListRed = cell(1,handles.nImages);
        for k = 1:handles.nImages
            handles.imageListRed{k} = imread(imageListRed,k);
        end
        %%%%% Display First Frame %%%%%
        imagesc(handles.imageListRed{1}*handles.bright(3),'Parent',handles.imageDisplay);
        set(handles.imageDisplay,'XTick',[],'YTick',[])
        set(handles.filenamePop,'Value',4)
        drawnow
        
    end
    
    %%%%% Update Slider Values and Step Size %%%%%
    if handles.nImages > 1
        set(handles.frameSlider,'Min',1,'Max',handles.nImages,'Value',1)
        handles.sliderStep = [1 1]/(handles.nImages - 1);
        set(handles.frameSlider,'SliderStep',handles.sliderStep)
    end
    set(handles.frameStatic,'String',sprintf(['Frame 1/',num2str(handles.nImages)]))
    
    %%%%% Handle Variables Initialisation %%%%%
    handles.colourPhs = cell(1,handles.nImages);
    handles.colourGrn = cell(1,handles.nImages);
    handles.colourRed = cell(1,handles.nImages);
    
    handles.newPhs = cell(1,handles.nImages);
    handles.newGrn = cell(1,handles.nImages);
    handles.newRed = cell(1,handles.nImages);
    handles.overlay = cell(1,handles.nImages);
    
    handles.trackedImagesPhs = cell(1,handles.nImages);
    handles.trackedImagesGrn = cell(1,handles.nImages);
    handles.trackedImagesRed = cell(1,handles.nImages);
    
    handles.workspaceMemory = cell(1,handles.nImages);
    
    %%%%% Trajectory Trace %%%%%
    handles.tempPosGrn = cell(1,200);
    handles.tempPosRed = cell(1,200);
    handles.stateEstGrn = cell(1,handles.nImages);
    handles.stateEstRed = cell(1,handles.nImages);
    
    %%%%% User Input Variables Initialisation %%%%%
    handles.colour = zeros(1,3);
    handles.bright = zeros(1,3);
    handles.tophat = zeros(1,3);
    handles.nTiles = zeros(1,6);
    handles.conlim = zeros(1,3);
    handles.gaussb = zeros(1,3);
    handles.thresh = zeros(1,3);
    handles.sizerA = zeros(1,3);
    handles.sizerB = zeros(1,3);
    handles.dilate = zeros(1,3);
    handles.minima = zeros(1,3);
    
    %%%%% Update Start and End Frames Static Text %%%%%
    handles.nImages = str2double(get(handles.toEdit,'String'));
    handles.firstFrame = str2double(get(handles.fromEdit,'String'));
    
    %%%%% Update Table Column Names %%%%%
    colNames = cell(1,handles.nImages);
    colNames{1} = sprintf('Label');
    for k = 2:handles.nImages + 1
        colNames{k} = ['Frame ',num2str(k-1)];
    end
    set(handles.dataTable,'ColumnName',colNames)
    
    %%%%% "Reading Images Complete" Message %%%%%
    tempStatus = cellstr(get(handles.statusList,'String'));
    initStatus = [tempStatus ; handles.messages{4}];
    set(handles.statusList,'String',initStatus)
    lastMsg = numel(get(handles.statusList,'String'));
    set(handles.statusList,'Value',lastMsg)
    drawnow
    
else
    
    %%%%% "Extension Not Supported" Message %%%%%
    tempStatus = cellstr(get(handles.statusList,'String'));
    initStatus = [tempStatus ; handles.messages{2} ; handles.messages{5}];
    set(handles.statusList,'String',initStatus)
    lastMsg = numel(get(handles.statusList,'String'));
    set(handles.statusList,'Value',lastMsg)
    drawnow
    
end

guidata(hObject,handles)

%%%%% "Run" Push Button %%%%%
function runPush_Callback(hObject,~,handles)

zoom(handles.imageDisplay,'off')

clear handles.updateID
clear handles.trackWorkspace
clear handles.workspaceMemory
handles.updateID = 1;
handles.workspaceMemory = cell(1,handles.nImages);
handles.trackWorkspace = struct('labelIndex',    {},...
                                'kalmanFilter',  {},...
                                'boundingBox',   {},...
                                'longevity',     {},...
                                'visibleCount',  {},...
                                'invisibleCount',{},...
                                'pixelIndex',    {},...
                                'intensityGFP',  {},...
                                'intensityRFP',  {},...
                                'intensityDIV',  {},...
                                'centroidGrn',   {},...
                                'centroidRed',   {});
                            
%%%%% "Not Enough Input Arguments" Message %%%%%
if numel(get(handles.filenamePop,'String')) == 9 || numel(get(handles.filenamePop,'String')) == 2 || numel(get(handles.filenamePop,'String')) == 3
    tempStatus = cellstr(get(handles.statusList,'String'));
    initStatus = [tempStatus ; handles.messages{6}];
    set(handles.statusList,'String',initStatus)
    lastMsg = numel(get(handles.statusList,'String'));
    set(handles.statusList,'Value',lastMsg)
    drawnow
    
elseif numel(get(handles.filenamePop,'String')) == 4
    
    clear handles.rowValuesGFP
    clear handles.rowValuesRFP
    clear handles.rowValuesDIV
    
    %%%%% "Performing Segmentation" Message %%%%%
    tempStatus = cellstr(get(handles.statusList,'String'));
    initStatus = [tempStatus ; handles.messages{8}];
    set(handles.statusList,'String',initStatus)
    lastMsg = numel(get(handles.statusList,'String'));
    set(handles.statusList,'Value',lastMsg)
    drawnow
    
    %%%%% Update Start and End Frames %%%%%
    handles.nImages = str2double(get(handles.toEdit,'String'));
    handles.firstFrame = str2double(get(handles.fromEdit,'String'));
    
    %%%%% Table Settings %%%%%
    numpy = handles.nImages - handles.firstFrame + 2;
    
    colNames = cell(1,numpy);
    colNames{1} = sprintf('Label');
    j = handles.firstFrame;
    
    for k = 2:numpy
        colNames{k} = ['Frame ',num2str(j)];
        j = j + 1;
    end
        
    set(handles.dataTable,'ColumnName',colNames)
    set(handles.dataTable,'RowName',1:150)
    
    %%%%% Set Radio Button State %%%%%
    set(handles.rawRadio,'Value',1);
    
    %%%%% Set "Stop" Push Button to Initial State %%%%%
    set(handles.stopPush,'Userdata',0);
    
    %%%%% Main Segmentation and Tracking %%%%%
    for k = handles.firstFrame:handles.nImages
        
        %%%%% "Stop" Push Button %%%%%
        if get(handles.stopPush,'Userdata') == 1
            %%%%% "Aborting Process on Next Iteration" Message %%%%%
            tempStatus = cellstr(get(handles.statusList,'String'));
            initStatus = [tempStatus ; handles.messages{21}];
            set(handles.statusList,'String',initStatus)
            lastMsg = numel(get(handles.statusList,'String'));
            set(handles.statusList,'Value',lastMsg)
            drawnow
            break
        end
        
        tic
        
        %%%%% Update Slider Values and Step Size %%%%%
        if handles.nImages > 1
            set(handles.frameSlider,'Min',1,'Max',handles.nImages,'Value',1)
            handles.sliderStep = [1 1]/(handles.nImages - 1);
            set(handles.frameSlider,'SliderStep',handles.sliderStep)
        end
        
        %%%%% Update Frame State %%%%%
        set(handles.frameStatic,'String',sprintf(['Frame ',num2str(k),'/',num2str(handles.nImages)]))
        
        %%%%% "Tracking Frame" Message %%%%%
        tempStatus = cellstr(get(handles.statusList,'String'));
        initStatus = [tempStatus ; sprintf(['Tracking Frame ',num2str(k),'/',num2str(handles.nImages),'..'])];
        set(handles.statusList,'String',initStatus)
        lastMsg = numel(get(handles.statusList,'String'));
        set(handles.statusList,'Value',lastMsg)
        drawnow
        
        %%%%% User Input Variables %%%%%
        handles.colour(1,1:3) = str2num(get(handles.colourEdit,'String'));
        if numel(handles.colour) == 1
            handles.colour(1,1:3) = repmat(handles.colour(1),[1 3]);
        end
        
        handles.bright(1,1:3) = str2num(get(handles.brightEdit,'String'));
        if numel(handles.bright) == 1
            handles.bright(1,1:3) = repmat(handles.bright(1),[1 3]);
        end
        
        handles.tophat(1,1:3) = str2num(get(handles.tophatEdit,'String'));
        if numel(handles.tophat) == 1
            handles.tophat(1,1:3) = repmat(handles.tophat(1),[1 3]);
        end
        
        handles.nTiles(1,1:3) = str2num(get(handles.tilesEdit,'String'));
        if numel(nonzeros(handles.nTiles)) == 3
            handles.nTiles(1,1:2) = repmat(handles.nTiles(1),[1 2]);
            handles.nTiles(1,3:4) = repmat(handles.nTiles(2),[1 2]);
            handles.nTiles(1,5:6) = repmat(handles.nTiles(3),[1 2]);
        elseif numel(nonzeros(handles.nTiles)) == 1
            handles.nTiles(1,1:6) = repmat(handles.nTiles(1),[1 6]);
        end
        
        handles.conlim(1,1:3) = str2num(get(handles.conlimEdit,'String'));
        if numel(handles.conlim) == 1
            handles.conlim(1,1:3) = repmat(handles.conlim(1),[1 3]);
        end
        
        handles.gaussb(1,1:3) = str2num(get(handles.gaussEdit,'String'));
        if numel(handles.gaussb) == 1
            handles.gaussb(1,1:3) = repmat(handles.gaussb(1),[1 3]);
        end
        
        handles.thresh(1,1:3) = str2num(get(handles.threshEdit,'String'));
        if numel(handles.thresh) == 1
            handles.thresh(1,1:3) = repmat(handles.thresh(1),[1 3]);
        end
        
        handles.sizerA(1,1:3) = str2num(get(handles.sizeAEdit,'String'));
        if numel(handles.sizerA) == 1
            handles.sizerA(1,1:3) = repmat(handles.sizerA(1),[1 3]);
        end
        
        handles.sizerB(1,1:3) = str2num(get(handles.sizeBEdit,'String'));
        if numel(handles.sizerB) == 1
            handles.sizerB(1,1:3) = repmat(handles.sizerB(1),[1 3]);
        end
        
        handles.dilate(1,1:3) = str2num(get(handles.dilateEdit,'String'));
        if numel(handles.dilate) == 1
            handles.dilate(1,1:3) = repmat(handles.dilate(1),[1 3]);
        end
        
        handles.minima(1,1:3) = str2num(get(handles.hminEdit,'String'));
        if numel(handles.minima) == 1
            handles.minima(1,1:3) = repmat(handles.minima(1),[1 3]);
        end
        
        handles.visibility = str2double(get(hObject,'String'));
        handles.agePenalty = str2double(get(hObject,'String'));
        handles.invisibleCount = str2double(get(hObject,'String'));
        
        %%%%% Phase-Contrast Image Segmentation %%%%%
        phsImage = handles.imageListPhs{k};
        
        if handles.colour(1) == 0
            phsChannels = rgb2gray(phsImage)*handles.bright(1);
        elseif all(handles.colour)
            phsChannels = phsImage(:,:,handles.colour(1))*handles.bright(1);
        end
        
        [~,phsNoise] = wiener2(phsChannels);
        noisePhs = wiener2(phsChannels,phsNoise);
        tophatPhs = imtophat(noisePhs,strel('disk',handles.tophat(1)));
        adjustPhs = imadjust(tophatPhs,stretchlim(tophatPhs),[]);
        histogramPhs = adapthisteq(adjustPhs,'NumTiles',[handles.nTiles(1:2)],'ClipLimit',handles.conlim(1));
        gaussianPhs = imgaussfilt(histogramPhs,handles.gaussb(1));
        
        if handles.thresh(1) == 0
            binaryPhs = im2bw(gaussianPhs,graythresh(gaussianPhs));
        elseif all(handles.thresh)
            binaryPhs = im2bw(gaussianPhs,handles.thresh(1));
        end
        
        removePhs = xor(bwareaopen(binaryPhs,handles.sizerA(1)),bwareaopen(binaryPhs,handles.sizerB(1)));
        dilatePhs = imdilate(removePhs,strel('disk',handles.dilate(1)));
        fillPhs = imfill(dilatePhs,'holes');
        distPhs = -bwdist(~fillPhs,'cityblock');
        minimaPhs = imhmin(distPhs,handles.minima(1));
        finalePhs = watershed(minimaPhs);
        finalePhs(~minimaPhs) = 0;
        finalePhs = logical(finalePhs);
        
        %%%%% Cytoplasm Image Segmentation %%%%%
        grnImage = handles.imageListGrn{k};
        
        if handles.colour(2) == 0
            grnChannels = rgb2gray(grnImage)*handles.bright(2);
        elseif all(handles.colour)
            grnChannels = grnImage(:,:,handles.colour(2))*handles.bright(2);
        end
        
        [~,grnNoise] = wiener2(grnChannels);
        noiseGrn = wiener2(grnChannels,grnNoise);
        tophatGrn = imtophat(noiseGrn,strel('disk',handles.tophat(2)));
        adjustGrn = imadjust(tophatGrn,stretchlim(tophatGrn),[]);
        histogramGrn = adapthisteq(adjustGrn,'NumTiles',[handles.nTiles(3:4)],'ClipLimit',handles.conlim(2));
        gaussianGrn = imgaussfilt(histogramGrn,handles.gaussb(2));
        
        if handles.thresh(1) == 0
            binaryGrn = im2bw(gaussianGrn,graythresh(gaussianGrn));
        elseif all(handles.thresh)
            binaryGrn = im2bw(gaussianGrn,handles.thresh(2));
        end
        
        removeGrn = xor(bwareaopen(binaryGrn,handles.sizerA(2)),bwareaopen(binaryGrn,handles.sizerB(2)));
        dilateGrn = imdilate(removeGrn,strel('disk',handles.dilate(2)));
        fillGrn = imfill(dilateGrn,'holes');
        distGrn = -bwdist(~fillGrn,'cityblock');
        minimaGrn = imhmin(distGrn,handles.minima(2));
        finaleGrn = watershed(minimaGrn);
        finaleGrn(~minimaGrn) = 0;
        finaleGrn = logical(finaleGrn);
        
        %%%%% Nucleus Image Segmentation %%%%%
        redImage = handles.imageListRed{k};
        
        if handles.colour(3) == 0
            redChannels = rgb2gray(redImage)*handles.bright(3);
        elseif all(handles.colour)
            redChannels = redImage(:,:,handles.colour(3))*handles.bright(3);
        end
        
        [~,redNoise] = wiener2(redChannels);
        noiseRed = wiener2(redChannels,redNoise);
        tophatRed = imtophat(noiseRed,strel('disk',handles.tophat(3)));
        adjustRed = imadjust(tophatRed,stretchlim(tophatRed),[]);
        histogramRed = adapthisteq(adjustRed,'NumTiles',[handles.nTiles(5:6)],'ClipLimit',handles.conlim(3));
        gaussianRed = imgaussfilt(histogramRed,handles.gaussb(3));
        
        if handles.thresh(3) == 0
            binaryRed = im2bw(gaussianRed,graythresh(gaussianRed));
        elseif all(handles.thresh)
            binaryRed = im2bw(gaussianRed,handles.thresh(3));
        end
        
        removeRed = xor(bwareaopen(binaryRed,handles.sizerA(3)),bwareaopen(binaryRed,handles.sizerB(3)));
        dilateRed = imdilate(removeRed,strel('disk',handles.dilate(3)));
        fillRed = imfill(dilateRed,'holes');
        distRed = -bwdist(~fillRed,'cityblock');
        minimaRed = imhmin(distRed,handles.minima(3));
        finaleRed = watershed(minimaRed);
        finaleRed(~minimaRed) = 0;
        finaleRed = logical(finaleRed);
        
        overlap = finalePhs & finaleGrn;
        
        handles.newPhs{k} = bsxfun(@times,phsImage,cast(finalePhs,'like',phsImage));
        handles.newRed{k} = bsxfun(@times,grnImage,cast(finaleRed,'like',grnImage));
        handles.newGrn{k} = bsxfun(@times,grnImage,cast(overlap,'like',grnImage)) - handles.newRed{k};
        
        overlay = imfuse(handles.newPhs{k},handles.newGrn{k});
        handles.overlay{k} = imfuse(overlay,handles.newRed{k});
        
        %%%%% Extract Cell Properties %%%%%
        
        phsLabel = bwlabel(finalePhs);
        redLabel = bwlabel(finaleRed);
        handles.colourPhs{k} = label2rgb(phsLabel,'jet','k','shuffle');
        propsPhs = regionprops(logical(phsLabel),handles.newPhs{k}(:,:,2),'all');
        propsRed = regionprops(logical(redLabel),'all');
        
        centroidListPhs = cat(1,propsPhs.Centroid);
        centroidListRed = cat(1,propsRed.Centroid);
        boundingListPhs = cat(1,propsPhs.BoundingBox);
        nPhsCells = length(propsPhs);
        pixelIdxListPhs = cell(nPhsCells,1);
        
        for j = 1:nPhsCells
            pixelIdxListPhs{j} = propsPhs(j).PixelIdxList;
        end
        
        %%%%% Predict Centroid Locations %%%%%
        
        for j = 1:length(handles.trackWorkspace)
            predict(handles.trackWorkspace(j).kalmanFilter);
        end
        
        %%%%% Compute Cost Matrix and Assignments %%%%%
        
        nDetPhs = size(propsPhs,1);
        nEstPhs = length(handles.trackWorkspace);
        costMatrix = zeros(nEstPhs,nDetPhs);
        
        for j = 1:nEstPhs
            costMatrix(j,:) = distance(handles.trackWorkspace(j).kalmanFilter,centroidListPhs);
        end
        
        handles.costValue = str2double(get(handles.costEdit,'String'));
        [assign,unTracks,unDetects] = assignDetectionsToTracks(costMatrix,handles.costValue);
        
        %%%%% Handle Detected Cell Tracking %%%%%
        
        numAssignedTracksPhs = size(assign,1);
        
        for j = 1:numAssignedTracksPhs
            
            estIndexPhs = assign(j,1);
            detIndexPhs = assign(j,2);
            
            centroidPhs = centroidListPhs(detIndexPhs,:);
            boundingPhs = boundingListPhs(detIndexPhs,:);
            pixelIdxPhs = pixelIdxListPhs{detIndexPhs,:};
            centroidRed = centroidListRed(detIndexPhs,:);
            
            correct(handles.trackWorkspace(estIndexPhs).kalmanFilter,centroidPhs);
            
            handles.trackWorkspace(estIndexPhs).boundingBox = boundingPhs;
            handles.trackWorkspace(estIndexPhs).longevity = handles.trackWorkspace(estIndexPhs).longevity + 1;
            handles.trackWorkspace(estIndexPhs).visibleCount = handles.trackWorkspace(estIndexPhs).visibleCount + 1;
            handles.trackWorkspace(estIndexPhs).invisibleCount = 0;
            handles.trackWorkspace(estIndexPhs).pixelIndex = pixelIdxPhs;
            handles.trackWorkspace(estIndexPhs).centroidGrn = centroidPhs;
            handles.trackWorkspace(estIndexPhs).centroidRed = centroidRed;
        end
        
        %%%%% Handle Unassigned Cell Tracking %%%%%
        
        for j = 1:length(unTracks)
            unassignTracksPhs = unTracks(j);
            handles.trackWorkspace(unassignTracksPhs).longevity = handles.trackWorkspace(unassignTracksPhs).longevity + 1;
            handles.trackWorkspace(unassignTracksPhs).invisibleCount = handles.trackWorkspace(unassignTracksPhs).invisibleCount + 1;
        end
        
        %%%%% Handle Undetected Cell Tracking %%%%%
        
        for j = 1:length(unDetects)
            
            centroidPhs = centroidListPhs(unDetects(j),:);
            boundingPhs = boundingListPhs(unDetects(j),:);
            pixelIdxPhs = pixelIdxListPhs{unDetects(j),:};
            centroidRed = centroidListRed(unDetects(j),:);
            
            kalmanFilter = configureKalmanFilter('ConstantVelocity',centroidPhs,[200,50],[100,25],100);
            newTrack = struct('labelIndex',     handles.updateID,...
                              'kalmanFilter',   kalmanFilter,...
                              'boundingBox',    boundingPhs,...
                              'longevity',      1,...
                              'visibleCount',   1,...
                              'invisibleCount', 0,...
                              'pixelIndex',     pixelIdxPhs,...
                              'intensityGFP',   0,...
                              'intensityRFP',   0,...
                              'intensityDIV',   0,...
                              'centroidGrn',    centroidPhs,...
                              'centroidRed',    centroidRed);
            
            handles.trackWorkspace(end + 1) = newTrack;
            handles.updateID = handles.updateID + 1;
            
        end
        
        %%%%% Delete Inconsistent Cell Tracking %%%%%
        
        if ~isempty(handles.trackWorkspace)
            agesPhs = [handles.trackWorkspace(:).longevity];
            visibleCountsPhs = [handles.trackWorkspace(:).visibleCount];
            invisibleCountsPhs = [handles.trackWorkspace(:).invisibleCount];
            visibilityPhs = visibleCountsPhs./agesPhs;

            lostIndsPhs = (agesPhs > handles.agePenalty & visibilityPhs > handles.visibility) | (invisibleCountsPhs < handles.invisibleCount);
            handles.trackWorkspace = handles.trackWorkspace(~lostIndsPhs);
        end
        
        %%%%% Cross-Image Association %%%%%
        
        grnLabel = bwlabel(finaleGrn);
        handles.colourGrn{k} = label2rgb(grnLabel,'jet','k','shuffle');
        propsGrn = regionprops(logical(grnLabel),handles.newGrn{k}(:,:,2),'all');
        
        %%%%% Extract Temporary Cell Properties %%%%%
        
        nGrnCells = length(propsGrn);
        grnCentroid = zeros(nGrnCells,1);
        matchMemory = zeros(numel(grnCentroid),2);
        
        for j = 1:nGrnCells
            grnPixels = propsGrn(j).PixelIdxList;
            grnCentroid(j) = round(median(grnPixels));
        end
        
        %%%%% Find Overlapping Connected Components %%%%%
        
        for j = 1:length(handles.trackWorkspace)
            phsPixels = handles.trackWorkspace(j).pixelIndex;
            matchMaker = ismember(grnCentroid,phsPixels);
            matchMemory(matchMaker,1) = find(matchMaker);
            matchMemory(matchMaker,2) = handles.trackWorkspace(j).labelIndex;
        end
        
        matchMemory(~any(matchMemory,2),:) = [];
        
        %%%%% Remove Duplicate Associations %%%%%
        
        [~,grnUniqueInd] = unique(matchMemory(:,1));
        grnUnique = matchMemory(grnUniqueInd,:);
        
        [~,phsUniqueInd] = unique(grnUnique(:,2));
        uniqueMatch = grnUnique(phsUniqueInd,:);
        
        %%%%% Update Tracking Workspace %%%%%
        
        intensitListGrn = cat(1,propsGrn.MeanIntensity);
        for j = 1:length(uniqueMatch)
            argPhs = [handles.trackWorkspace.labelIndex];
            argMatch = ismember(argPhs,uniqueMatch(j,2));
            handles.trackWorkspace(argMatch).intensityGFP = intensitListGrn(uniqueMatch(j,1));
        end
        
        %%%%% Cross-Image Association %%%%%
        
        redLabel = bwlabel(finaleRed);
        handles.colourRed{k} = label2rgb(redLabel,'jet','k','shuffle');
        propsRed = regionprops(logical(redLabel),handles.newRed{k}(:,:,2),'all');
        
        %%%%% Extract Temporary Cell Properties %%%%%
        
        nRedCells = length(propsRed);
        redCentroid = zeros(nRedCells,1);
        matchMemory = zeros(numel(redCentroid),2);
        
        for j = 1:nRedCells
            redPixels = propsRed(j).PixelIdxList;
            redCentroid(j) = round(median(redPixels));
        end
        
        %%%%% Find Overlapping Connected Components %%%%%
        
        for j = 1:length(handles.trackWorkspace)
            grnPixels = handles.trackWorkspace(j).pixelIndex;
            matchMaker = ismember(redCentroid,grnPixels);
            matchMemory(matchMaker,1) = find(matchMaker);
            matchMemory(matchMaker,2) = handles.trackWorkspace(j).labelIndex;
        end
        
        matchMemory(~any(matchMemory,2),:) = [];
        
        %%%%% Remove Duplicate Associations %%%%%
        
        [~,redUniqueInd] = unique(matchMemory(:,1));
        redUnique = matchMemory(redUniqueInd,:);
        
        [~,grnUniqueInd] = unique(redUnique(:,2));
        uniqueMatch = redUnique(grnUniqueInd,:);
        
        %%%%% Update Tracking Workspace %%%%%
        
        intensitListRed = cat(1,propsRed.MeanIntensity);
        for j = 1:length(uniqueMatch)
            argGrn = [handles.trackWorkspace.labelIndex];
            argMatch = ismember(argGrn,uniqueMatch(j,2));
            handles.trackWorkspace(argMatch).intensityRFP = intensitListRed(uniqueMatch(j,1));
        end
        
        %%%%% Compute Intensity Ratio %%%%%
        
        for j = 1:length(handles.trackWorkspace)
            gfpList = handles.trackWorkspace(j).intensityGFP;
            rfpList = handles.trackWorkspace(j).intensityRFP;
            handles.trackWorkspace(j).intensityDIV = rfpList/gfpList;
        end
        
        
        nancom = [handles.trackWorkspace.intensityDIV];
        if any(isnan(nancom))
            [handles.trackWorkspace(isnan(nancom)).intensityDIV] = deal(0);
        end
        if any(isinf(nancom))
            [handles.trackWorkspace(isinf(nancom)).intensityDIV] = deal(0);
        end
        
        %%%%% Tracking Workspace Memory Storage %%%%%
        
        handles.workspaceMemory{k} = handles.trackWorkspace;
        
        %%%%% Display Tracking Indices %%%%%
        
        imagesc(handles.newPhs{k}*handles.bright(1),'Parent',handles.imageDisplay);
        set(handles.imageDisplay,'XTick',[],'YTick',[])
        
        if ~isempty(handles.trackWorkspace)
            
            indicesPhs = [handles.trackWorkspace(:).labelIndex];
            matBoxPhs = cat(1,handles.trackWorkspace.boundingBox);
            
            encBoxPhs = matBoxPhs;
            encBoxPhs(:,4) = matBoxPhs(:,4)./4;
            encBoxPhs(:,2) = matBoxPhs(:,2) - matBoxPhs(:,4)./4;
            idxBoxPhs = [encBoxPhs(:,1) + encBoxPhs(:,3)./2 , encBoxPhs(:,2) + encBoxPhs(:,4)./2];
            
            for j = 1:length(indicesPhs)
                boxPhs = rectangle('Position',matBoxPhs(j,:),'Parent',handles.imageDisplay);
                set(boxPhs,'EdgeColor',handles.boxColour)
                moxPhs = rectangle('Position',encBoxPhs(j,:),'Parent',handles.imageDisplay);
                set(moxPhs,'FaceColor',handles.boxColour)
                
                indexPhs = text(idxBoxPhs(j,1),idxBoxPhs(j,2),num2str(indicesPhs(j)),'Parent',handles.imageDisplay);
                set(indexPhs,'FontSize',10,'Color',handles.indColour)
            end
            
        end
        
        %%%%% Burn Primitives onto Image %%%%%
        
        currentFrame = getframe(handles.imageDisplay);
        handles.trackedImagesPhs{k} = frame2im(currentFrame);
        imagesc(handles.trackedImagesPhs{k},'Parent',handles.imageDisplay);
        set(handles.imageDisplay,'XTick',[],'YTick',[])
        drawnow
        
        %%%%% Display Tracking Indices %%%%%
        
        imagesc(handles.newGrn{k}*handles.bright(2),'Parent',handles.imageDisplay);
        set(handles.imageDisplay,'XTick',[],'YTick',[])
        
        if ~isempty(handles.trackWorkspace)
            
            indicesPhs = [handles.trackWorkspace(:).labelIndex];
            matBoxPhs = cat(1,handles.trackWorkspace.boundingBox);
            
            encBoxPhs = matBoxPhs;
            encBoxPhs(:,4) = matBoxPhs(:,4)./4;
            encBoxPhs(:,2) = matBoxPhs(:,2) - matBoxPhs(:,4)./4;
            idxBoxPhs = [encBoxPhs(:,1) + encBoxPhs(:,3)./2 , encBoxPhs(:,2) + encBoxPhs(:,4)./2];
            
            for j = 1:length(indicesPhs)
                boxPhs = rectangle('Position',matBoxPhs(j,:),'Parent',handles.imageDisplay);
                set(boxPhs,'EdgeColor',handles.boxColour)
                moxPhs = rectangle('Position',encBoxPhs(j,:),'Parent',handles.imageDisplay);
                set(moxPhs,'FaceColor',handles.boxColour)
                
                indexPhs = text(idxBoxPhs(j,1),idxBoxPhs(j,2),num2str(indicesPhs(j)),'Parent',handles.imageDisplay);
                set(indexPhs,'FontSize',10,'Color',handles.indColour)
            end
            
        end
        
        %%%%% Burn Primitives onto Image %%%%%
        
        currentFrame = getframe(handles.imageDisplay);
        handles.trackedImagesGrn{k} = frame2im(currentFrame);
        
        %%%%% Display Tracking Indices %%%%%
        
        imagesc(handles.newRed{k}*handles.bright(3),'Parent',handles.imageDisplay);
        set(handles.imageDisplay,'XTick',[],'YTick',[])
        
        if ~isempty(handles.trackWorkspace)
            
            indicesPhs = [handles.trackWorkspace(:).labelIndex];
            matBoxPhs = cat(1,handles.trackWorkspace.boundingBox);
            
            encBoxPhs = matBoxPhs;
            encBoxPhs(:,4) = matBoxPhs(:,4)./4;
            encBoxPhs(:,2) = matBoxPhs(:,2) - matBoxPhs(:,4)./4;
            idxBoxPhs = [encBoxPhs(:,1) + encBoxPhs(:,3)./2 , encBoxPhs(:,2) + encBoxPhs(:,4)./2];
            
            for j = 1:length(indicesPhs)
                boxPhs = rectangle('Position',matBoxPhs(j,:),'Parent',handles.imageDisplay);
                set(boxPhs,'EdgeColor',handles.boxColour)
                moxPhs = rectangle('Position',encBoxPhs(j,:),'Parent',handles.imageDisplay);
                set(moxPhs,'FaceColor',handles.boxColour)
                
                indexPhs = text(idxBoxPhs(j,1),idxBoxPhs(j,2),num2str(indicesPhs(j)),'Parent',handles.imageDisplay);
                set(indexPhs,'FontSize',10,'Color',handles.indColour)
            end
            
        end
        
        %%%%% Burn Primitives onto Image %%%%%
        currentFrame = getframe(handles.imageDisplay);
        handles.trackedImagesRed{k} = frame2im(currentFrame);
        
        %%%%% Set Filename Popup List State %%%%%
        imagesc(handles.trackedImagesGrn{k},'Parent',handles.imageDisplay);
        set(handles.imageDisplay,'XTick',[],'YTick',[])
        set(handles.filenamePop,'Value',2);
        
        %%%%% Amass Centroids %%%%%
        cellID = [handles.trackWorkspace.labelIndex];
        
        for j = 1:length(cellID)
            
            tempID = cellID(j);
            tempHi = find(ismember(cellID,tempID));
            
            handles.stateEstGrn{k}(tempID,1) = tempID;
            handles.stateEstRed{k}(tempID,1) = tempID;
            handles.stateEstGrn{k}(tempID,2) = handles.trackWorkspace(tempHi).centroidGrn(1);
            handles.stateEstRed{k}(tempID,2) = handles.trackWorkspace(tempHi).centroidRed(1);
            handles.stateEstGrn{k}(tempID,3) = handles.trackWorkspace(tempHi).centroidGrn(2);
            handles.stateEstRed{k}(tempID,3) = handles.trackWorkspace(tempHi).centroidRed(2);
            
        end
        
        handles.stateEstGrn{k}(handles.stateEstGrn{k} == 0) = NaN;
        handles.stateEstRed{k}(handles.stateEstRed{k} == 0) = NaN;
        
        %%%%% Cell by Cell Recollection
        for j = 1:length(handles.stateEstGrn{k})
            handles.tempPosGrn{j}(1,k) = handles.stateEstGrn{k}(j,2);
            handles.tempPosGrn{j}(2,k) = handles.stateEstGrn{k}(j,3);
            handles.tempPosGrn{j}(handles.tempPosGrn{j} == 0) = NaN;
        end
        
        %%%%% Cell by Cell Recollection
        for j = 1:length(handles.stateEstRed{k})
            handles.tempPosRed{j}(1,k) = handles.stateEstRed{k}(j,2);
            handles.tempPosRed{j}(2,k) = handles.stateEstRed{k}(j,3);
            handles.tempPosRed{j}(handles.tempPosRed{j} == 0) = NaN;
        end
        
        %%%%% Processing Time %%%%%
        minutes = (toc*(handles.nImages - k))/60;
        seconds = rem(minutes,1)*60;
        
        if minutes < 1; minutes = 0;
        else            minutes = round(minutes);
        end
        
        if seconds < 1; seconds = 0;
        else            seconds = round(seconds);
            if seconds == 60; minutes = 1; seconds = 0; end
        end
        
        %%%%% "Estimated Remaining Time" Message %%%%%
        tempStatus = cellstr(get(handles.statusList,'String'));
        initStatus = [tempStatus ; sprintf(['The Estimated Remaining Time is ',num2str(minutes),' mins ',num2str(seconds),' s'])];
        set(handles.statusList,'String',initStatus)
        lastMsg = numel(get(handles.statusList,'String'));
        set(handles.statusList,'Value',lastMsg)
        drawnow
        
    end
    
    if k == handles.nImages
        
        %%%%% "Tracking Complete" Message %%%%%
        tempStatus = cellstr(get(handles.statusList,'String'));
        initStatus = [tempStatus ; handles.messages{9}];
        set(handles.statusList,'String',initStatus)
        lastMsg = numel(get(handles.statusList,'String'));
        set(handles.statusList,'Value',lastMsg)
        drawnow
        
        %%%%% "Gathering Cytometric Data" Message %%%%%
        tempStatus = cellstr(get(handles.statusList,'String'));
        initStatus = [tempStatus ; handles.messages{16}];
        set(handles.statusList,'String',initStatus)
        lastMsg = numel(get(handles.statusList,'String'));
        set(handles.statusList,'Value',lastMsg)
        drawnow
        
        %%%%% Allocate Raw Data %%%%%
        for k = 1:numel(handles.workspaceMemory)
            handles.IDList = [handles.workspaceMemory{k}.labelIndex];
            GFPList = [handles.workspaceMemory{k}.intensityGFP];
            RFPList = [handles.workspaceMemory{k}.intensityRFP];
            DIVList = [handles.workspaceMemory{k}.intensityDIV];
            GFPMatrix(handles.IDList,k) = GFPList;
            RFPMatrix(handles.IDList,k) = RFPList;
            DIVMatrix(handles.IDList,k) = DIVList;
        end
        
        GFPMatrix(GFPMatrix == 0) = NaN;
        RFPMatrix(RFPMatrix == 0) = NaN;
        DIVMatrix(DIVMatrix == 0) = NaN;
        
        %%%%% Normalise Data %%%%%
        minGFP = min(min(GFPMatrix));
        maxGFP = max(max(GFPMatrix));
        minRFP = min(min(RFPMatrix));
        maxRFP = max(max(RFPMatrix));
        minDIV = min(min(DIVMatrix));
        maxDIV = max(max(DIVMatrix));
        
        handles.normalGFP = (GFPMatrix - minGFP)./(maxGFP - minGFP);
        handles.normalRFP = (RFPMatrix - minRFP)./(maxRFP - minRFP);
        handles.normalDIV = (DIVMatrix - minDIV)./(maxDIV - minDIV);
        
        handles.normalGFP(handles.normalGFP == 0) = NaN;
        handles.normalRFP(handles.normalRFP == 0) = NaN;
        handles.normalDIV(handles.normalDIV == 0) = NaN;
        
        %%%%% Plot Normalised Data %%%%%
        framers = handles.firstFrame:handles.nImages;
        for k = 1:length(handles.IDList)
            plot(handles.plotDisplay,framers,handles.normalGFP(k,:),'-')
            set(handles.plotDisplay,'XLim',[handles.firstFrame handles.nImages])
            set(handles.plotDisplay,'XTickLabel',{})
            set(handles.plotDisplay,'YTickLabel',{})
            hold(handles.plotDisplay,'on')
            drawnow
        end
        
        %%%%% Include First Column Cell ID %%%%%
        sizerGFP = size(handles.normalGFP); countGFP = 1:sizerGFP(1);
        sizerRFP = size(handles.normalRFP); countRFP = 1:sizerRFP(1);
        sizerDIV = size(handles.normalDIV); countDIV = 1:sizerDIV(1);
        
        handles.GFPMatrix = [countGFP' handles.normalGFP];
        handles.RFPMatrix = [countRFP' handles.normalRFP];
        handles.DIVMatrix = [countDIV' handles.normalDIV];
        
        %%%%% Set Default GFP Data Table Tab %%%%%
        set(handles.gfpRadio,'Value',1)
        set(handles.dataTable,'Data',handles.GFPMatrix)
        set(handles.dataTable,'RowName',1:size(handles.GFPMatrix,1))
        
        %%%%% "Cytometric Data Acquisition Complete" Message %%%%%
        tempStatus = cellstr(get(handles.statusList,'String'));
        initStatus = [tempStatus ; handles.messages{17}];
        set(handles.statusList,'String',initStatus)
        lastMsg = numel(get(handles.statusList,'String'));
        set(handles.statusList,'Value',lastMsg)
        drawnow
        
    else
        
        %%%%% "Process Aborted" Message %%%%%
        tempStatus = cellstr(get(handles.statusList,'String'));
        initStatus = [tempStatus ; handles.messages{22}];
        set(handles.statusList,'String',initStatus)
        lastMsg = numel(get(handles.statusList,'String'));
        set(handles.statusList,'Value',lastMsg)
        drawnow
        
    end
    
end

guidata(hObject,handles)

%%%%% "Play" Toggle Button %%%%%
function playToggle_Callback(hObject,~,handles)

zoom(handles.imageDisplay,'off')
% video(handles.nImages) = struct('cdata',[],'colormap',[]);

%%%%% Extract Brightness Settings %%%%%
handles.bright(1,1:3) = str2num(get(handles.brightEdit,'String'));
if numel(handles.bright) == 1
   handles.bright(1,1:3) = repmat(handles.bright(1),[1 3]);
end

try
    
    %%%%% Extract Tab State %%%%%
    rawradio = get(handles.rawRadio,'Value');
    segradio = get(handles.segRadio,'Value');
    traradio = get(handles.traRadio,'Value');
    
    %%%%% Extract Filename Popup List State %%%%%
    filePopup = get(handles.filenamePop,'Value');
    
    %%%%% Extract Frame Interval Specification %%%%%
    handles.nImages = str2double(get(handles.toEdit,'String'));
    set(handles.frameStatic,'String',sprintf(['Frame ',num2str(handles.firstFrame),'/',num2str(handles.nImages)]))
    
    %%%%% Play Raw Image %%%%%
    if (rawradio == 1) && (segradio == 0) && (traradio == 0)
        for k = handles.firstFrame:handles.nImages
            
            %%%%% Pause Play Button %%%%%
            if get(handles.playToggle,'Value') == 0
                handles.firstFrame = k;
                set(handles.playToggle,'String','Paused')
                guidata(hObject,handles)
                return
            else
                %%%%% Playe Play Button %%%%%
                set(handles.playToggle,'String','Play')
                if filePopup == 2
                    imagesc(handles.imageListPhs{k}*handles.bright(1),'Parent',handles.imageDisplay);
                elseif filePopup == 3
                    imagesc(handles.imageListGrn{k}*handles.bright(2),'Parent',handles.imageDisplay);
                elseif filePopup == 4
                    imagesc(handles.imageListRed{k}*handles.bright(3),'Parent',handles.imageDisplay);
                end
                set(handles.imageDisplay,'XTick',[],'YTick',[])
                set(handles.frameStatic,'String',sprintf(['Frame ',num2str(k),'/',num2str(handles.nImages)]))
                drawnow
                pause(handles.speed)
%                 video(k) = getframe(handles.imageDisplay);
                handles.remember = k;
            end
        end
        handles.firstFrame = str2double(get(handles.fromEdit,'String'));
        guidata(hObject,handles)
        
    %%%%% Play Segmented Image %%%%%
    elseif (rawradio == 0) && (segradio == 1) && (traradio == 0)
        for k = handles.firstFrame:handles.nImages
            
            %%%%% Pause Play Button %%%%%
            if get(handles.playToggle,'Value') == 0
                handles.firstFrame = k;
                set(handles.playToggle,'String','Paused')
                guidata(hObject,handles)
                return
            else
                %%%%% Playe Play Button %%%%%
                set(handles.playToggle,'String','Play')
                if filePopup == 2
                    imagesc(handles.colourPhs{k},'Parent',handles.imageDisplay);
                elseif filePopup == 3
                    imagesc(handles.colourGrn{k},'Parent',handles.imageDisplay);
                elseif filePopup == 4
                    imagesc(handles.colourRed{k},'Parent',handles.imageDisplay);
                end
                set(handles.imageDisplay,'XTick',[],'YTick',[])
                set(handles.frameStatic,'String',sprintf(['Frame ',num2str(k),'/',num2str(handles.nImages)]))
                drawnow
                pause(handles.speed)
                handles.remember = k;
            end
        end
        handles.firstFrame = str2double(get(handles.fromEdit,'String'));
        guidata(hObject,handles)
        
    %%%%% Play Tracked Image %%%%%
    elseif (rawradio == 0) && (segradio == 0) && (traradio == 1)
        for k = handles.firstFrame:handles.nImages
            
            %%%%% Pause Play Button %%%%%
            if get(handles.playToggle,'Value') == 0
                handles.firstFrame = k;
                set(handles.playToggle,'String','Paused')
                guidata(hObject,handles)
                return
            else
                %%%%% Playe Play Button %%%%%
                set(handles.playToggle,'String','Play')
                if filePopup == 2
                    imagesc(handles.trackedImagesPhs{k},'Parent',handles.imageDisplay);
                elseif filePopup == 3
                    imagesc(handles.trackedImagesGrn{k},'Parent',handles.imageDisplay);
                elseif filePopup == 4
                    imagesc(handles.trackedImagesRed{k},'Parent',handles.imageDisplay);
                end
                set(handles.imageDisplay,'XTick',[],'YTick',[])
                set(handles.frameStatic,'String',sprintf(['Frame ',num2str(k),'/',num2str(handles.nImages)]))
                drawnow
                pause(handles.speed)
                handles.remember = k;
            end
        end
        handles.firstFrame = str2double(get(handles.fromEdit,'String'));
        guidata(hObject,handles)
        
    end
    
catch
    %%%% "Not Enough Input Arguments" Message %%%%%
    tempStatus = cellstr(get(handles.statusList,'String'));
    initStatus = [tempStatus ; handles.messages{6}];
    set(handles.statusList,'String',initStatus)
    lastMsg = numel(get(handles.statusList,'String'));
    set(handles.statusList,'Value',lastMsg)
    drawnow
end

%%%%% Reset "Play" Toggle Button %%%%%
set(handles.playToggle,'Value',0)
% movie2avi(video,'poof.avi','Compression','None','fps',5)

guidata(hObject,handles)

%%%%% Frame Slider %%%%%
function frameSlider_Callback(hObject,~,handles)

zoom(handles.imageDisplay,'off')

%%%%% Extract Brightness Settings %%%%%
handles.bright(1,1:3) = str2num(get(handles.brightEdit,'String'));
if numel(handles.bright) == 1
   handles.bright(1,1:3) = repmat(handles.bright(1),[1 3]);
end

try
    
    %%%%% Extract Tab State %%%%%
    rawradio = get(handles.rawRadio,'Value');
    segradio = get(handles.segRadio,'Value');
    traradio = get(handles.traRadio,'Value');
    
    %%%%% Extract Filenames Popup Menu State %%%%%
    filePopup = get(handles.filenamePop,'Value');
    
    %%%%% Extract Current Slider Location %%%%%
    indexes = round(get(hObject,'Value'));
    
    %%%%% Slide Raw Image %%%%%
    if (rawradio == 1) && (segradio == 0) && (traradio == 0)
        if filePopup == 2
            imagesc(handles.imageListPhs{indexes}*handles.bright(1),'Parent',handles.imageDisplay);
        elseif filePopup == 3
            imagesc(handles.imageListGrn{indexes}*handles.bright(2),'Parent',handles.imageDisplay);
        elseif filePopup == 4
            imagesc(handles.imageListRed{indexes}*handles.bright(3),'Parent',handles.imageDisplay);
        end
        
        %%%%% Slide Segmented Image %%%%%
    elseif (rawradio == 0) && (segradio == 1) && (traradio == 0)
        if filePopup == 2
            imagesc(handles.colourPhs{indexes},'Parent',handles.imageDisplay);
        elseif filePopup == 3
            imagesc(handles.colourGrn{indexes},'Parent',handles.imageDisplay);
        elseif filePopup == 4
            imagesc(handles.colourRed{indexes},'Parent',handles.imageDisplay);
        end
        
        %%%%% Slide Tracked Image %%%%%
    elseif (rawradio == 0) && (segradio == 0) && (traradio == 1)
        if filePopup == 2
            imagesc(handles.trackedImagesPhs{indexes},'Parent',handles.imageDisplay);
        elseif filePopup == 3
            imagesc(handles.trackedImagesGrn{indexes},'Parent',handles.imageDisplay);
        elseif filePopup == 4
            imagesc(handles.trackedImagesRed{indexes},'Parent',handles.imageDisplay);
        end
    end
    
    set(handles.imageDisplay,'XTick',[],'YTick',[])
    set(handles.frameStatic,'String',sprintf(['Frame ',num2str(indexes),'/',num2str(handles.nImages)]))
    
catch
    %%%% "Not Enough Input Arguments" Message %%%%%
    tempStatus = cellstr(get(handles.statusList,'String'));
    initStatus = [tempStatus ; handles.messages{7}];
    set(handles.statusList,'String',initStatus)
    lastMsg = numel(get(handles.statusList,'String'));
    set(handles.statusList,'Value',lastMsg)
    drawnow
end

guidata(hObject,handles)

%%%%% "Raw Image" Radio Button %%%%%
function rawRadio_Callback(hObject,~,handles)

zoom(handles.imageDisplay,'off')

%%%%% Extract Brightness Settings %%%%%
handles.bright(1,1:3) = str2num(get(handles.brightEdit,'String'));
if numel(handles.bright) == 1
   handles.bright(1,1:3) = repmat(handles.bright(1),[1 3]);
end

try
    %%%%% Display Raw Images of Channels %%%%%
    if get(handles.filenamePop,'Value') == 2
        imagesc(handles.imageListPhs{handles.firstFrame}*handles.bright(1),'Parent',handles.imageDisplay);
    elseif get(handles.filenamePop,'Value') == 3
        imagesc(handles.imageListGrn{handles.firstFrame}*handles.bright(2),'Parent',handles.imageDisplay);
    elseif get(handles.filenamePop,'Value') == 4
        imagesc(handles.imageListRed{handles.firstFrame}*handles.bright(3),'Parent',handles.imageDisplay);
    end
    set(handles.imageDisplay,'XTick',[],'YTick',[])
catch
    %%%%% "Files Not Loaded" Message %%%%%
    tempStatus = cellstr(get(handles.statusList,'String'));
    initStatus = [tempStatus ; handles.messages{7}];
    set(handles.statusList,'String',initStatus)
    lastMsg = numel(get(handles.statusList,'String'));
    set(handles.statusList,'Value',lastMsg)
    drawnow
end

guidata(hObject,handles)

%%%%% "Segmented Image" Radio Button %%%%%
function segRadio_Callback(hObject,~,handles)

zoom(handles.imageDisplay,'off')

try
    %%%%% Display Segmented Images of Channels %%%%%
    if get(handles.filenamePop,'Value') == 2
        imagesc(handles.colourPhs{handles.firstFrame},'Parent',handles.imageDisplay);
    elseif get(handles.filenamePop,'Value') == 3
        imagesc(handles.colourGrn{handles.firstFrame},'Parent',handles.imageDisplay);
    elseif get(handles.filenamePop,'Value') == 4
        imagesc(handles.colourRed{handles.firstFrame},'Parent',handles.imageDisplay);
    end
    set(handles.imageDisplay,'XTick',[],'YTick',[])
catch
    %%%%% "No Output Arguments Detected" Message %%%%%
    tempStatus = cellstr(get(handles.statusList,'String'));
    initStatus = [tempStatus ; handles.messages{10}];
    set(handles.statusList,'String',initStatus)
    lastMsg = numel(get(handles.statusList,'String'));
    set(handles.statusList,'Value',lastMsg)
    drawnow
end

guidata(hObject,handles)

%%%%% "Tracked Image" Radio Button %%%%%
function traRadio_Callback(hObject,~, handles)

zoom(handles.imageDisplay,'off')

try
    %%%% Display Tracked Images of Channels %%%%%
    if get(handles.filenamePop,'Value') == 2
        imagesc(handles.trackedImagesPhs{handles.firstFrame},'Parent',handles.imageDisplay);
    elseif get(handles.filenamePop,'Value') == 3
        imagesc(handles.trackedImagesGrn{handles.firstFrame},'Parent',handles.imageDisplay);
    elseif get(handles.filenamePop,'Value') == 4
        imagesc(handles.trackedImagesRed{handles.firstFrame},'Parent',handles.imageDisplay);
    end
    set(handles.imageDisplay,'XTick',[],'YTick',[])
catch
    %%%%% "No Output Arguments Detected" Message %%%%%
    tempStatus = cellstr(get(handles.statusList,'String'));
    initStatus = [tempStatus ; handles.messages{10}];
    set(handles.statusList,'String',initStatus)
    lastMsg = numel(get(handles.statusList,'String'));
    set(handles.statusList,'Value',lastMsg)
    drawnow
end

guidata(hObject,handles)

%%%%% Cell Channel Popup Menu %%%%%
function filenamePop_Callback(hObject,~,handles)

zoom(handles.imageDisplay,'off')

%%%%% Extract Brightness Settings %%%%%
handles.bright(1,1:3) = str2num(get(handles.brightEdit,'String'));
if numel(handles.bright) == 1
   handles.bright(1,1:3) = repmat(handles.bright(1),[1 3]);
end

%%%%% Extract Tab State %%%%%
rawradio = get(handles.rawRadio,'Value');
segradio = get(handles.segRadio,'Value');
traradio = get(handles.traRadio,'Value');

%%%%% Display Raw Images %%%%%
if (rawradio == 1) && (segradio == 0) && (traradio == 0)
    if get(handles.filenamePop,'Value') == 2
        imagesc(handles.imageListPhs{handles.firstFrame}*handles.bright(1),'Parent',handles.imageDisplay);
    elseif get(handles.filenamePop,'Value') == 3
        imagesc(handles.imageListGrn{handles.firstFrame}*handles.bright(2),'Parent',handles.imageDisplay);
    elseif get(handles.filenamePop,'Value') == 4
        imagesc(handles.imageListRed{handles.firstFrame}*handles.bright(3),'Parent',handles.imageDisplay);
    end
    
    %%%%% Display Segmented Images %%%%%
elseif (rawradio == 0) && (segradio == 1) && (traradio == 0)
    if get(handles.filenamePop,'Value') == 2
        imagesc(handles.colourPhs{handles.firstFrame},'Parent',handles.imageDisplay);
    elseif get(handles.filenamePop,'Value') == 3
        imagesc(handles.colourGrn{handles.firstFrame},'Parent',handles.imageDisplay);
    elseif get(handles.filenamePop,'Value') == 4
        imagesc(handles.colourRed{handles.firstFrame},'Parent',handles.imageDisplay);
    end
    
    %%%%% Display Tracked Images %%%%%
elseif (rawradio == 0) && (segradio == 0) && (traradio == 1)
    if get(handles.filenamePop,'Value') == 2
        imagesc(handles.trackedImagesPhs{handles.firstFrame},'Parent',handles.imageDisplay);
    elseif get(handles.filenamePop,'Value') == 3
        imagesc(handles.trackedImagesGrn{handles.firstFrame},'Parent',handles.imageDisplay);
    elseif get(handles.filenamePop,'Value') == 4
        imagesc(handles.trackedImagesRed{handles.firstFrame},'Parent',handles.imageDisplay);
    end
end

set(handles.imageDisplay,'XTick',[],'YTick',[])
guidata(hObject,handles)

%%%%% "Play Isolate Cell" Push Button %%%%%
function isolatePush_Callback(hObject,~,handles)

zoom(handles.imageDisplay,'off')

cla(handles.plotDisplay)
cellID = str2num(get(handles.isolateEdit,'String'));

%%%%% Extract Line Colour Specification %%%%%
linColours = {'m','y','g','w','c','k','b','r'};
linColour = get(handles.linColPop,'Value');
lineColour = linColours{linColour};

%%%%% Extract Frame Interval Specification %%%%%
handles.firstFrame = str2double(get(handles.fromEdit,'String'));
handles.nImages = str2double(get(handles.toEdit,'String'));
set(handles.frameStatic,'String',sprintf(['Frame ',num2str(handles.firstFrame),'/',num2str(handles.nImages)]))

video(handles.nImages) = struct('cdata',[],'colormap',[]);

%%%%% Play Phase-Contrast Isolated Cell Movie %%%%%
if get(handles.filenamePop,'Value') == 2
    
    try
        %%%%% Play Isolated Cell Movie %%%%%
        for k = handles.firstFrame:handles.nImages
            
            blankImage = false(size(handles.imageListPhs{1},1),size(handles.imageListPhs{1},2));
            pixelList = [handles.workspaceMemory{k}.labelIndex];
            
            for j = 1:length(cellID)
                indPos = ismember(pixelList,cellID(j));
                if any(indPos)
                    memoryPix = handles.workspaceMemory{k}(indPos).pixelIndex;
                else
                    continue
                end
                blankImage(memoryPix) = true;
            end
            
            overPhs = bsxfun(@times,handles.imageListPhs{k},cast(blankImage,'like',handles.imageListPhs{k}));
            overPhs = overPhs*handles.bright(1);
            imagesc(overPhs,'Parent',handles.imageDisplay);
            set(handles.imageDisplay,'XTick',[],'YTick',[])
            hold on
            
            %%%%% Overlay Bounding Boxes and Corresponding Indices %%%%%
            try
                if ~isempty(handles.trackWorkspace)
                    
                    indicesPhs = [handles.workspaceMemory{k}(cellID).labelIndex];
                    matBoxPhs = cat(1,handles.workspaceMemory{k}(cellID).boundingBox);
                    
                    encBoxPhs = matBoxPhs;
                    encBoxPhs(:,4) = matBoxPhs(:,4)./4;
                    encBoxPhs(:,2) = matBoxPhs(:,2) - matBoxPhs(:,4)./4;
                    idxBoxPhs = [encBoxPhs(:,1) + encBoxPhs(:,3)./2 , encBoxPhs(:,2) + encBoxPhs(:,4)./2];
                    
                    for j = 1:length(indicesPhs)
                        boxPhs = rectangle('Position',matBoxPhs(j,:),'Parent',handles.imageDisplay);
                        set(boxPhs,'EdgeColor',handles.boxColour)
                        moxPhs = rectangle('Position',encBoxPhs(j,:),'Parent',handles.imageDisplay);
                        set(moxPhs,'FaceColor',handles.boxColour)
                        
                        indexPhs = text(idxBoxPhs(j,1),idxBoxPhs(j,2),num2str(indicesPhs(j)),'Parent',handles.imageDisplay);
                        set(indexPhs,'FontSize',10,'Color',handles.indColour)
                    end
                    
                end
            catch
            end
            
            %%%%% Plot Trajectories %%%%%
            if get(handles.marker,'Value') == 1
                for j = 1:length(cellID)
                    xArrays = handles.tempPosGrn{cellID(j)}(1,handles.firstFrame:k);
                    yArrays = handles.tempPosGrn{cellID(j)}(2,handles.firstFrame:k);
                    
                    isnanChecker = isnan(handles.GFPMatrix(cellID,:));
                    xArrays(isnanChecker) = NaN;
                    yArrays(isnanChecker) = NaN;
                    
                    plotHandle = plot(xArrays,yArrays,'-','Parent',handles.imageDisplay);
                    set(plotHandle,'LineWidth',1,'Color',lineColour)
                end
            end
            
            drawnow
            hold off
            
            set(handles.frameStatic,'String',sprintf(['Frame ',num2str(k),'/',num2str(handles.nImages)]))
            pause(handles.speed)
            video(k) = getframe(handles.imageDisplay);
            
        end
        
        %%%%% Plot Isolated Cell Graph %%%%%
        framers = handles.firstFrame:handles.nImages;
        for k = 1:length(cellID)
            plot(handles.plotDisplay,framers,handles.normalDIV(cellID(k),:),'-')
            set(handles.plotDisplay,'XLim',[handles.firstFrame handles.nImages])
            set(handles.plotDisplay,'XTickLabel',{})
            set(handles.plotDisplay,'YTickLabel',{})
            hold(handles.plotDisplay,'on')
            drawnow
        end
        
    catch
        %%%% "Selected Label Index Unavailable" Message %%%%%
        tempStatus = cellstr(get(handles.statusList,'String'));
        initStatus = [tempStatus ; handles.messages{18}];
        set(handles.statusList,'String',initStatus)
        lastMsg = numel(get(handles.statusList,'String'));
        set(handles.statusList,'Value',lastMsg)
        drawnow
    end
    
end

%%%%% Play Cytoplasm Isolated Cell Movie %%%%%
if get(handles.filenamePop,'Value') == 3
    
    try
        %%%%% Play Isolated Cell Movie %%%%%
        for k = handles.firstFrame:handles.nImages
            
            blankImage = false(size(handles.imageListGrn{1},1),size(handles.imageListGrn{1},2));
            pixelList = [handles.workspaceMemory{k}.labelIndex];
            
            for j = 1:length(cellID)
                indPos = ismember(pixelList,cellID(j));
                if any(indPos)
                    memoryPix = handles.workspaceMemory{k}(indPos).pixelIndex;
                else
                    continue
                end
                blankImage(memoryPix) = true;
            end
            
            overGrn = bsxfun(@times,handles.newGrn{k},cast(blankImage,'like',handles.newGrn{k}));
            overGrn = overGrn*handles.bright(2);
            imagesc(overGrn,'Parent',handles.imageDisplay);
            set(handles.imageDisplay,'XTick',[],'YTick',[])
            hold on
            
            %%%%% Overlay Bounding Boxes and Corresponding Indices %%%%%
            if ~isempty(handles.trackWorkspace)
                
                indicesPhs = [handles.workspaceMemory{k}(cellID).labelIndex];
                matBoxPhs = cat(1,handles.workspaceMemory{k}(cellID).boundingBox);
                
                encBoxPhs = matBoxPhs;
                encBoxPhs(:,4) = matBoxPhs(:,4)./4;
                encBoxPhs(:,2) = matBoxPhs(:,2) - matBoxPhs(:,4)./4;
                idxBoxPhs = [encBoxPhs(:,1) + encBoxPhs(:,3)./2 , encBoxPhs(:,2) + encBoxPhs(:,4)./2];
                
                for j = 1:length(indicesPhs)
                    boxPhs = rectangle('Position',matBoxPhs(j,:),'Parent',handles.imageDisplay);
                    set(boxPhs,'EdgeColor',handles.boxColour)
                    moxPhs = rectangle('Position',encBoxPhs(j,:),'Parent',handles.imageDisplay);
                    set(moxPhs,'FaceColor',handles.boxColour)
                    
                    indexPhs = text(idxBoxPhs(j,1),idxBoxPhs(j,2),num2str(indicesPhs(j)),'Parent',handles.imageDisplay);
                    set(indexPhs,'FontSize',10,'Color',handles.indColour)
                end
                
            end
            
            %%%%% Plot Trajectories %%%%%
            if get(handles.marker,'Value') == 1
                for j = 1:length(cellID)
                    xArrays = handles.tempPosGrn{cellID(j)}(1,handles.firstFrame:k);
                    yArrays = handles.tempPosGrn{cellID(j)}(2,handles.firstFrame:k);
                    
                    isnanChecker = isnan(handles.GFPMatrix(cellID,:));
                    xArrays(isnanChecker) = NaN;
                    yArrays(isnanChecker) = NaN;
                    
                    plotHandle = plot(xArrays,yArrays,'-','Parent',handles.imageDisplay);
                    set(plotHandle,'LineWidth',1,'Color',lineColour)
                end
            end
            
            drawnow
            hold off
            
            set(handles.frameStatic,'String',sprintf(['Frame ',num2str(k),'/',num2str(handles.nImages)]))
            pause(handles.speed)
            
        end
        
        %%%%% Plot Isolated Cell Graph %%%%%
        framers = handles.firstFrame:handles.nImages;
        for k = 1:length(cellID)
            plot(handles.plotDisplay,framers,handles.normalGFP(cellID(k),:),'-')
            set(handles.plotDisplay,'XLim',[handles.firstFrame handles.nImages])
            set(handles.plotDisplay,'XTickLabel',{})
            set(handles.plotDisplay,'YTickLabel',{})
            hold(handles.plotDisplay,'on')
            drawnow
        end
        
    catch
        %%%%% "Selected Label Index Unavailable" Message %%%%%
        tempStatus = cellstr(get(handles.statusList,'String'));
        initStatus = [tempStatus ; handles.messages{18}];
        set(handles.statusList,'String',initStatus)
        lastMsg = numel(get(handles.statusList,'String'));
        set(handles.statusList,'Value',lastMsg)
        drawnow
    end
    
end

%%%%% Play Nucleus Isolated Cell Movie %%%%%
if get(handles.filenamePop,'Value') == 4
    
    try
        %%%%% Play Isolated Cell Movie %%%%%
        for k = handles.firstFrame:handles.nImages
            
            blankImage = false(size(handles.imageListRed{1},1),size(handles.imageListRed{1},2));
            pixelList = [handles.workspaceMemory{k}.labelIndex];
            
            for j = 1:length(cellID)
                indPos = ismember(pixelList,cellID(j));
                if any(indPos)
                    memoryPix = handles.workspaceMemory{k}(indPos).pixelIndex;
                else
                    continue
                end
                blankImage(memoryPix) = true;
            end
            
            overRed = bsxfun(@times,handles.imageListRed{k},cast(blankImage,'like',handles.imageListRed{k}));
            overRed = overRed*handles.bright(3);
            imagesc(overRed,'Parent',handles.imageDisplay);
            set(handles.imageDisplay,'XTick',[],'YTick',[])
            hold on
            
            %%%%% Overlay Bounding Boxes and Corresponding Indices %%%%%
            if ~isempty(handles.trackWorkspace)
                
                indicesPhs = [handles.workspaceMemory{k}(cellID).labelIndex];
                matBoxPhs = cat(1,handles.workspaceMemory{k}(cellID).boundingBox);
                
                encBoxPhs = matBoxPhs;
                encBoxPhs(:,4) = matBoxPhs(:,4)./4;
                encBoxPhs(:,2) = matBoxPhs(:,2) - matBoxPhs(:,4)./4;
                idxBoxPhs = [encBoxPhs(:,1) + encBoxPhs(:,3)./2 , encBoxPhs(:,2) + encBoxPhs(:,4)./2];
                
                for j = 1:length(indicesPhs)
                    boxPhs = rectangle('Position',matBoxPhs(j,:),'Parent',handles.imageDisplay);
                    set(boxPhs,'EdgeColor',handles.boxColour)
                    moxPhs = rectangle('Position',encBoxPhs(j,:),'Parent',handles.imageDisplay);
                    set(moxPhs,'FaceColor',handles.boxColour)
                    
                    indexPhs = text(idxBoxPhs(j,1),idxBoxPhs(j,2),num2str(indicesPhs(j)),'Parent',handles.imageDisplay);
                    set(indexPhs,'FontSize',10,'Color',handles.indColour)
                end
                
            end
            
            %%%%% Plot Trajectories %%%%%
            if get(handles.marker,'Value') == 1
                for j = 1:length(cellID)
                    xArrays = handles.tempPosGrn{cellID(j)}(1,handles.firstFrame:k);
                    yArrays = handles.tempPosGrn{cellID(j)}(2,handles.firstFrame:k);
                    
                    isnanChecker = isnan(handles.GFPMatrix(cellID,:));
                    xArrays(isnanChecker) = NaN;
                    yArrays(isnanChecker) = NaN;
                    
                    plotHandle = plot(xArrays,yArrays,'-','Parent',handles.imageDisplay);
                    set(plotHandle,'LineWidth',1,'Color',lineColour)
                end
            end
            
            drawnow
            hold off
            
            set(handles.frameStatic,'String',sprintf(['Frame ',num2str(k),'/',num2str(handles.nImages)]))
            pause(handles.speed)
            
        end
        
        %%%%% Plot Isolated Cell Graph %%%%%
        framers = handles.firstFrame:handles.nImages;
        for k = 1:length(cellID)
            plot(handles.plotDisplay,framers,handles.normalRFP(cellID(k),:),'-')
            set(handles.plotDisplay,'XLim',[handles.firstFrame handles.nImages])
            set(handles.plotDisplay,'XTickLabel',{})
            set(handles.plotDisplay,'YTickLabel',{})
            hold(handles.plotDisplay,'on')
            drawnow
        end
        
    catch
        %%%%% "Selected Label Index Unavailable" Message %%%%%
        tempStatus = cellstr(get(handles.statusList,'String'));
        initStatus = [tempStatus ; handles.messages{18}];
        set(handles.statusList,'String',initStatus)
        lastMsg = numel(get(handles.statusList,'String'));
        set(handles.statusList,'Value',lastMsg)
        drawnow
    end
    
end

movie2avi(video,'poof.avi','Compression','None','fps',5)

guidata(hObject,handles)

%%%%% "Clear Data" Push Button %%%%%
function clearImagePush_Callback(~,~,handles)

%%%%% Filename Popup List Reset %%%%%
set(handles.filenamePop,'String','Filenames')
set(handles.frameStatic,'String',[])

%%%%% Image and Plot Axes Reset %%%%%
cla(handles.imageDisplay,'reset')
set(handles.imageDisplay,'XTick',[])
set(handles.imageDisplay,'YTick',[])
box(handles.imageDisplay,'on')

%%%%% Handle Variables Reset %%%%%
clear handles.nFrames
clear handles.nImages
clear handles.firstFrame

clear handles.colour = zeros(1,3);
clear handles.bright = zeros(1,3);
clear handles.tophat = zeros(1,3);
clear handles.nTiles = zeros(1,6);
clear handles.conlim = zeros(1,3);
clear handles.gaussb = zeros(1,3);
clear handles.thresh = zeros(1,3);
clear handles.sizerA = zeros(1,3);
clear handles.sizerB = zeros(1,3);
clear handles.dilate = zeros(1,3);
clear handles.minima = zeros(1,3);

clear handles.imageListPhs
clear handles.imageListGrn
clear handles.imageListRed
clear handles.newPhs
clear handles.newGrn
clear handles.newRed
clear handles.overlay
clear handles.trackedImagesPhs
clear handles.trackedImagesGrn
clear handles.trackedImagesRed

clear handles.normalGFP
clear handles.normalRFP
clear handles.normalDIV
clear handles.GFPMatrix
clear handles.RFPMatrix
clear handles.DIVMatrix

clear handles.dataTable
colNames = cell(1,10);
colNames{1} = sprintf('Label');
for k = 2:11
    colNames{k} = ['Frame ',num2str(k-1)];
end
set(handles.dataTable,'ColumnName',colNames)
set(handles.dataTable,'RowName',1:150)

clear handles.updateID
clear handles.trackWorkspace
clear handles.workspaceMemory

handles.updateID = 1;
handles.trackWorkspace = struct('labelIndex',    {},...
                                'kalmanFilter',  {},...
                                'boundingBox',   {},...
                                'longevity',     {},...
                                'visibleCount',  {},...
                                'invisibleCount',{},...
                                'pixelIndex',    {},...
                                'intensityGFP',  {},...
                                'intensityRFP',  {},...
                                'intensityDIV',  {},...
                                'centroidList',  {});

tempStatus = cellstr(get(handles.statusList,'String'));
initStatus = [tempStatus ; handles.messages{13}];
set(handles.statusList,'String',initStatus)
refresh

%%%%% "First Frame" Edit Text %%%%%
function fromEdit_Callback(hObject,~,handles)

%%%%% Extract Frame Interval Specification %%%%%
handles.firstFrame = str2double(get(handles.fromEdit,'String'));
handles.nImages = str2double(get(handles.toEdit,'String'));
set(handles.frameStatic,'String',sprintf(['Frame ',num2str(handles.firstFrame),'/',num2str(handles.nImages)]))

guidata(hObject,handles)

%%%%% "Last Frame" Edit Text %%%%%
function toEdit_Callback(hObject,~,handles)

%%%%% Extract Frame Interval Specification %%%%%
handles.firstFrame = str2double(get(handles.fromEdit,'String'));
handles.nImages = str2double(get(handles.toEdit,'String'));
set(handles.frameStatic,'String',sprintf(['Frame ',num2str(handles.firstFrame),'/',num2str(handles.nImages)]))

guidata(hObject,handles)

%%%%% "GFP" Radio Button %%%%%
function gfpRadio_Callback(hObject,~,handles)

% zoom(handles.imageDisplay,'off')
handles.firstFrame = str2double(get(handles.fromEdit,'String'));

gfpTab = get(hObject,'Value');
rfpTab = get(handles.rfpRadio,'Value');
divTab = get(handles.divRadio,'Value');

if (gfpTab == 1) && (rfpTab == 0) && (divTab == 0)
    set(handles.dataTable,'Data',[])
    set(handles.dataTable,'Data',handles.GFPMatrix)
    set(handles.dataTable,'RowName',1:size(handles.GFPMatrix,1))
    cla(handles.plotDisplay)
    
    %%%%% Plot GFP Graph %%%%%
    framers = handles.firstFrame:handles.nImages;
    for k = 1:length(handles.IDList)
        plot(handles.plotDisplay,framers,handles.normalGFP(k,:),'-')
        set(handles.plotDisplay,'XLim',[handles.firstFrame handles.nImages])
        set(handles.plotDisplay,'XTickLabel',{})
        set(handles.plotDisplay,'YTickLabel',{})
        hold(handles.plotDisplay,'on')
        drawnow
    end
    
end

guidata(hObject,handles)

%%%%% "RFP" Radio Button %%%%%
function rfpRadio_Callback(hObject,~,handles)

% zoom(handles.imageDisplay,'off')
handles.firstFrame = str2double(get(handles.fromEdit,'String'));

gfpTab = get(handles.gfpRadio,'Value');
rfpTab = get(hObject,'Value');
divTab = get(handles.divRadio,'Value');

if (gfpTab == 0) && (rfpTab == 1) && (divTab == 0)
    set(handles.dataTable,'Data',[])
    set(handles.dataTable,'Data',handles.RFPMatrix)
    set(handles.dataTable,'RowName',1:size(handles.RFPMatrix,1))
    cla(handles.plotDisplay)
    
    %%%%% Plot RFP Graph %%%%%
    framers = handles.firstFrame:handles.nImages;
    for k = 1:length(handles.IDList)
        plot(handles.plotDisplay,framers,handles.normalRFP(k,:),'-')
        set(handles.plotDisplay,'XLim',[handles.firstFrame handles.nImages])
        set(handles.plotDisplay,'XTickLabel',{})
        set(handles.plotDisplay,'YTickLabel',{})
        hold(handles.plotDisplay,'on')
        drawnow
    end
    
end

guidata(hObject,handles)

%%%%% "DIV" Radio Button %%%%%
function divRadio_Callback(hObject,~,handles)

% zoom(handles.imageDisplay,'off')
handles.firstFrame = str2double(get(handles.fromEdit,'String'));

gfpTab = get(handles.gfpRadio,'Value');
rfpTab = get(handles.rfpRadio,'Value');
divTab = get(hObject,'Value');

if (gfpTab == 0) && (rfpTab == 0) && (divTab == 1)
    set(handles.dataTable,'Data',[])
    set(handles.dataTable,'Data',handles.DIVMatrix)
    set(handles.dataTable,'RowName',1:size(handles.DIVMatrix,1))
    cla(handles.plotDisplay)
    
    %%%%% Plot GFP Graph %%%%%
    framers = handles.firstFrame:handles.nImages;
    for k = 1:length(handles.IDList)
        plot(handles.plotDisplay,framers,handles.normalDIV(k,:),'-')
        set(handles.plotDisplay,'XLim',[handles.firstFrame handles.nImages])
        set(handles.plotDisplay,'XTickLabel',{})
        set(handles.plotDisplay,'YTickLabel',{})
        hold(handles.plotDisplay,'on')
        drawnow
    end
    
end


guidata(hObject,handles)

%%%%% "Clear Plot" Push Button %%%%%
function clearPlotPush_Callback(hObject,~,handles)

% zoom(handles.imageDisplay,'off')

cla(handles.plotDisplay)
set(handles.plotDisplay,'XLim',[handles.firstFrame handles.nImages])
set(handles.plotDisplay,'XTickLabel',{})
set(handles.plotDisplay,'YTickLabel',{})
set(handles.plotDisplay,'XTick',[])
set(handles.plotDisplay,'YTick',[])
set(handles.plotDisplay,'XLabel',[])
set(handles.plotDisplay,'YLabel',[])
box(handles.plotDisplay,'on')

tempStatus = cellstr(get(handles.statusList,'String'));
initStatus = [tempStatus ; handles.messages{27}];
set(handles.statusList,'String',initStatus)

guidata(hObject,handles)

%%%%% "Bounding Box Colour" Popup Menu %%%%%
function boxcolPop_Callback(hObject,~, handles)

boxColours = {'m','y','g','w','c','k','b','r'};
boxColour = get(hObject,'Value');
handles.boxColour = boxColours{boxColour};

guidata(hObject,handles)

%%%%% "Index Colour" Popup Menu %%%%%
function indcolPop_Callback(hObject,~, handles)

indColours = {'m','y','g','w','c','k','b','r'};
indColour = get(hObject,'Value');
handles.indColour = indColours{indColour};

guidata(hObject,handles)

%%%%% "Line Color" Popup Menu %%%%%
function linColPop_Callback(hObject,~,handles)

%%%%% "Export Data to Excel" Push Button %%%%%
function excelPush_Callback(hObject,~,handles)

%%%%% Open Files Directory %%%%%
[outputFile,outputFolder] = uiputfile({'*.xlsx' 'Excel (*.xlsx)'},'Save as');

%%%%% Cancel Save File %%%%%
if isequal(outputFile,0)
    return
end

%%%%% "Exporting To Excel" Message %%%%%
tempStatus = cellstr(get(handles.statusList,'String'));
initStatus = [tempStatus ; handles.messages{19}];
set(handles.statusList,'String',initStatus)
lastMsg = numel(get(handles.statusList,'String'));
set(handles.statusList,'Value',lastMsg)
drawnow

%%%%% Specify Save Location %%%%%
outputFull = fullfile(outputFolder,outputFile);
xlswrite(outputFull,get(handles.dataTable,'Data'));

%%%%% "Export Complete" Message %%%%%
tempStatus = cellstr(get(handles.statusList,'String'));
initStatus = [tempStatus ; handles.messages{20}];
set(handles.statusList,'String',initStatus)
lastMsg = numel(get(handles.statusList,'String'));
set(handles.statusList,'Value',lastMsg)
drawnow

guidata(hObject,handles)

%%%%% Save Image Toolbar Button %%%%%
function saveImageTool_ClickedCallback(hObject,~,handles)

%%%%% Open Files Directory %%%%%
[outputFile,outputFolder] = uiputfile({'*.jpg';'*.png';'*.tif'},'Save as');

%%%%% Cancel Save File %%%%%
if isequal(outputFile,0)
    return
end

%%%%% "Saving Current Axes Handle" Message %%%%%
tempStatus = cellstr(get(handles.statusList,'String'));
initStatus = [tempStatus ; handles.messages{23}];
set(handles.statusList,'String',initStatus)
lastMsg = numel(get(handles.statusList,'String'));
set(handles.statusList,'Value',lastMsg)
drawnow

%%%%% Specify Save Location %%%%%
outputFull = fullfile(outputFolder,outputFile);
extractedImage = getimage(handles.imageDisplay);
imwrite(extractedImage,outputFull);

%%%%% "Image Save Complete" Message %%%%%
tempStatus = cellstr(get(handles.statusList,'String'));
initStatus = [tempStatus ; handles.messages{24}];
set(handles.statusList,'String',initStatus)
lastMsg = numel(get(handles.statusList,'String'));
set(handles.statusList,'Value',lastMsg)
drawnow

guidata(hObject,handles)

%%%%% "Clear Table" Push Button %%%%%
function clearTablePush_Callback(hObject,~,handles)

% zoom(handles.imageDisplay,'off')

colNames = cell(1,10);
colNames{1} = sprintf('Label');
for k = 2:11
    colNames{k} = ['Frame ',num2str(k-1)];
end
set(handles.dataTable,'Data',[])
set(handles.dataTable,'ColumnName',colNames)
set(handles.dataTable,'RowName',1:50)

tempStatus = cellstr(get(handles.statusList,'String'));
initStatus = [tempStatus ; handles.messages{26}];
set(handles.statusList,'String',initStatus)

guidata(hObject,handles)

%%%%% "Stop" Push Button %%%%%
function stopPush_Callback(hObject,~,handles)
zoom off
set(handles.stopPush,'Userdata',1)
guidata(hObject,handles)

%%%%% "<<" Push Button %%%%%
function decreasePush_Callback(hObject,~,handles)
handles.speed = handles.speed + 0.02;
set(handles.speedStatic,'String',handles.speed)
guidata(hObject,handles)

%%%%% ">>" Push Button %%%%%
function increasePush_Callback(hObject,~,handles)
handles.speed = handles.speed - 0.02;
set(handles.speedStatic,'String',handles.speed)
guidata(hObject,handles)

%%%%% "Clear Status Window" Push Button %%%%%
function clearStatusPush_Callback(hObject,~,handles)
set(handles.statusList,'String','>> Status Window Cleared')
guidata(hObject,handles)

%%%%% "Clear File" Push Button %%%%%
function pushbutton24_Callback(hObject,~,handles)

%%%%% Filename Popup List Reset %%%%%
set(handles.filenamePop,'String','Filenames')
set(handles.frameStatic,'String',[])

%%%%% Image and Plot Axes Reset %%%%%
cla(handles.imageDisplay,'reset')
set(handles.imageDisplay,'XTick',[])
set(handles.imageDisplay,'YTick',[])
box(handles.imageDisplay,'on')

clear handles.imageListPhs
clear handles.imageListGrn
clear handles.imageListRed

tempStatus = cellstr(get(handles.statusList,'String'));
initStatus = [tempStatus ; handles.messages{25}];
set(handles.statusList,'String',initStatus)
refresh

%%%%% Restart Application Toolbar Button %%%%%
function restartTool_ClickedCallback(hObject,~,handles)
clear handles
close(gcbf)
userInterface

%%%%% Command Window Outputs %%%%%
function varargout = userInterface_OutputFcn(~,~,handles)
varargout{1} = handles.output;

%%%%% Status Window Listbox %%%%%
function statusList_Callback(hObject,~,handles)

%%%%% Brightness Edit Text %%%%%
function brightEdit_Callback(hObject,~,handles)

%%%%% "Threshold" Edit Text %%%%%
function threshEdit_Callback(hObject,~,handles)

%%%%% "Minimum Size" Edit Text %%%%%
function sizeAEdit_Callback(hObject,~,handles)

%%%%% "Maximum Size" Edit Text %%%%%
function sizeBEdit_Callback(hObject,~,handles)

%%%%% "Assignment Cost" Edit Text %%%%%
function costEdit_Callback(hObject,~,handles)

%%%%% "Top-Hat Filter" Edit Text %%%%%
function tophatEdit_Callback(hObject,~,handles)

%%%%% "H-Minima" Edit Text %%%%%
function hminEdit_Callback(hObject,~,handles)

%%%%% "Dilation" Edit Text %%%%%
function dilateEdit_Callback(hObject,~,handles)

%%%%% "Gaussian Blur" Edit Text %%%%%
function gaussEdit_Callback(hObject,~,handles)

%%%%% "Contrast Limit" Edit Text %%%%%
function conlimEdit_Callback(hObject,~,handles)

%%%%% "Tiles" Edit Text %%%%%
function tilesEdit_Callback(hObject,~,handles)

%%%%% "Isolate Cell" Edit Text %%%%%
function isolateEdit_Callback(hObject,~,handles)

%%%%% "Colour Channel" Edit Text %%%%%
function colourEdit_Callback(hObject,~,handles)

%%%%% "Visibility (%)" Edit Text %%%%%
function visEdit_Callback(hObject,~,handles)

%%%%% "Age Penalty" Edit Text %%%%%
function ageEdit_Callback(hObject,~,handles)

%%%%% "Invisible Count" Edit Text %%%%%
function invisEdit_Callback(hObject,~,handles)

%%%%% "Marker" Check Box %%%%%
function marker_Callback(hObject,~,handles)



%%%%% Loaded Files Listbox Properties %%%%%
function filenameList_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% First Frame Edit Text Properties %%%%%
function fromEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Last Frame Edit Text Properties %%%%%
function toEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Frame Slider Properties %%%%%
function frameSlider_CreateFcn(hObject,~,~)
if isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%%%%% Status Window Properties %%%%%
function statusList_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Brightness Properties %%%%%
function brightEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Threshold Properties %%%%%
function threshEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Minimum Size Properties %%%%%
function sizeAEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function sizeBEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Box Colour Properties %%%%%
function boxcolPop_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Index Colour Properties %%%%%
function indcolPop_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Maximum Cost Properties %%%%%
function costEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Filename Popup Properties %%%%%
function filenamePop_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Top-Hat Filter Properties %%%%%
function tophatEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% H-Minima Properties %%%%%
function hminEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Tiles Properties %%%%%
function tilesEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Contrast Limit Properties %%%%%
function conlimEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Gaussian Blur Properties %%%%%
function gaussEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Dilation Properties %%%%%
function dilateEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Isolate Cell Properties %%%%%
function isolateEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Colour Channel Properties %%%%%
function colourEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Visibility Properties %%%%%
function visEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Age Penalty Properties %%%%%
function ageEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Invisibility Properties %%%%%
function invisEdit_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%% Line Color Properties %%%%%
function linColPop_CreateFcn(hObject,~,~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end