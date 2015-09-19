%   SMEARVOLUTION 
%
%   A manipulatable convolution reverb that allows for spectral editing.
%   GUI created with GUIDE.
%
%   Dependencies: fastConvolver.m, spectrumAnalyzer.m
%  
%   Author: Adrian Tregonning, 2014


function varargout = smearvolution(varargin)
% SMEARVOLUTION MATLAB code for smearvolution.fig
%
%      GUI wrapper for smearvolution.m, a smearvolution effect. 
%      
%      smearvolution.fig must be in the same directory as this file.
%
%      SMEARVOLUTION, by itself, creates a new SMEARVOLUTION or raises the
%      existing singleton*.
%
%      H = SMEARVOLUTION returns the handle to a new SMEARVOLUTION or the 
%      handle to the existing singleton*.
%
%      SMEARVOLUTION('CALLBACK',hObject,eventData,handles,...) calls the 
%      local function named CALLBACK in SMEARVOLUTION.M with the given 
%      input arguments.
%
%      SMEARVOLUTION('Property','Value',...) creates a new SMEARVOLUTION or 
%      raises the existing singleton*.  Starting from the left, property 
%      value pairs are applied to the GUI before smearvolution_OpeningFcn
%      gets called.  An unrecognized property name or invalid value makes
%      property application stop. All inputs are passed to 
%      smearvolution_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help smearvolution

% Last Modified by GUIDE v2.5 21-May-2014 21:00:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @smearvolution_OpeningFcn, ...
                   'gui_OutputFcn',  @smearvolution_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before smearvolution is made visible.
function smearvolution_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to smearvolution (see VARARGIN)

% Choose default command line output for smearvolution
handles.output = hObject;

%  Add initial/default values struct to GUI data
initVals = struct(...
                'pathWarningImpulse', 'Please enter path for valid wav file', ...
                'wetAmount', 1, ...
                'wetMin', 0, ...
                'wetMax', 2, ...  % This changes upon wavread to Nyquist freq (fs/2)
                'dryAmount', 0, ...
                'dryMin', 0, ...
                'dryMax', 2, ...
                'winLength', 1024, ...     % Default FFT parameters
                'overlap', 512, ...
                'window', 'hann', ...
                'fftLength', 1024, ...
                'cutoffFreq', 20000 ...     % Frequency limit for plotting
            );

handles.initVals = initVals;
handles.sigLoaded = false;
handles.irLoaded = false;
handles.brushSize = 1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes smearvolution wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Initialize values and ranges for sliders and text boxes, add callbacks
% for updating text while sliding
h = handles.sliderWet;
set(h, 'Value', initVals.wetAmount)
set(h, 'Min', initVals.wetMin)
set(h, 'Max', initVals.wetMax)
addlistener(h,'Value','PreSet',@(src,ev) updateText(src, ev, ...
    get(h, 'Value'), handles.editWet));

h = handles.editWet;
set(h, 'Value', initVals.wetAmount)
set(h, 'String', num2str(initVals.wetAmount, '%0.2f'))

h = handles.sliderDry;
set(h, 'Value', initVals.dryAmount)
set(h, 'Min', initVals.dryMin)
set(h, 'Max', initVals.dryMax)
addlistener(h,'Value','PreSet',@(src,ev) updateText(src, ev, ...
    get(h, 'Value'), handles.editDry));

h = handles.editDry;
set(h, 'Value', initVals.dryAmount)
set(h, 'String', num2str(initVals.dryAmount, '%0.2f'))

set(handles.titleText, 'Visible', 'off')

% Initialize the wet/dry parameters as disabled until a file is loaded
% successfully
toggleButtons(handles, 'off')

set(hObject,'toolbar','figure');
% set(hObject,'menubar','figure');


% --- Outputs from this function are returned to the command line.
function varargout = smearvolution_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                     %
% ------- SLIDERS/POPUP MENU -------  %
%                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on slider movement.
function sliderWet_Callback(hObject, eventdata, handles)
% hObject    handle to sliderWet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%        slider
val = get(hObject,'Value');
h = handles.editWet;
set(h, 'Value', val);
set(h, 'String', num2str(val, '%0.2f'));


% --- Executes during object creation, after setting all properties.
function sliderWet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderWet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), ...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderDry_Callback(hObject, eventdata, handles)
% hObject    handle to sliderDry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine
%        range of slider
val = get(hObject,'Value');
h = handles.editDry;
set(h, 'Value', val);
set(h, 'String', num2str(val, '%0.2f'));


% --- Executes during object creation, after setting all properties.
function sliderDry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderDry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupBrushSize.
function popupBrushSize_Callback(hObject, eventdata, handles)
% hObject    handle to popupBrushSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupBrushSize
% contents as cell array contents{get(hObject,'Value')} returns selected
% item from popupBrushSize
items = get(hObject,'String');
index_selected = get(hObject,'Value');
handles.brushSize = str2double(items{index_selected});

guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function popupBrushSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupBrushSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                %  
% ------- EDIT TEXT BOXES ------ %
%                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function editWet_Callback(hObject, eventdata, handles)
% hObject    handle to editWet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWet as text
%        str2double(get(hObject,'String')) returns contents of editWet
%        as a double
val = str2double(get(hObject, 'String'));
set(hObject, 'Value', val);
set(handles.sliderWet, 'Value', val);


% --- Executes during object creation, after setting all properties.
function editWet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%set(hObject, 'Value', handles.centerFreq)
%set(hObject, 'String', num2str(handles.centerFreq, '%0.2f'))


function editDry_Callback(hObject, eventdata, handles)
% hObject    handle to editDry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDry as text
%        str2double(get(hObject,'String')) returns contents of editDry 
%        as a double
val = str2double(get(hObject, 'String'));
set(hObject, 'Value', val);
set(handles.sliderDry, 'Value', val);


% --- Executes during object creation, after setting all properties.
function editDry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                %  
% ---------- BUTTONS ----------- %
%                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in buttonLoadSig.
function buttonLoadSig_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoadSig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open load file dialog
[filename, pathname] = uigetfile({'*.wav'}, 'Select File');
fullPathName = strcat (pathname, filename);

% Read file and add to handles
if ~isempty(fullPathName)  
    try
        [sig, sigFS] = audioread(fullPathName);
    catch
        warndlg('Given file cannot be read')
    end
    
    handles.sig = sig;
    handles.sigFS = sigFS;
    handles.sigLoaded = true;

    set(handles.titleText, 'String', ['signal = ', filename])
    set(handles.titleText, 'Visible', 'on')
    
    guidata(hObject, handles);
    
    % Enable the wet/dry parameters    
    if(handles.irLoaded)
        toggleButtons(handles, 'on')
    end
end


% --- Executes during object creation, after setting all properties.
function buttonLoadSig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to buttonLoadIr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function buttonLoadIr_Callback(hObject, eventdata, handles)
% hObject    handle to buttonLoadIr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of buttonLoadIr as text
%        str2double(get(hObject,'String')) returns contents of
%        buttonLoadIr as a double

% Open load file dialog
[filename, pathname] = uigetfile({'*.wav'}, 'Select File');
fullPathName = strcat (pathname, filename);

% Read file and add to handles
if ~isempty(fullPathName)  
    try
        [initIR, irFS] = audioread(fullPathName);
    catch
        warndlg('Given file cannot be read')
    end

    handles.irFS = irFS;
    handles.initIR = initIR;
   
    guidata(hObject, handles)
    
    % Run spectrum analyzer on impulse and plot results in GUI
    [initMAGS, PHASES] = drawSpect(initIR, hObject);
    
    % Add spectrogram data to figure handle
    handles = guidata(gcf);
    
    handles.initMAGS = initMAGS;
    handles.PHASES = PHASES;
    % size of a bin, used for plotting
    handles.rectSize = ...
        (handles.initVals.winLength - handles.initVals.overlap) / irFS;
    
    guidata(hObject, handles)
    
end


% --- Executes during object creation, after setting all properties.
function buttonLoadIr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to buttonLoadIr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),...
        get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonRun.
function buttonRun_Callback(hObject, eventdata, handles)
% hObject    handle to buttonRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check sampling rates are the same
if handles.sigFS ~= handles.irFS
    error(['Sampling rates are not the same (sig = ', ...
      num2str(handles.sigFS), ' Hz, ir = ', num2str(handles.irFS), ' Hz)'])
end

wet = get(handles.editWet, 'Value');
dry = get(handles.editDry, 'Value');

initVals = handles.initVals;

% Debug - check difference with original spectrogram
% diffs = handles.currMAGS == handles.initMAGS;
% find(diffs ~= 1)

% Calculate new impulse response from graph
currIR = calcIR(handles.currMAGS, handles.PHASES, initVals.winLength, ...
                        initVals.overlap, initVals.window);

% Save new IR
handles.currIR = currIR;
guidata(hObject, handles);

% Run convolution function
y = fastConvolver(handles.sig, currIR, wet, dry);

% Play result in an audioplayer with a stop callback function
player = audioplayer(y, handles.sigFS);
player.StopFcn = {@stopFunction, y, 'y', handles};

% Disable buttons and sliders while sound is playing
toggleButtons(handles, 'off')

%play sound
playblocking(player)


% --- Executes on button press in buttonReset.
function buttonReset_Callback(hObject, eventdata, handles)
% hObject    handle to buttonReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reset all sliders and boxes to defaults
initVals = handles.initVals;

h = handles.sliderWet;
set(h, 'Value', initVals.wetAmount)
set(h, 'Min', initVals.wetMin)
set(h, 'Max', initVals.wetMax)

h = handles.editWet;
set(h, 'Value', initVals.wetAmount)
set(h, 'String', num2str(initVals.wetAmount, '%0.2f'))

h = handles.sliderDry;
set(h, 'Value', initVals.dryAmount)
set(h, 'Min', initVals.dryMin)
set(h, 'Max', initVals.dryMax)

h = handles.editDry;
set(h, 'Value', initVals.dryAmount)
set(h, 'String', num2str(initVals.dryAmount, '%0.2f'))

% Reset to the original impulse response
drawSpect(handles.initIR, hObject);


% MOUSECLICK CALLBACK - handle clicks on the chart
function mouseclick_callback(obj, event)
% Update figure handles to ensure changes from other callbacks are
% propogated
handles = guidata(gcf);

hold on

% Plot the new point in the chosen color, and store the change in the
% currIR variable.
if isfield(handles, 'currColor')
    % Add dragging functionality from window's motion and button up
    % functions
    fig = ancestor(obj, 'figure');
    props.WindowButtonMotionFcn = get(fig, 'WindowButtonMotionFcn');
    props.WindowButtonUpFcn = get(fig, 'WindowButtonUpFcn');

    setappdata(fig, 'TestGuiCallbacks', props);

    set(fig, 'WindowButtonMotionFcn', @mousedrag_callback)
    set(fig, 'WindowButtonUpFcn', @mouseup_callback)

    % Get the point that was clicked on
    cP = get(gca, 'Currentpoint');
    x = cP(1, 1);
    y = cP(1, 2);

%     cursor_handle = plot(0, 0, 'Color', handles.currColor, 'Marker', '+', 'MarkerSize', 10,'visible', 'off');
%     set(cursor_handle, 'Xdata', x, 'Ydata', y, 'visible', 'on')
    
    % Update value of current point and shade the plot bin in the new
    % color
    xLims = get(handles.fig, 'xLim');
    yLims = get(handles.fig, 'yLim');
    magsSize = size(handles.currMAGS);
    
    window = round(((x - xLims(1)) / (xLims(2) - xLims(1))) * magsSize(2));
    freqBin = round(((y - yLims(1)) / (yLims(2) - yLims(1)))* handles.plotBins);
    
    xSnap = (xLims(2) - xLims(1)) * window/magsSize(2) + xLims(1);
    ySnap = (yLims(2) - yLims(1)) * freqBin/handles.plotBins + yLims(1);
    
    % Set the size of the added rectangle
    rectW = handles.rectSize * handles.brushSize;
    rectH = round(handles.brushSize);
    
    rectangle('Position', [xSnap, ySnap, rectW, rectH], 'FaceColor', ...
        handles.currColor, 'EdgeColor', handles.currColor)
      
    handles = guidata(gcf);
    
    if (freqBin + handles.brushSize - 1) > magsSize(1)
        bins = freqBin:magsSize(2);
    else
        bins = freqBin:(freqBin + handles.brushSize - 1);
    end
        
    if (window + handles.brushSize - 1) > magsSize(2)
        wins = window:magsSize(2);
    else
        wins = window:(window + handles.brushSize - 1);
    end
    
    % Replace magnitudes in the current spectrogram with new magnitude
    handles.currMAGS(bins, wins) = handles.newDB;
    
    guidata(gca, handles);
end


% Mouse dragging callback
function mousedrag_callback(hObject, event)

handles = guidata(gcf);

% disp('motion')

cP = get(gca, 'Currentpoint');
x = cP(1, 1);
y = cP(1, 2);

if isfield(handles, 'currColor')  
%     cursor_handle = plot(0, 0, 'Color', handles.currColor, 'Marker', '+', 'MarkerSize', 10,'visible', 'off');
%     set(cursor_handle, 'Xdata', x, 'Ydata', y, 'visible', 'on')
    
    % Update value of current point and shade the plot bin in the new
    % color
    xLims = get(handles.fig, 'xLim');
    yLims = get(handles.fig, 'yLim');
    magsSize = size(handles.currMAGS);
    
    window = round(((x - xLims(1)) / (xLims(2) - xLims(1))) * magsSize(2));
    freqBin = round(((y - yLims(1)) / (yLims(2) - yLims(1))) * handles.plotBins);
    
    xSnap = (xLims(2) - xLims(1)) * window/magsSize(2) + xLims(1);
    ySnap = (yLims(2) - yLims(1)) * freqBin/handles.plotBins + yLims(1);
    
    window = round(((x - xLims(1)) / (xLims(2) - xLims(1))) * magsSize(2));
    freqBin = round(((y - yLims(1)) / (yLims(2) - yLims(1))) * handles.plotBins);
    
    % Set the size of the added rectangle
    rectW = handles.rectSize * handles.brushSize;
    rectH = round(handles.brushSize);
    
    rectangle('Position', [xSnap, ySnap, rectW, rectH], 'FaceColor', ...
        handles.currColor, 'EdgeColor', handles.currColor)
      
    handles = guidata(gcf);
    
    if (freqBin + handles.brushSize - 1) > magsSize(1)
        bins = freqBin:magsSize(2);
    else
        bins = freqBin:(freqBin + handles.brushSize - 1);
    end
        
    if (window + handles.brushSize - 1) > magsSize(2)
        wins = window:magsSize(2);
    else
        wins = window:(window + handles.brushSize - 1);
    end
    
    % Replace magnitude in the current spectrogram with new magnitude
    handles.currMAGS(bins, wins) = handles.newDB;
    
    guidata(gcf, handles);
end


% Button up callback
function mouseup_callback(obj, event)

% disp('up')

fig = ancestor(obj, 'figure');

props = getappdata(fig, 'TestGuiCallbacks');
set(fig, props);
setappdata(fig, 'TestGuiCallbacks', []);


% COLORBAR CALLBACK - choose color for editing the spectrogram
function colorBar_callback(obj, event)

handles = guidata(gcf);

% Get point on color bar that was clicked on
cP = get(gca,'Currentpoint');
y = cP(1,2);

% Get the color that was clicked on by scaling the clicked position to the
% color map
yLims = get(handles.cBar, 'yLim');
cMap = get(gcf, 'ColorMap');
cMap = cMap(end:-1:1,:);
[mapSize, ~] = size(cMap);
freqLim = handles.initVals.cutoffFreq;
% newColor = round((y - yLims(1)) / (yLims(2) - yLims(1)) * mapSize);
yScale = (freqLim - y) / freqLim;
yDB = -yScale * (yLims(2) - yLims(1));
newColor = round(yScale * mapSize);

% Store the modified dB value and it's color to figure handles
% this will be the color drawn on the chart when it is clicked
handles.newDB = yDB;
handles.currColor = cMap(newColor, :);
guidata(gca, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                               %  
% ------- HELPER FUNCTIONS ETC. ------ %
%                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Callback for continous updating of a slider's associated text box while
% it is being dragged
function updateText(obj, event, val, h)
set(h, 'Value', val)
set(h, 'String', num2str(val, '%0.2f'))


% Callback function for audioplayer stop event. It assigns the signal to 
% variable var in the base workspace, and updates the play button
function stopFunction(obj, event, sig, name, handles)
assignin('base', name, sig)
toggleButtons(handles, 'on')


% Helper function to turn on/off all sliders, buttons, etc.
function toggleButtons(handles, state)
set(handles.buttonRun,'Enable', state)
set(handles.buttonReset,'Enable', state)
set(handles.sliderWet,'Enable', state)
set(handles.editWet,'Enable', state)
set(handles.sliderDry,'Enable', state)
set(handles.editDry,'Enable', state)


% Draw spectrum and add callback functions
function [MAGS, PHASES] = drawSpect(ir, h)

handles = guidata(gcf);

initVals = handles.initVals;
[MAGS, PHASES, handles.plotBins,...
    handles.spect, handles.cBar] = spect(ir, handles.irFS, ...
                initVals.winLength, initVals.overlap, initVals.window, ...
                initVals.cutoffFreq, initVals.fftLength);

handles.currMAGS = MAGS;
handles.irLoaded = true;

guidata(h, handles);

% Enable the wet/dry parameters
if(handles.sigLoaded)
    toggleButtons(handles, 'on')
end

% Add mousclick listeners to plot axes and lines (i.e. its children)
% and the color bar
set(gca,'ButtonDownFcn', @mouseclick_callback)
set(get(gca,'Children'),'ButtonDownFcn', @mouseclick_callback)
set(handles.cBar,'ButtonDownFcn', @colorBar_callback)


% Generates transfer function of loaded IR
function [MAGS, PHASES, bins, h, cBar] = spect(ir, fs, windowLen, ...
    overlap, winType, plotCutoff, fftLen)
colorScale = [-110, 0];

[MAGS, PHASES] = spectrumAnalyzer(ir, windowLen, overlap, winType, fftLen);

s = size(MAGS);
xLim = s(2);
winSize = (windowLen - overlap)/fs;
bins = ceil(plotCutoff * s(1) / fs);

hold off

h = imagesc(0:winSize:xLim*winSize, 0:bins*fs/s(1), MAGS(1:bins,:),...
    colorScale);

set(gca, 'YDir', 'normal')
set(gca,'Ytick',0:2000:plotCutoff)
set(gca,'YtickLabel', 0:2:20)
xlabel('Time (s)', 'FontSize', 12)
ylabel('Frequency (kHz)', 'FontSize', 12)
cBar = colorbar('peer', gca);


% Calculate an impulse response from spectrogram magnitude and phases
function ir = calcIR(MAGS_dB, PHASES, winLength, overlap, window)

% Generate the appropriate windowing function
    switch window
        case 'rect'
            windowFunc = ones(winLength,1);
        case 'hamming'
            windowFunc = hamming(winLength);
        case 'hann'
            windowFunc = hann(winLength);
        case 'blackman'
            windowFunc = blackman(winLength);
        case 'bartlett'
            windowFunc = bartlett(winLength);
        otherwise
            error(['Error: invalid window type - ',...
                 'choose from rect, hamming, hann, blackman, bartlett'])
    end
    
    % Transform back to time-domain after returning to magnitudes from 
    % dB and un-normalizing
    MAGS = db2mag(MAGS_dB);
    WINS = MAGS * (sum(windowFunc) / 2) .* exp(1i * PHASES);
    wins = real(ifft(WINS));
    
    [~, numWins] = size(wins);
    
    % Unbuffer the signal
    hopSize = winLength - overlap;
    
    ir = zeros((numWins * hopSize) + winLength, 1);
    idx = 1:winLength;
    
    for n = 1:numWins
        ir(idx) = ir(idx) + wins(:, n);
        idx = idx + hopSize;
    end
