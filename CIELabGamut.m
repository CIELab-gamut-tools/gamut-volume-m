function gamut = CIELabGamut(varargin)
% CIELabGamut Build a representation of a CIELab gamut
%
% Syntax:
%   gamut = CIELabGamut();
%   gamut = CIELabGamut(filename);
%   gamut = CIELabGamut(filepath);
%   gamut = CIELabGamut(filepath, filter);
%   gamut = CIELabGamut(RGB,XYZ,title);
%
% Input Arguments:
%   If no arguments are given, the user can browse for a suitable ASCII
%     CGATS.17 file, containing measurement RGB signal levels and
%     measured XYZ data, from which the gamut will be loaded.
%
%   filename specifies the file to be loaded.
%
%   filepath specifies the path from which a file can be selected.
%
%   filter is the file pattern to be used in selecting files.
%
%   RGB is a matrix of RGB triplets arranged in rows.
%
%   XYZ is a matrix of XYZ triplets arranged in rows.
%
%   title is the title of the data to be used for plot titles etc.
%
% Returned Values:
%  gamut is a structure containing the gamut data which can be used by any
%  of the other analysis functions, such as GetVolume or PlotRings.
%
% Examples:
%  % Browse for a file
%  gamut = CIELabGamut();
%  % Browse for a file from a particular location
%  gamut = CIELabGamut('/path/to/folder','*.cgats');
%  % Load data from a particular file
%  gamut = CIELabGamut('sRGB.txt');
%  % Initialise data from supplied matrices
%  gamut = CIELabGamut(RGB, XYZ, 'simulated gamut');    
%
% see also GetVolume, IntersectGamuts, PlotVolume, PlotRings, SyntheticGamut

%import all of the functions in the +CIEtools folder
import CIEtools.*
% deal with the different input argument variants
if nargin < 3
    if nargin == 0
        [filename,path] = uigetfile('*.txt','Please select a CGATS gamut data file');
    elseif nargin == 1
        type = exist(varargin{1},'file');
        if type == 2 %file
            filename=varargin{1};
            path="";
        else
            [filename,path] = uigetfile(varargin{1},'Please select a CGATS gamut data file');
        end
    elseif nargin == 2
        [filename,path] = uigetfile(fullfile(varargin{:}),'Please select a CGATS gamut data file');
    end
    gamut=readCGATS(fullfile(path,filename));
    gamut.title=filename;
else
    gamut=[];
    gamut.RGB=varargin{1};
    gamut.XYZ=varargin{2};
    gamut.title=varargin{3};
end

%find the reference max RGB (don't assume it is 8-bit, for example)
gamut.RGBmax = max(gamut.RGB(:));
%find the white point
gamut.XYZn = gamut.XYZ(all(gamut.RGB==gamut.RGBmax,2),:);

%Get a D50 white point of equivalent luminance
D50=[0.9642957, 1, 0.8251046]*gamut.XYZn(2);

%Chromatically adapt CIE XYZ to D50 using CIECAM02 CAT
%assuming full adaptation and using the 'Bradford' coefficients
%if XYZn is already D50 this is harmless, and a check will fail without a
%reasonable tolerance.  Simplest is just to always adapt.
gamut.XYZ = camcat_cc(gamut.XYZ, gamut.XYZn, D50);
gamut.XYZn = D50;

%Get the standard tesslation in terms of the supplied RGB values
[TRI_ref, RGB_ref] = make_tesselation(unique(gamut.RGB));
map = map_rows(RGB_ref,gamut.RGB);
if (~all(map>0))
    fprintf('Missing RGB data\n');
    fprintf('%g, %g, %g\n',unique(RGB_ref(map==0,:),'rows')');
    return;
end
gamut.TRI=map(TRI_ref);

%Convert to CIE 1971 L*a*b* (CIELAB) color space
gamut.LAB=xyz2lab(gamut.XYZ,D50);
%finally calculate the surface intersections of L* rays
%use 100 L* steps and 360 hue steps
gamut.Lsteps=100;
gamut.hsteps=360;
gamut.cylmap = cielab_cylindrical_map(gamut);



end

