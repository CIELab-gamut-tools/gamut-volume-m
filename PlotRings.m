function PlotRings(gamut, varargin)
% PlotRings 
% Plot a Gamut Rings figure from CIELab gamut data
%
% Syntax:
%   PlotRings(gamut);
%   PlotRings(gamut, refGamut);
%   PlotRings(gamut, refGamut1, refGamut2);
%   PlotRings(___, 'parameter', value, ...);
%
% Input Arguments:
%   gamut, refGamut etc are all gamut objects returned by one of CIELabGamut
%   or IntersectGamuts.
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
%   RefLine           - The linespec of the first reference gamut ring.
%                       ['--k' (default) | char] 
%
%   Ref2Line          - The linespec of the second reference gamut ring.
%                       [':k' (default) | char] 
%
%   RingReference     - The single reference ring does not resolve the 
%                       gamut by luminance, it is just an indication of
%                       overall volume against hue.  This option provides
%                       two ways to visualise the comparison to the
%                       reference per lightness ring. 'intersection' plots
%                       a dotted line per ring which is the intersection of
%                       the test and (first) reference gamuts. 'ref' plots
%                       a dotted line per ring which is the volume of the
%                       reference gamut in the requisite lightness range,
%                       where it is less than the the test gamut.
%                       ['none' (default) | 'intersection' | 'ref'] 
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
%   BandLs            - The lightnesses of the bands.
%                       [20:70/9:90 (default) | vector]
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
%   PrimaryChroma     - The C_RSS radius of the primary arrow head.
%                       [950 (default) | positive scalar] 
%
%   PrimaryOrigin     - From where the primary arrows will be drawn.
%                     - ['centre' (default) | 'center' | 'ring']
%
%   RefPrimaries      - Which reference primaries to show
%                       ['none' (default) | 'rgb' | 'all']
%
%   RefPrimaryChroma  - The C_RSS radius of the ref primary arrow head.
%                       [1000 (default) | positive scalar] 
%
%   PrimaryOrigin     - From where the ref primary arrows will be drawn.
%                     - ['ring' (default) | 'centre' | 'center']
%
% See also CIELabGamut, PlotVolume, GetVolume, IntersectGamuts
%
% https://github.com/CIELab-gamut-tools/gamut-volume-m

%import all of the functions in the +CIEtools folder
import CIEtools.*

%Use matlab's in-built input parser to deal with the params and options
p = inputParser;

%A function to test that a struct has the right fields to be a gamut object
validGamut = @(x) all(isfield(x,{'hsteps','Lsteps','title','cylmap'}));

%=====Input Data=====
addRequired(p,'gamut',validGamut);
addOptional(p,'ref',[],validGamut);
addOptional(p,'ref2',[],validGamut);

%=====Gamut Ring Format=====
addParameter(p,'LRings',10:10:90,@isnumeric);
addParameter(p,'LLabelIndices',[1,5],@isnumeric);
addParameter(p,'LLabelColors','default',@(x) ischar(x) || isstring(x) || (isnumeric(x) && size(x,2)==3) || iscell(x));
addParameter(p,'RingLine','k',@ischar);
addParameter(p,'RefLine','--k',@ischar);
addParameter(p,'Ref2Line',':k',@ischar);
addParameter(p,'RingReference','none',@(x) any(validatestring(x,{'none','intersection','ref'},'PlotRings')));


%=====Gamut Band Format=====
addParameter(p,'ShowBands',true,@islogical);
addParameter(p,'BandChroma',50,@isnumeric);
addParameter(p,'BandLs',20:70/9:90,@isnumeric);

%=====Chart Decorations=====
addParameter(p,'CentMark','+k',@ischar);
addParameter(p,'CentMarkSize',20,@isscalar);
addParameter(p,'ChromaRings',0,@isnumeric);

%=====Primary colour indicators=====
addParameter(p,'PrimaryChroma',950,@isnumeric);
addParameter(p,'PrimaryOrigin','centre',@(x) any(validatestring(x,{'centre','center','ring'},'PlotRings')));
addParameter(p,'RefPrimaryChroma',1000,@isnumeric);
addParameter(p,'RefPrimaryOrigin','ring',@(x) any(validatestring(x,{'centre','center','ring'},'PlotRings')));
addParameter(p,'Primaries','rgb',@(x) any(validatestring(x,{'none','rgb','all'},'PlotRings')));
addParameter(p,'RefPrimaries','none',@(x) any(validatestring(x,{'none','rgb','all'},'PlotRings')));

% now run the parser on the input parameters
parse(p,gamut,varargin{:});

% extract a few values from the parsed results
refgamut = p.Results.ref;
refgamut2 = p.Results.ref2;
lrings = p.Results.LRings;

%calculate the main set of gamut rings
[x,y,~,vol] = calcRings(gamut,lrings);

clf;
box on;
hold on;

% ================== Main figure ===================== %

%plot the figure
if ~isempty(p.Results.RingLine)
    h=plot(x(:,[1:end 1])',y(:,[1:end 1])',p.Results.RingLine);
    noLegend(h(1:end-1));
end

%add the ring references, if specified
ringRef = validatestring(p.Results.RingReference,{'none','intersection','ref'});
if ~strcmp(ringRef,'none')
    if strcmp(ringRef,'intersection')
        ringref = IntersectGamuts(gamut, refgamut);
    else
        ringref = refgamut;
    end
    [xi,yi]=calcRings(ringref,lrings);
    ri=xi.^2+yi.^2;
    rg=x.^2+y.^2;
    rsc=min(1,sqrt((ri(2:end,:)-ri(1:end-1,:)+rg(1:end-1,:))./rg(2:end,:)));
    xd=x(2:end,:).*rsc;
    yd=y(2:end,:).*rsc;
    noLegend(plot(xd(:,[1:end 1])',yd(:,[1:end 1])',p.Results.RefLine));
end

%add the coloured bands, if specified
if (p.Results.ShowBands)
    %fill in the colours
    chroma=p.Results.BandChroma;
    ls=p.Results.BandLs;
    r=max(1,sqrt(x.^2+y.^2));
    lim=size(x,2)*2;
    TRI=[1:lim; 2:lim 1; 3:lim 1:2]'; 
    for n=1:size(x,1)-1
        xc=reshape(x(n:n+1,:),[],1);
        yc=reshape(y(n:n+1,:),[],1);
        rc=reshape(r(n:n+1,:),[],1);
        rgb=lab2srgb([ls(n)+rc*0, chroma*xc./rc, chroma*yc./rc])/255;
        noLegend(trisurf(TRI,xc,yc,zeros(lim,1)-1,...
            'EdgeColor','none',...
            'FaceVertexCData',rgb,...
            'FaceColor','interp'));
    end
end


% ================== Ring Labels ===================== %
% LLabelIndices indicates which lrings will have a label
% LLabelColors indicates what colour they will be.
%    ischar: 'default' or a colour name
%    isnumeric: 1 x 3 or n x 3 array of colours
%    iscell: a cell entry per colour (this is what will be output)
labelIndices = p.Results.LLabelIndices(p.Results.LLabelIndices<=numel(lrings));
cols = p.Results.LLabelColors;
if ischar(cols) || isstring(cols)
    if strcmp(p.Results.LLabelColors,'default')
        cols=(p.Results.LLabelIndices(:)<numel(lrings))*[1,1,1];
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
    text(x(i+1,floor(end*15/16)),y(i+1,floor(end*15/16)),sprintf('L*=%d',lrings(i)),'Color',cols{n},'FontWeight','demi');
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
if ~isempty(refgamut)
    [xref,yref] = calcRings(refgamut,[]);
    plot(xref(end,[1:end 1]),yref(end,[1:end 1]),p.Results.RefLine);
end
%if a second reference is supplied, add just the L*=100 line
if ~isempty(refgamut2)
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

r=p.Results.PrimaryChroma;
rr=p.Results.RefPrimaryChroma;
ringorigin=strcmp(validatestring(p.Results.PrimaryOrigin,{'centre','center','ring'}),'ring');
rringorigin=strcmp(validatestring(p.Results.RefPrimaryOrigin,{'centre','center','ring'}),'ring');
%loop through all the primaries (RGBCMY) for which indicators are required
for n=1:max(nprims,nrefprims)
    ri=[];
    i=[];
    %reference primaries first.
    if (n<=nrefprims)
        %find the specified primary
        ri=find(all(refgamut.RGB==prims(n,:)*refgamut.RGBmax,2),1);
        %if it exists
        if (~isempty(ri))
            %get the Lab values
            rlab=refgamut.LAB(ri,:);
            %calculate the nearest sRGB colour
            rcol=lab2srgb(rlab)/255;
            %calculate the end of the arrow
            rpt=rlab(2:3)*rr/norm(rlab(2:3));
            %and the hue - may be needed for the origin or a linking arc
            rhue=mod(floor(0.5+atan2(rlab(2),rlab(3))/pi*180)+719,360)+1;
            %and a mid-point - the reference arrows are only coloured at
            %their ends
            mpt=rpt*0.9;
            if (rringorigin)
                %start from the ring, so find the closest hue angle
                %and get the point on the ring
                opt=[xref(end,rhue),yref(end,rhue)];
            else
                %start from the origin
                opt=[0,0];
            end
            %plot, and make sure this line won't appear in any legend
            %first plot the grey line to the mid-point
            noLegend(plot([opt(1),mpt(1)],[opt(2),mpt(2)],'Color',[0.7,0.7,0.7]));
            %then use quiver to plot an arrow from the mid-point to the tip
            rvect=[rpt(1)-mpt(1),rpt(2)-mpt(2)];
            noLegend(quiver(mpt(1),mpt(2),rvect(1),rvect(2),'Color',rcol,'LineWidth',1.5,'MaxHeadSize',200/norm(rvect),'AutoScale','off'));
        end                        
    end
    %now do the gamut primary
    if (n<=nprims && ~(isempty(refgamut)))
        %find the primary
        i=find(all(gamut.RGB==prims(n,:)*gamut.RGBmax,2),1);
        %if it exists
        if (~isempty(i))
            %get the Lab value
            lab=gamut.LAB(i,:);
            %calculate the nearest sRGB colour
            col=lab2srgb(lab)/255;
            %calculate the end of the arrow
            pt=lab(2:3)*r/norm(lab(2:3));
            %and the hue
            hue=mod(floor(0.5+atan2(lab(2),lab(3))/pi*180)+719,360)+1;
            %and the start
            if (ringorigin)
                %from the ring
                opt=[x(end,hue),y(end,hue)];
            else
                %or from the origin
                opt=[0,0];
            end
            %plot the arrow using quiver
            vect=pt-opt;
            noLegend(quiver(opt(1),opt(2),vect(1),vect(2),'Color',col,'LineWidth',1.5,'MaxHeadSize',200/norm(vect),'AutoScale','off'));
        end        
    end
    %if there was both a test and reference primary
    if (~(isempty(refgamut) || isempty(ri) || isempty(i)))
        %make a little dotted arc to link them.
        rng=(hue:sign(rhue-hue):rhue)/180*pi;
        noLegend(plot(0.95*r*sin(rng),0.95*r*cos(rng),':k'));
    end
end

%add a little padding to the axis range
axis(axis*1.05);
%make the axes equal
axis equal
%add the title
t=sprintf('CIELab gamut rings\n%s\nVolume = %g',gamut.title, vol);
title(t);
%and the axis labels
xlabel('a^*_{RSS}')
ylabel('b^*_{RSS}')
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