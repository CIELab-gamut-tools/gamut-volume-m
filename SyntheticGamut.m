function [gamut] = SyntheticGamut(varargin)
% SyntheticGamut
% Calculate a synthetic display gamut
% 
% Syntax:
%   gamut = SyntheticGamut(referenceName);
%   gamut = SyntheticGamut(RGBxy);
%   gamut = SyntheticGamut(RGBxy, white);
%   gamut = SyntheticGamut(RGBxy, driveMapping);
%   gamut = SyntheticGamut(RGBxy, white, driveMapping);
%   gamut = SyntheticGamut(colorantXYZ, driveMapping);
%   gamut = SyntheticGamut(___, 'parameter', value, ...);
%
% Input Arguments:
%   referenceName is a string or char array, and one of 'sRGB', 'DCI-P3',
%     'BT.2020'.
%
%   RGBxy is a 3x2 matrix of CIE1931 x,y chromaticities in the row order
%     red, green then blue.
%
%   white is either a 2-element row vector and specifies the CIE1931 x,y 
%     chromaticity coordinates for the white point, or is a string or char
%     array specifying the white point and will be one of 'D50', 'D60',
%     'D65' or 'DCI-P3'.
%
%   driveMapping is a function which maps a set of linear rgb signal levels
%     to drive levels for the supplied colorants.  For the case where RGB
%     chromaticities have been supplied, the fourth colorant is a white, so
%     this function can be used to simulate an RGBW display.  For the case
%     where a set of N colorant X,Y,Z values have been supplied this
%     function is required to map from the 3 linear RGB signal levels to
%     the required N signal levels. The function will be called with an Mx3
%     matrix of nominal drive signals and should return an MxN matrix of
%     drive signals to be used on the N display colorants.
%
%   colorantXYZ is an Nx3 matrix of CIE1931 X,Y,Z tristimulous values for
%     each colorant in the simulated display.  This must be supplied where
%     more than the standard three primary RGB colorants, plus white, are
%     used.  These must be supplied as tristimulous values rather than
%     chromaticities as there is no standard way to ascertain the
%     luminances of each colorant to product a standard white point.
%     Instead the white point will be calculated from these values and the
%     required driveMapping for input RGB signals all at full scale.
%   
% Examples:
%   % Compare the gamut volumes of BT2020 and sRGB
%   sRGBvol = GetVolume(SyntheticGamut('sRGB'));
%   BT2020vol = GetVolume(SyntheticGamut('BT.2020'));
%   r = BT2020vol/sRGBvol;
%   sprintf('The BT2020 gamut volume is %gx that of sRGB\n', r);
%
%   % Assess the impact of white point selection on a gamut volume
%   D50gmt = SyntheticGamut([.68,.32;.265,.69;.15,.06],'D50');
%   D65gmt = SyntheticGamut([.68,.32;.265,.69;.15,.06],'D65');
%   sprintf('Gamut assuming a D50 white point is %g\n',GetVolume(D50gmt));
%   sprintf('Gamut assuming a D65 white point is %g\n',GetVolume(D65gmt));
%
%   % Assess the impact on gamut volume of the use of a white boosted RGBW
%   for wb=0:0.25:1
%     mapping = @(s) [s, wb*min(s,[],2)];
%     gamut = SyntheticGamut([.64,.33;.3,.6;.15,.06], mapping);
%     sprintf('Gamut volume with %g%% white boost is %g\n',...
%       wb*100, GetVolume(gamut));
%   end
%
% Parameters:
%   Gamma             - Either a scalar value or a function used to map
%                       the relative RGB value to a drive level.  Both the
%                       value and drive level will be in the range 0-1.
%                       A value is taken as the gamma value of a power law
%                       so that drive = value.^gamma.  A function will be
%                       called with a matrix of values and is expected to
%                       return a similar matrix of drive levels.  The
%                       general default is a gamma of 2.4, however this
%                       can be set by the use of a standard reference
%                       gamut.
%                       [2.4 | scalar | function]
%
%   Black             - The CIE1931 chromaticity of the black point. The
%                       default is to be the same as the white point.
%                       [[] | 2-element vector]
%
%   BlackRatio        - The ratio of the black signal luminance to the
%                       white signal lumance (i.e. the inverse of the
%                       contrast ratio).
%                       [0 | scalar]
%                    
%   Steps             - The number of signal steps to use per edge of the
%                       RGB cube.  The total number of points used will
%                       then be 6*steps^2+2.
%                       [10 | integer > 0]
%
%   Name              - The name of the gamut.  Can be used in subsiquent
%                       plots.
%                       ['Synthetic Gamut' or ref name | char | string]
%
% See also CIELabGamut, PlotVolume, GetVolume, IntersectGamuts, PlotRings
%
% https://github.com/CIELab-gamut-tools/gamut-volume-m
    try
        import CIEtools.*;
    catch
        octimport CIEtools;
    end

    %=====================================
    % Define the standard reference gamuts

    refs={...
        'srgb',[.64,.33;.3,.6;.15,.06],'d65',@(v) sRGBgamma(v); ...
        'bt.2020',[.708,.292;.17,.797;.131,.046],'d65',@(v) v.^2.4;...
        'dci-p3',[.68,.32;.265,.69;.15,.06],'dci-p3',@(v) v.^2.4;...
        'd65-p3',[.68,.32;.265,.69;.15,.06],'d65',@(v) v.^2.4;...
        'd60-p3',[.68,.32;.265,.69;.15,.06],'d60',@(v) v.^2.4;...
        };

    %=====================================
    % Define the standard white points, 1st is default
    
    whites={...
        'd50',[.3457,.3585];...
        'd55',[.3324,.3474];...
        'd60',[.32168,.33767];...
        'd65',[.3127,.3290];...
        'd75',[.2990,.3149];...
        'dci-p3',[.314,.351]};
    
    %=====================================
    % Validate the input
    
    isChrom = @(v,l) isnumeric(v) && isrow(v) && numel(v)==l;
    isfun = @(f) isa(f, 'function_handle');
    iscol = @(x) isChrom(x,2) || any(strcmpi(x,whites(:,1)));


    %=====Input Data=====
    % Parse the main input parameters manually, there does not seem a way
    % to automatically do this with the inputParser
    
    % defaults
    white = 'd65';
    driveMapping = @(x) x;
    RGBxy=[];
    colorantXYZ=[];
    name='Synthetic Gamut';
    gamma=2.4;
    
    if nargin<1
        error('SyntheticGamut: At least one parameter required');
    end
    
    % check for a standard colour space
    iref=find(strcmpi(varargin{1},refs(:,1)),1);
    if ~isempty(iref)
        name=varargin{1};
        RGBxy=refs{iref,2};
        white=refs{iref,3};
        gamma=refs{iref,4};
        idx=2;
    else
        if ~isnumeric(varargin{1}) 
            error('SyntheticGamut: Parameter 1 invalid');
        end
        % check if RGBxy supplied
        if all(size(varargin{1})==[3,2])
            RGBxy=varargin{1};
            % the next parameter could be the white point
            if nargin>1 && iscol(varargin{2})
                white=varargin{2};
                idx=3;
            else
                idx=2;
            end
        % otherwise check if colorants supplied
        elseif size(varargin{1},1)>=3 && size(varargin{1},2)==3
            colorantXYZ=varargin{1};
            idx=2;
        % otherwise throw an error
        else
            error('SyntheticGamut: Parameter 1 invalid');
        end
        % now check if a gamma function has been supplied
        if nargin>=idx && isfun(varargin{idx})
            driveMapping=varargin{idx};
            idx=idx+1;
        end
    end
    
    %=====Parameters=====
    % The rest of the parameters can use the input parser
    p=inputParser;
    addParameter(p,'Gamma',[],@(x) isscalar(x) || isfun(x));
    addParameter(p,'Black',[], @(x) isChrom(x,1,1));
    addParameter(p,'BlackRatio',0,@isscalar);
    addParameter(p,'Steps',10,@isnumeric);
    addParameter(p,'Name',[], @(x) ischar(x) || isstring(x));
    parse(p,varargin{idx:end});
    
    if ~isempty(p.Results.Gamma), gamma = p.Results.Gamma; end
    if isfun(gamma)
        gammaFn=gamma;
    else
        gammaFn=@(x) x.^gamma; 
    end
    black = p.Results.Black;
    blackR = p.Results.BlackRatio;
    steps = p.Results.Steps;
    if ~isempty(p.Results.Name), name=p.Results.Name; end
    %======================================
    % Main body of the function
    
    dfs = driveMapping([1,1,1]);
    % White balance calculations, if required
    if isempty(colorantXYZ)
        %Get the white point
        if ischar(white) || isstring(white)
            i=find(strcmpi(white,whites(:,1)),1);
            white=whites{i,2};
        end
        whiteXYZ=xy2XYZ(white);
        RGBnXYZ=xy2XYZ(RGBxy);
        Lrgb = whiteXYZ/RGBnXYZ;
        colorantXYZ = RGBnXYZ.*repmat(Lrgb',1,3);
        if numel(dfs)>3
            colorantXYZ(4,:) = whiteXYZ;
        end
    end
    
    %Work out the white point
    XYZn=dfs*colorantXYZ;
    
    %deal with the black point
    if blackR>0
        if ischar(black) || isstring(black)
            i=find(strcmpi(black,whites(:,1)),1);
            black=whites{i,2};
        elseif isempty(black)
            black=white;
        end        
        Lblack=XYZn(2)/(1/blackR-1);
        blackXYZ=xy2XYZ(black,Lblack);
        XYZn=XYZn+blackXYZ;
    else
        blackXYZ=[0,0,0];
    end
    
    % Calculate the RGB cube
    if isscalar(steps)
        steps = 0:1/steps:1;
    else
        steps = steps / max(steps);
    end
    [~,RGB]=make_tesselation(steps);
    RGB=unique(RGB,'rows');
    
    % get the drive levels
    RGBsig = gammaFn(RGB);
    RGBdrive = driveMapping(RGBsig);
    
    % get the XYZ values
    XYZ = RGBdrive * colorantXYZ + repmat(blackXYZ,size(RGB,1),1);
    
    gamut = CIELabGamut(RGB,XYZ,name);
    
end

