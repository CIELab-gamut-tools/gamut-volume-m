function PlotRings(gamut, varargin)
% PlotRings Plot a Gamut Rings figure from CIELab gamut data
%
% Syntax:
%   PlotRings(gamut);
%   PlotRings(gamut, refGamut);
%   PlotRings(gamut, refGamut1, refGamut2);
%   PlotRings(___, 'parameter', value, ...);
%
% Input Arguments:
%   gamut, refGamut etc are all gamut objects returned by one of
%   CIELabGamut, IntersectGamuts or SyntheticGamut.
%
% Examples:
%   % A simple rings plot with a reference
%   sRGB = CIELabGamut('sRGB.txt');
%   gamut = CIELabGamut('sampleGamut.txt');
%   figure;
%   PlotRings(gamut, sRGB);
%   % The same figure showing the difference in the primary colours
%   figure;
%   PlotRings(gamut, sRGB,... 
%     'LLabelIndices',[], ... %Turn of the label indices
%     'RingReference','intersection', ... %Show, per ring, the intersection
%     'ChromaRing',1000, ... %Show a ring of constant chroma
%     'Primaries','all', ... %Show all primaries - RGBCMY
%     'RefPrimaries','all'); %And the reference primaries
%
% Parameters:
% +General
%   Axes              - Set which axes to use for the plot
%                       [gca (default) | axes handle]
%
%   ClearAxes         - Set if the current axes should be cleared
%                       [true (default) | false]
%
% +Gamut Rings Format
%   LRings            - The inner L* values of the gamut rings. The outer
%                       ring, L*=100, is always shown.
%                       [10:10:90 (default) | vector]
%
%   LLabelIndices     - The indices of the L* values to label.
%                       [[1 5] (default) | vector of indices]
%
%   LLabelColors      - The colour or colours of each L* label.  If
%                       'default' then the outer label is black and the
%                       others white. If a single colour (a name or an rgb
%                       triplet) then this is applied to all labels.  A
%                       cell array, or a matrix of RGB values, can be used
%                       to specify colours for each label.
%                       ['default' | char | n x 3 matrix | cell array] 
%
%   RingLine          - The linespec of all the gamut rings.
%                       ['k' (default) | char] 
%
%   RefLine           - The linespec of the first outer reference gamut ring.
%                       ['--k' (default) | char] 
%
%   Ref2Line          - The linespec of the second outer reference gamut ring.
%                       [':k' (default) | char] 
%
%   IntersectionPlot  - Specify if, when a test and reference gamut is
%                       specified, the intersection plot should be rendered
%                       rather than the standard rings plot.
%                       [true | false (default)]
%
%   IntersectionLine  - The linespec used for plotting the intersection
%                       ['' (default) | char]
%
%   IntersectGamut    - If true the test gamut is intersected with the
%                       (first or only) reference gamut before display.  If
%                       the intersection plot is shown, this is
%                       automatically true.
%                       [true | false (default)]
%
% +Gamut Bands
%   ShowBands         - The Bands are the coloured sections between the
%                       rings which can visually indicate the band order
%                       (that the inner bands are dark) and hue angles.
%                       [true (default) | false] 
%
%   BandChroma        - How saturated the band hue colours should be.  Set
%                       this to 0 for the bands to be monochrome.
%                       [50 (default) | positive scalar]
%
%   BandLs            - The lightnesses of the bands.  If this is a
%                       2-element vector then it indicates the min and max
%                       lightnesses, otherwise the number of values must
%                       match the number of bands defined in LRings
%                       *including the outer L*=100 band*
%                       [[20 90] (default) | vector]
%
%   BandHue           - The hue of the bands.  This can either match the
%                       hue angle of the chart ('match'), or be a fixed
%                       hue. The hue is defined as 0 for a*=1, b*=0 and 90
%                       for a*=0, b*=1.
%                       [0-359 | 'match' (default)]
%
%   ShowRefBands      - Display bands containing the reference and test
%                       gamuts. Where the reference band is not overlapped
%                       by the test band, the colour shown will accord with
%                       the RefBand settings.
%                       [true (default) | false]
%
%   RefBandChroma     - As BandChroma, applied to the Ref Band, if shown.
%                       [0 (default) | positive scalar]
%
%   RefBandLs         - As BandLs, applied to the Ref Band, if shown.
%                       [[30 98] (default) | vector]
%
%   RefBandHue        - As BandHue, applied to the Ref Band, if shown.
%                       [0-359 | 'match' (default)]
%
% +Decorations
%   CentMark          - The linespec of the centre marker.  An empty array
%                       indicates no centre mark.
%                       ['+k' (default) | char | []]
%
%   CentMarkSize      - The size of the centre mark.
%                       [20 (default) | positive scalar]
%
%   ChromaRings       - The values at which to plot rings of constant RSS
%                       Chroma.
%                       [[] (default) | vector]
%
%  +Primary Colour Indicators
%   Primaries         - The primary colours can be shown as arrows out from
%                       the gamut rings plot indicating the hue of the
%                       primaries, their difference to the reference
%                       primaries (if these are plotted), with the arrow
%                       head colour matched, as closely as possible, to the
%                       actual primary colour (assuming an sRGB
%                       reproduction).
%                       ['rgb' (default) | 'none' | 'all']
%
%   PrimaryColor      - The colours of the vector arrows are, by default
%   PrimaryColour       set to equal the observed colour of the primary
%                       ('output').  They can also be set to the nominal
%                       primary colour ('input');
%                       ['input' | 'output' (default)]
%
%   PrimaryChroma     - The C_RSS radius of the primary arrow head.
%                       If 'auto' it will be the max ring or ref chroma
%                       plus 100.
%                       [950 (default) | positive scalar | 'auto'] 
%
%   PrimaryOrigin     - From where the primary arrows will be drawn.
%                       ['centre' (default) | 'center' | 'ring']
%
%
%   RefPrimaries      - Which reference primaries to show
%                       ['none' (default) | 'rgb' | 'all']
%
%   RefPrimaryChroma  - The C_RSS radius of the ref primary arrow head.
%                       If 'auto' it will be the PrimaryChroma + 50
%                       [positive scalar | 'auto' (default)] 
%
%   RefPrimaryOrigin  - From where the ref primary arrows will be drawn.
%                     - ['ring' (default) | 'centre' | 'center']
%
%  +Scatter Point Data
%   ScatterData       - An n x 3 matrix of L*,a*,b* data, to be used as
%                       scatter points.
%
% See also CIELabGamut, PlotVolume, GetVolume, IntersectGamuts, SyntheticGamut
%
% https://github.com/CIELab-gamut-tools/gamut-volume-m



%import all of the functions in the +CIEtools folder
try
    import CIEtools.*;
catch
    octimport CIEtools;
end

%Set some implementation dependent constants
if isOctave
    ASCALE=30;
else
    ASCALE=200;
end

%Use matlab's in-built input parser to deal with the params and options
p = inputParser;

%A function to test that a struct has the right fields to be a gamut object
validGamut = @(x) all(isfield(x,{'hsteps','Lsteps','title','cylmap'}));

%=====Input Data=====
addRequired(p,'gamut',validGamut);
addOptional(p,'ref',[],validGamut);
addOptional(p,'ref2',[],validGamut);

%=====General Figure Options=====
addParameter(p,'Axes',gca,@ishghandle);
addParameter(p,'ClearAxes',true,@islogical);

%=====Gamut Ring Format=====
addParameter(p,'LRings',10:10:90,@isnumeric);
addParameter(p,'LLabelIndices',[1,5],@isnumeric);
addParameter(p,'LLabelColors','default',@(x) ischar(x) || isstring(x) || (isnumeric(x) && size(x,2)==3) || iscell(x));
addParameter(p,'RingLine','k',@ischar);
addParameter(p,'RefLine','--k',@ischar);
addParameter(p,'Ref2Line',':k',@ischar);
addParameter(p,'IntersectionLine','',@ischar);
addParameter(p,'RingReference','none',@(x) any(validatestring(x,{'none','intersection','ref'},'PlotRings')));
addParameter(p,'IntersectGamuts',false,@islogical);
addParameter(p,'IntersectionPlot',false,@islogical);

%=====Gamut Band Format=====
validHue = @(x) isnumeric(x) || any(validatestring(x,{'match'},'PlotRings'));
addParameter(p,'ShowBands',true,@islogical);
addParameter(p,'BandChroma',50,@isnumeric);
addParameter(p,'BandLs',[20 90],@isnumeric);
addParameter(p,'BandHue','match',validHue);
addParameter(p,'ShowRefBands',true,@islogical);
addParameter(p,'RefBandChroma',0,@isnumeric);
addParameter(p,'RefBandLs',[30 98],@isnumeric);
addParameter(p,'RefBandHue','match',validHue);

%=====Chart Decorations=====
addParameter(p,'CentMark','+k',@ischar);
addParameter(p,'CentMarkSize',20,@isscalar);
addParameter(p,'ChromaRings',0,@isnumeric);

%=====Primary colour indicators=====
validateOrigin = @(x) validatestring(x,{'centre','center','ring'},'PlotRings');
validOrigin = @(x) any(validateOrigin(x));
validPrimaries = @(x) any(validatestring(x,{'none','rgb','all'},'PlotRings'));
validChroma = @(x) isnumeric(x) || any(validatestring(x,{'auto'},'PlotRings'));
addParameter(p,'PrimaryChroma',950,validChroma);
addParameter(p,'PrimaryChromaOffset','centre',validOrigin);
addParameter(p,'PrimaryOrigin','centre',validOrigin);
addParameter(p,'RefPrimaryChroma',1000,validChroma);
addParameter(p,'RefPrimaryChromaOffset','centre',validOrigin);
addParameter(p,'RefPrimaryOrigin','ring',validOrigin);
addParameter(p,'Primaries','rgb',validPrimaries);
addParameter(p,'RefPrimaries','none',validPrimaries);
validCol=  @(x) isempty(x) || any(validatestring(x,{'input','output'}));
addParameter(p,'PrimaryColour',[],validCol);
addParameter(p,'PrimaryColor',[],validCol);

%=====Scatter Point Data=====
addParameter(p,'ScatterData',[],@(x) isnumeric(x)&&size(x,2)==3);

% now run the parser on the input parameters
parse(p,gamut,varargin{:});

% extract a few values from the parsed results
refgamut = p.Results.ref;
refgamut2 = p.Results.ref2;

% if required, calculate the intersected gamut
intersectionPlot = p.Results.IntersectionPlot && validGamut(refgamut);
intersectGamuts = p.Results.IntersectGamuts || intersectionPlot;
if intersectGamuts && validGamut(refgamut)
  testGamut = IntersectGamuts(gamut, refgamut);
  origVol = GetVolume(gamut);
else
  testGamut = gamut;
  origVol = [];
end

%calculate the main set of gamut rings
lrings = p.Results.LRings;
if intersectionPlot
  rings = ringsBase(testGamut,lrings, refgamut);
  [testX, testY, testVol] = calcSubRings(rings, testGamut);
  [refX, refY, refVol] = calcSubRings(rings, refgamut);
else
  rings = ringsBase(testGamut,lrings);
  testX = rings.x(2:end,:);
  testY = rings.y(2:end,:);
  if ~isempty(refgamut)
      [refX,refY] = calcRings(refgamut,[]);
  end
  testVol = rings.vol;
  if validGamut(refgamut), refVol = GetVolume(refgamut); end
end

axes(p.Results.Axes);
if (p.Results.ClearAxes), clf; end
box on;
hold on;

% calculate the max RSS chroma
maxChroma = sqrt(max(testX(:).^2+testY(:).^2));
if ~isempty(refgamut)
    maxChroma = max(maxChroma, sqrt(max(refX(:).^2+refY(:).^2)));
end

if strcmp(p.Results.PrimaryChroma,'auto')
  primaryChroma = maxChroma + 100;
else
  primaryChroma = p.Results.PrimaryChroma;    
end

if strcmp(p.Results.RefPrimaryChroma,'auto')
  refPrimaryChroma = primaryChroma + 50;
else
  refPrimaryChroma = p.Results.RefPrimaryChroma;    
end

% ================== Main figure ===================== %

%add the reference coloured bands, if specified
if (intersectionPlot && p.Results.ShowRefBands)
    %fill in the colours
    chroma=p.Results.RefBandChroma;
    N=size(rings.x,1)-1;
    ls=normRange(p.Results.RefBandLs,N);
    lim=size(rings.x,2)*2;
    TRI=[1:lim; 2:lim 1; 3:lim 1:2]; 
    for n=1:N
        xc=reshape([rings.x(n,:);refX(n,:)],[],1);
        yc=reshape([rings.y(n,:);refY(n,:)],[],1);
        rgb=lab2srgb([ls(n)+zeros(size(xc)), chroma*kron(rings.ux(:),[1;1]), chroma*kron(rings.uy(:),[1;1])])/255;
        noLegend(patch('XData',xc(TRI),'YData',yc(TRI),'EdgeColor','none',...
          'FaceVertexCData',rgb(TRI,:),'FaceColor','interp'));
    end
end

%add the coloured bands, if specified
if (p.Results.ShowBands)
    %fill in the colours
    chroma=p.Results.BandChroma;
    N=size(rings.x,1)-1;
    ls=normRange(p.Results.BandLs,N);
    lim=size(rings.x,2)*2;
    TRI=[1:lim; 2:lim 1; 3:lim 1:2]; 
    for n=1:N
        xc=reshape([rings.x(n,:);testX(n,:)],[],1);
        yc=reshape([rings.y(n,:);testY(n,:)],[],1);
        rgb=lab2srgb([ls(n)+zeros(size(xc)), chroma*kron(rings.ux(:),[1;1]), chroma*kron(rings.uy(:),[1;1])])/255;
        noLegend(patch('XData',xc(TRI),'YData',yc(TRI),'EdgeColor','none',...
          'FaceVertexCData',rgb(TRI,:),'FaceColor','interp'));
    end
end

%plot the figure
if ~isempty(p.Results.RingLine)
    h=plot(rings.x(:,[1:end 1])',rings.y(:,[1:end 1])',p.Results.RingLine);
    noLegend(h(1:end-1));
end

if ~isempty(p.Results.IntersectionLine) && intersectionPlot
    h=plot(testX(:,[1:end 1])',testY(:,[1:end 1])',p.Results.IntersectionLine);
    noLegend(h(1:end-1));
end

% ================== Ring Labels ===================== %
% LLabelIndices indicates which lrings will have a label
% LLabelColors indicates what colour they will be.
%    ischar: 'default' or a colour name
%    isnumeric: 1 x 3 or n x 3 array of colours
%    iscell: a cell entry per colour (this is what will be output)
allLRings = [lrings, 100];
labelIndices = p.Results.LLabelIndices(p.Results.LLabelIndices<=numel(allLRings));
cols = p.Results.LLabelColors;
if ischar(cols) || isstring(cols)
    if strcmp(p.Results.LLabelColors,'default')
        cols=(p.Results.LLabelIndices(:)<numel(allLRings))*[1,1,1];
    else
        cols=repmat({cols},numel(labelIndices));
    end
end
if isnumeric(cols)
    if size(cols,1)==1
        cols=repmat({cols},numel(labelIndices));
    else
        cols=mat2cell(cols,ones(1,size(cols,1)));
    end
end

for n=1:numel(labelIndices)
    i=labelIndices(n);
    text(rings.x(i+1,floor(end*15/16)),rings.y(i+1,floor(end*15/16)),sprintf('L*=%d',allLRings(i)),'Color',cols{n},'FontWeight','normal');
end

% ================== Centre mark ===================== %
%add a central marker
if ~isempty(p.Results.CentMark)
    noLegend(plot(0,0,p.Results.CentMark,'MarkerSize',p.Results.CentMarkSize));
end

% ================== Chroma rings ===================== %
if (~isempty(p.Results.ChromaRings))
    r=p.Results.ChromaRings;
    %plot in 3D at z=-2 to be behind both the rings and 
    noLegend(plot3((r(:)*sin(0:pi/50:2*pi))',(r(:)*cos(0:pi/50:2*pi))',(r(:)*zeros(1,101))'-2,'Color',[0.7,0.7,0.7]));
end

% ================== Reference rings ===================== %
%if a reference is supplied, add just the L*=100 line
if ~isempty(refgamut) && ~intersectionPlot
    [xref,yref] = calcRings(refgamut,[]);
    plot(xref(end,[1:end 1]),yref(end,[1:end 1]),p.Results.RefLine);
end
%if a second reference is supplied, add just the L*=100 line
if ~isempty(refgamut2) && strcmp(ringRef,'none')
    [xref2,yref2] = calcRings(refgamut2,[]);
    plot(xref2(end,[1:end 1]),yref2(end,[1:end 1]),p.Results.Ref2Line);
end

% ================== Primary Colour Indicators ===================== %
prims=[eye(3);1-eye(3)];
switch validatestring(p.Results.Primaries,{'none','rgb','all'})
    case 'none'
        nprims=0;
    case 'rgb'
        nprims=3;
    case 'all'
        nprims=6;
end
switch validatestring(p.Results.RefPrimaries,{'none','rgb','all'})
    case 'none'
        nrefprims=0;
    case 'rgb'
        nrefprims=3;
    case 'all'
        nrefprims=6;
end

ringorigin=strcmp(validateOrigin(p.Results.PrimaryOrigin),'ring');
ringoffset=strcmp(validateOrigin(p.Results.PrimaryChromaOffset),'ring');
rringorigin=strcmp(validateOrigin(p.Results.RefPrimaryOrigin),'ring');
rringoffset=strcmp(validateOrigin(p.Results.RefPrimaryChromaOffset),'ring');
vcolsource = p.Results.PrimaryColor;
if isempty(vcolsource), vcolsource = p.Results.PrimaryColour; end
usevcol = isempty(vcolsource) || strcmp(vcolsource,'output');
%loop through all the primaries (RGBCMY) for which indicators are required
for n=1:max(nprims,nrefprims)
    ri=[];
    i=[];
    %reference primaries first.
    if (n<=nrefprims && ~(isempty(refgamut)))
        %find the specified primary
        ri=find(all(refgamut.RGB==prims(n,:)*refgamut.RGBmax,2),1);
        %if it exists
        if (~isempty(ri))
            %get the Lab values
            rlab=refgamut.LAB(ri,:);
            %calculate the nearest sRGB colour
            rcol=lab2srgb(rlab)/255;
            %calculate the hue - may be needed for the origin or a linking arc
            rhue=mod(floor(0.5+atan2(rlab(2),rlab(3))/pi*180)+719,360)+1;
            %calculate the chroma of the outer ring at this hue
            rringchroma = sqrt(refX(end,rhue).^2+refY(end,rhue).^2);
            %offset the head chroma if need be
            if (rringoffset)
                rchroma = refPrimaryChroma + rringchroma;
            else
                rchroma = refPrimaryChroma;
            end
            %calculate the end of the arrow
            rpt=rlab(2:3)*rchroma/norm(rlab(2:3));
            %and a mid-point - the reference arrows are only coloured at
            %their ends
            mpt=rpt*0.9;
            if (rringorigin)
                %start from the ring, so find the closest hue angle
                %and get the point on the ring
                opt=rlab(2:3)*rringchroma/norm(rlab(2:3));
            else
                %start from the origin
                opt=[0,0];
            end
            %plot, and make sure this line won't appear in any legend
            %first plot the grey line to the mid-point
            noLegend(plot([opt(1),mpt(1)],[opt(2),mpt(2)],'Color',[0.7,0.7,0.7]));
            %then use quiver to plot an arrow from the mid-point to the tip
            rvect=[rpt(1)-mpt(1),rpt(2)-mpt(2)];
            noLegend(quiver(mpt(1),mpt(2),rvect(1),rvect(2),'Color',rcol,'LineWidth',1.5,'MaxHeadSize',ASCALE/norm(rvect),'AutoScale','off'));
        end                        
    end
    %now do the gamut primary
    if (n<=nprims)
        %find the primary
        i=find(all(gamut.RGB==prims(n,:)*gamut.RGBmax,2),1);
        %if it exists
        if (~isempty(i))
            %get the Lab value
            lab=gamut.LAB(i,:);
            if usevcol
              %calculate the nearest sRGB colour
              col=lab2srgb(lab)/255;
            else
              col=prims(n,:);
            end
            %calculate the hue
            hue=mod(floor(0.5+atan2(lab(2),lab(3))/pi*180)+719,360)+1;
            %calculate the chroma of the outer ring at this hue
            ringchroma = sqrt(rings.x(end,hue).^2+rings.y(end,hue).^2);
            %offset the head chroma if need be
            if (ringoffset)
                chroma = primaryChroma + ringchroma;
            else
                chroma = primaryChroma;
            end
            %calculate the end of the arrow
            pt=lab(2:3)*chroma/norm(lab(2:3));
            %and the start
            if (ringorigin)
                %from the ring
                opt=lab(2:3)*ringchroma/norm(lab(2:3));
            else
                %or from the origin
                opt=[0,0];
            end
            %plot the arrow using quiver
            vect=pt-opt;
            noLegend(quiver(opt(1),opt(2),vect(1),vect(2),'Color',col,'LineWidth',1.5,'MaxHeadSize',ASCALE/norm(vect),'AutoScale','off'));
        end        
    end
    %if there was both a test and reference primary
    if (~(isempty(refgamut) || isempty(ri) || isempty(i)))
        %make a little dotted arc to link them.
        rng=(hue:sign(rhue-hue):rhue)/180*pi;
        noLegend(plot(0.95*chroma*sin(rng),0.95*chroma*cos(rng),':k'));
    end
end

%add a little padding to the axis range
axis(axis*1.05);
%make the axes equal
axis equal
%add the title
t=sprintf('CIELab gamut rings\n%s\nVolume = %g',gamut.title, testVol);
title(t);
%and the axis labels
xlabel('a^*_{RSS}')
ylabel('b^*_{RSS}')

% ================== Scatter Points ===================== %
if ~isempty(p.Results.ScatterData)
  dH=2*pi/gamut.hsteps;
  dL=100/gamut.Lsteps;
  LAB = p.Results.ScatterData;
  [LABu,~,ic] = unique(LAB,'rows');
  cnt = accumarray(ic,1);
  i = floor(LABu(:,1)/10);
  a = atan2(LABu(:,2),LABu(:,3));
  h = mod(a/pi*180+360,360);
  rx = interp2(0:360,0:10,rings.x(:,[end 1:end]),h,i);
  ry = interp2(0:360,0:10,rings.y(:,[end 1:end]),h,i);
  v = sum(LABu(:,2:3).^2,2)*dL*10*dH/2;
  bv = (rx.^2+ry.^2)*dH/2;
  r = (2*(bv+v)/dH).^0.5;
  mr=ceil(max(r(:)));
  density = accumarray([floor(sin(a).*r+0.5)+mr+1,floor(cos(a).*r+0.5)+mr+1],cnt,[2*mr+1,2*mr+1]);
  density = conv2(density,[0,1,0;1,2,1;0,1,0],'same');
%   density = conv2(density,ones(3,3),'same');
%   density = conv2(density,ones(3,3),'same');
  alph = zeros(size(density));
  alph(density>0) = (log(density(density>0))+2)/(log(max(density(:)))+2);
  % alph=(density'/max(density(:))).^0.25;
  image(-mr:mr,-mr:mr,zeros(2*mr+1,2*mr+1,3),'AlphaData',alph');
end

hold off;
end

function [x,y,rings,vol]=calcRings(gamut,LRings)
    dH=2*pi/gamut.hsteps;
    dL=100/gamut.Lsteps;
    %get the map of the volume in cylintrical coordinates
    volmap=cellfun(@(a) sum(a(:,1).*(a(:,2).^2)*dL*dH/2),gamut.cylmap);
    %Get the accumulated volume sum (the final row will be the total)
    %and calculate the radius required to represent that volume
    %adding a zero radius at the start
    rings=interp1([0 1:100/gamut.Lsteps:100],[zeros(1,gamut.hsteps);(2*cumsum(volmap)/dH).^0.5],[0 LRings 100]);
    %Plot against the mid-point of the angle ranges
    midH=dH/2:dH:2*pi;
    x=repmat(sin(midH),numel(LRings)+2,1).*rings;
    y=repmat(cos(midH),numel(LRings)+2,1).*rings;
    vol=sum(volmap(:));
end

function noLegend(h)
    if (~isempty(h))
        set(h,'HandleVisibility','off');
    end
end

function [rings] = ringsBase(gamut, LRings, ref)
     dH=2*pi/gamut.hsteps;
     dL=100/gamut.Lsteps;
     %get the map of the volume in cylintrical coordinates
     volmapFn = @(a) sum(a(:,1).*(a(:,2).^2)*dL*dH/2);
     if (nargin > 2)
       volmap=cellfun(volmapFn,ref.cylmap);
     else
       volmap=cellfun(volmapFn,gamut.cylmap);
     end
     %Get the accumulated volume sum (the final row will be the total)
     %and calculate the radius required to represent that volume
     %adding a zero radius at the start
     r2=interp1([0 1:100/gamut.Lsteps:100],[zeros(1,gamut.hsteps);(2*cumsum(volmap)/dH)],[0 LRings 100]);
     rings = struct();
     rings.r2 = r2;
     rings.midH=dH/2:dH:2*pi;
     rings.dH=dH;
     rings.dL=dL;
     rings.LRings=LRings;
     rings.ux=sin(rings.midH);
     rings.uy=cos(rings.midH);
     r=sqrt(r2);
     rings.x=r.*rings.ux;
     rings.y=r.*rings.uy;
     rings.vol=sum(volmap(:));
end

function [x,y,vol] = calcSubRings(rings, gamut)
    volmap=cellfun(@(a) sum(a(:,1).*(a(:,2).^2)*rings.dL*rings.dH/2),gamut.cylmap);
    ri2=interp1([0 1:100/gamut.Lsteps:100],[zeros(1,gamut.hsteps);(2*cumsum(volmap)/rings.dH)],[0 rings.LRings 100]);
    rg2=rings.r2;
    r=sqrt(min(rg2(2:end,:),(ri2(2:end,:)-ri2(1:end-1,:)+rg2(1:end-1,:))));
    x=r.*rings.ux;
    y=r.*rings.uy;
    vol=sum(volmap(:));
end

function t = isTrue(v)
    if islogical(v)
      t = v;
    else
      t = false;
    end
end

function values = normRange(range, N)
  if numel(range)==1
    values=repmat(range, 1, N);
  else
    values = interp1(normSteps(numel(range)),range,normSteps(N));
  end
end

function range = normSteps(N)
  range = (0:N-1)/(N-1);
end

