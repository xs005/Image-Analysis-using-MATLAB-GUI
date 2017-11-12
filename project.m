function varargout = project(varargin)
% PROJECT MATLAB code for project.fig
%      PROJECT, by itself, creates a new PROJECT or raises the existing
%      singleton*.
%
%      H = PROJECT returns the handle to a new PROJECT or the handle to
%      the existing singleton*.
%
%      PROJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECT.M with the given input arguments.
%
%      PROJECT('Property','Value',...) creates a new PROJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before project_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to project_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help project

% Last Modified by GUIDE v2.5 04-Dec-2014 19:07:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @project_OpeningFcn, ...
                   'gui_OutputFcn',  @project_OutputFcn, ...
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


% --- Executes just before project is made visible.
function project_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to project (see VARARGIN)

% Choose default command line output for project
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes project wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = project_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- About Information.
function about_Callback(hObject, eventdata, handles)
% hObject    handle to about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(msgbox('Designed for Microscopy Project.','About','modal'));


% --- Load Images.
function load_image_Callback(hObject, eventdata, handles)
% hObject    handle to load_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global K dist_array label_num J I pathname filename; %set global variables
[filename, pathname] = ...
     uigetfile({'*.jpg;*.png;*.bmp;*.tif;*.gif'},'Choose an image file'); %set input file type
I=imread(strcat(pathname,filename)); %read the file. 
J=I; %J is image for counting
K=I; %K is image to display in grayscale
axes(handles.axes1); %choose axes1 as the display region.
imshow(I) %show the figure in the GUI



% --- Reset the image.
function reset_image_Callback(hObject, eventdata, handles)
% hObject    handle to reset_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global K dist_array label_num J I pathname filename; 
axes(handles.axes1);
I=imread(strcat(pathname,filename)); %read the original file. 
J=I;
K=I;
imshow(I) %show the figure in the GUI
%clear the content in text boxes.
nothing = [ ' ' ];
set(handles.area_min,'String', nothing);
set(handles.area_max,'String', nothing);
set(handles.output_num,'String', nothing);




% --- Executes on button press in choose_region.
function choose_region_Callback(hObject, eventdata, handles)
% hObject    handle to choose_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global K dist_array label_num J I; %set global variables
axes(handles.axes1);
J = imcrop(J); %choose a region in the original figure for further analysis
K = J;
rgb = J; %load image
rgb2 = rgb2gray(rgb); %change it to gray
rgb2 = imcomplement(rgb2); %invert the color
rgb2 = adapthisteq(rgb2, 'ClipLimit', 0.1); %enhance contract
BWdfill = imfill(im2bw(rgb2,0.6), 'holes'); 
%fills holes in the binary image BW. A hole is a set of background pixels 
%that cannot be reached by filling in the background from the edge of the image.
J = BWdfill;
imshow(K) %show the cropped figure in the GUI



% --- Executes on button press in f_intensitiy.
function f_intensitiy_Callback(hObject, eventdata, handles)
% hObject    handle to f_intensitiy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global K dist_array label_num J I;
axes(handles.axes1);
f_intensity = mean(single(reshape(rgb2gray(K),1,[]))/255); %average the intensity of all pixels in cropped region.
f_std = std(single(reshape(rgb2gray(K),1,[]))/255); %calculate the standard deviation
f_intensity_std=['Intensity=' num2str(f_intensity) ' (' 'STD=' num2str(f_std) ')' ]; %show the result in output region.
set(handles.output_num,'String',f_intensity_std);

% --- Executes on button press in counting.
function counting_Callback(hObject, eventdata, handles)
% hObject    handle to counting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global K dist_array label_num J I;
axes(handles.axes1);
BWnobord = imclearborder(J, 8); %remove the boundary cells in the cropped figure
rgb_perim = bwperim(im2bw(BWnobord)); %find the boundary of vaculoes
overlay1 = imoverlay(rgb2gray(K),rgb_perim, [.3 1 .3]); %overlap vacuole figures with boundary
imshow(overlay1)
cc = bwconncomp(BWnobord, 8); %find the connected components
vacuoledata = regionprops(cc,'basic'); %get a list of vacuole in the figure
vacuole_areas = [vacuoledata.Area]; %get the area of each vacuole
s = regionprops(BWnobord, {'Centroid'}); %find the center of mass of each vacuole
hold on
numObj = numel(s); %total number of vacuoles
label_num = 0;
dist_array = {};
for k = 1 : numObj
    plot(s(k).Centroid(1), s(k).Centroid(2), 'ro'); %plot the red label in the center of mass of each vacuole.
    label_num = label_num + 1;
    dist_array = [dist_array, vacuole_areas(k)];
end
hold off
%output the results.
label_num_str = ['No. of Vacuoles=' num2str(label_num)];
set(handles.area_min,'String',min(vacuole_areas));
set(handles.area_max,'String',max(vacuole_areas));
set(handles.output_num,'String',label_num_str);

nbins = 30; % the number of bins for histogram
axes(handles.axes2); % show the figure in axes2
%convert the matrix to vector
x=reshape(dist_array.', 1, []);
x=[x{:}] ;
hist(x,nbins); %plot the histogram






function area_min_Callback(hObject, eventdata, handles)
% hObject    handle to area_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of area_min as text
%        str2double(get(hObject,'String')) returns contents of area_min as a double


% --- Executes during object creation, after setting all properties.
function area_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to area_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function area_max_Callback(hObject, eventdata, handles)
% hObject    handle to area_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of area_max as text
%        str2double(get(hObject,'String')) returns contents of area_max as a double


% --- Executes during object creation, after setting all properties.
function area_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to area_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in modified_counting.
function modified_counting_Callback(hObject, eventdata, handles)
% hObject    handle to modified_counting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global K dist_array label_num J I;
axes(handles.axes1);
BWnobord = imclearborder(J, 8); 
rgb_perim = bwperim(im2bw(BWnobord)); 
overlay1 = imoverlay(rgb2gray(K),rgb_perim, [.3 1 .3]); 
imshow(overlay1)
cc = bwconncomp(BWnobord, 8);
vacuoledata = regionprops(cc,'basic');
vacuole_areas = [vacuoledata.Area];
s = regionprops(BWnobord, {'Centroid'});
hold on
numObj = numel(s);
label_num = 0;
dist_array = {};
min_areas=str2num(get(handles.area_min,'String')); %get the modified area minimum
max_areas=str2num(get(handles.area_max,'String')); %get the modified area maximum
for k = 1 : numObj
    %find the vacuoles in the modified area range
    if (vacuole_areas(k) >= min_areas) & ( vacuole_areas(k) <= max_areas)
    plot(s(k).Centroid(1), s(k).Centroid(2), 'ro');
    label_num = label_num + 1;
    dist_array = [dist_array, vacuole_areas(k)];
    end
end
hold off
%output the results
label_num_str = ['No. of Vacuoles=' num2str(label_num)];
set(handles.area_min,'String',min_areas);
set(handles.area_max,'String',max_areas);
set(handles.output_num,'String',label_num_str);

nbins = 30; % the number of bins for histogram
axes(handles.axes2); % show the figure in axes2
%convert the matrix to vector
x=reshape(dist_array.', 1, []);
x=[x{:}] ;
hist(x,nbins); %plot the histogram



function output_num_Callback(hObject, eventdata, handles)
% hObject    handle to output_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of output_num as text
%        str2double(get(hObject,'String')) returns contents of output_num as a double


% --- Executes during object creation, after setting all properties.
function output_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function rotate_slider_Callback(hObject, eventdata, handles)
% hObject    handle to rotate_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global K dist_array label_num J I;
axes(handles.axes1);
v1=get(handles.rotate_slider,'value'); %get the value of the slider bar
J=imrotate(I,v1); %rotate images
imshow(J)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function rotate_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotate_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% Draw black line to seperate the connected vacuoles.
function draw_lines_Callback(hObject, eventdata, handles)
% hObject    handle to draw_lines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global K dist_array label_num J I;
axes(handles.axes1);
imshow(J);
monochromeImage = J;
%Draw lines into image
burnedImage = J;
cumulativeBinaryImage = false(size(burnedImage)); %lines will draw in the cumulativeBinaryImage.
axis on;
again = true;
lineCount = 0;
%use a loop to draw lines and show the result figures.
while again && lineCount < 10000
	promptMessage = sprintf('Modify the image, or Quit?', lineCount + 1);
	titleBarCaption = 'Continue?';
	button = questdlg(promptMessage, titleBarCaption, 'Draw', 'Quit', 'Draw');
	if strcmpi(button, 'Quit')
		break;
	end
	lineCount = lineCount + 1;
	hLine = imline(gca); %draw lines in the figure.
	singleLineBinaryImage = hLine.createMask();%Create a binary image from cropped image.
	%combine the lines and original image.
    cumulativeBinaryImage = cumulativeBinaryImage | singleLineBinaryImage;
	burnedImage(cumulativeBinaryImage) = 0; % 0 is black line
	cla;
	imshow(burnedImage);
end
J=burnedImage;


% Save the area of vacuole as text format.
function save_area_data_Callback(hObject, eventdata, handles)
% hObject    handle to save_area_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global K dist_array label_num J I;
[filename1, pathname1] = uiputfile('*.txt','Save Vacuoles Area As'); %set the output type
dlmwrite([pathname1,filename1],dist_array) %write vacuoles area to the output file.


% Draw white line to delete unwanted vacuoles.
function white_line_Callback(hObject, eventdata, handles)
% hObject    handle to white_line (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global K dist_array label_num J I;
axes(handles.axes1);
imshow(J);
monochromeImage = J;
%Draw lines into image
burnedImage = J;
cumulativeBinaryImage = false(size(burnedImage)); %lines will draw in the cumulativeBinaryImage.
axis on;
again = true;
lineCount = 0;
%use a loop to draw lines and show the result figures.
while again && lineCount < 10000
	promptMessage = sprintf('Modify the image, or Quit?', lineCount + 1);
	titleBarCaption = 'Continue?';
	button = questdlg(promptMessage, titleBarCaption, 'Draw', 'Quit', 'Draw');
	if strcmpi(button, 'Quit')
		break;
	end
	lineCount = lineCount + 1;
	hLine = imline(gca); %draw lines in the figure.
	singleLineBinaryImage = hLine.createMask();%Create a binary image from cropped image.
	%combine the lines and original image.
    cumulativeBinaryImage = cumulativeBinaryImage | singleLineBinaryImage;
	burnedImage(cumulativeBinaryImage) = 255; %255 is white line
	cla;
	imshow(burnedImage);
end
J=burnedImage;