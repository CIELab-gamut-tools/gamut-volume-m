function PlotRings(gamut, varargin)
%GAMUTRINGS Plots a gamut rings figure from CIELab gamut data

p = inputParser;
validGamut = @(x) all(isfield(x,{'hsteps','Lsteps','title','cylmap'}));
addRequired(p,'gamut',validGamut);
addOptional(p,'ref',[],validGamut);
addParameter(p,'ShowBands',true,@islogical);
addParameter(p,'BandChroma',50,@isscalar);
addParameter(p,'BandLs',20:70/9:90,@isnumeric);
addParameter(p,'RingReference','none',@(x) any(validatestring(x,{'none','intersection','ref'},'PlotRings')));
addParameter(p,'LLabelIndices',[1,5],@isnumeric);
addParameter(p,'LLabelColors','default',@(x) strcmp(x,'default') || isnumeric(x));
addParameter(p,'LRings',10:10:100,@isnumeric);
addParameter(p,'ShowCentMark',true,@islogical);
addParameter(p,'CentMarkSize',20,@isscalar);
addParameter(p,'CentMark','+k',@ischar);
addParameter(p,'RingLine','k',@ischar);
addParameter(p,'RefLine','--k',@ischar);
addParameter(p,'ChromaRing',1000,@isnumeric);
addParameter(p,'ShowPrimaries',true,@islogical);
parse(p,gamut,varargin{:});

refgamut = p.Results.ref;
lrings = p.Results.LRings;

[x,y,~,vol] = calcRings(gamut,lrings);

clf;
%plot the figure
if (~strcmp(p.Results.RingLine,''))
    plot(x(:,[1:end 1])',y(:,[1:end 1])',p.Results.RingLine);
else
    box on;
end
hold on

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
    plot(xd(:,[1:end 1])',yd(:,[1:end 1])',p.Results.RefLine);
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
        trisurf(TRI,xc,yc,zeros(lim,1)-1,...
            'EdgeColor','none',...
            'FaceVertexCData',rgb,...
            'FaceColor','interp');
    end
end

%add labels for L* 10, 50 and 100
for n=1:numel(p.Results.LLabelIndices)
    if strcmp(p.Results.LLabelColors,'default')
        cols=(p.Results.LLabelIndices(:)<numel(lrings))*[1,1,1];
    else
        cols=ones(numel(p.Results.LLabelIndices),1)*p.Results.LLabelColors;
    end
    i=p.Results.LLabelIndices(n);
    text(x(i+1,floor(end*15/16)),y(i+1,floor(end*15/16)),sprintf('L*=%d',lrings(i)),'Color',cols(n,:),'FontWeight','demi');
end
%add a central marker
if p.Results.ShowCentMark
    plot(0,0,p.Results.CentMark,'MarkerSize',p.Results.CentMarkSize);
end
%if a reference is supplied, add a dotted outline
if ~isempty(refgamut)
    [xref,yref] = calcRings(refgamut,lrings);
    plot(xref(end,[1:end 1]),yref(end,[1:end 1]),p.Results.RefLine);
end
if (p.Results.ChromaRing>0)
    r=p.Results.ChromaRing;
    plot(r*sin(0:pi/200:2*pi),r*cos(0:pi/200:2*pi),'Color',[0.7,0.7,0.7]);
end
if (p.Results.ShowPrimaries)
    %get the Lab colours of the primaries
    prims=[1,0,0;1,1,0;0,1,0;0,1,1;0,0,1;1,0,1]*gamut.RGBmax;
    r=p.Results.ChromaRing;
    for n=1:6
        rgb=prims(n,:);
        if (~isempty(refgamut))
            ri=find(all(refgamut.RGB==rgb,2),1);
            if (~isempty(ri))
                rlab=refgamut.CIELAB(ri,:);
                rcol=lab2srgb(rlab)/255;
                rpt=rlab(2:3)*r/norm(rlab(2:3));
                mpt=rpt*0.9;
                rhue=mod(fix(atan2(rlab(2),rlab(3))/pi*180)+719,360)+1;
                plot([xref(end,rhue),mpt(1)],[yref(end,rhue),mpt(2)],'Color',[0.7,0.7,0.7]);
                rvect=[rpt(1)-mpt(1),rpt(2)-mpt(2)];
                quiver(mpt(1),mpt(2),rvect(1),rvect(2),'Color',rcol,'LineWidth',1.5,'MaxHeadSize',200/norm(rvect),'AutoScale','off');
            end                
        end
        i=find(all(gamut.RGB==rgb,2),1);
        if (~isempty(i))
            lab=gamut.CIELAB(i,:);
            col=lab2srgb(lab)/255;
            pt=lab(2:3)*r*.95/norm(lab(2:3));
            hue=mod(fix(atan2(lab(2),lab(3))/pi*180)+719,360)+1;
            vect=[pt(1)-x(end,hue),pt(2)-y(end,hue)];
            quiver(x(end,hue),y(end,hue),vect(1),vect(2),'Color',col,'LineWidth',1.5,'MaxHeadSize',200/norm(vect),'AutoScale','off');
        end
        if (~(isempty(refgamut) || isempty(ri) || isempty(i)))
            rng=(hue:sign(rhue-hue):rhue)/180*pi;
            plot(0.95*r*sin(rng),0.95*r*cos(rng),':k');
        end
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
    rings=interp1([0 1:100/gamut.Lsteps:100],[zeros(1,gamut.hsteps);(2*cumsum(volmap)/dH).^0.5],[0 LRings]);
    %Plot against the mid-point of the angle ranges
    midH=dH/2:dH:2*pi;
    x=repmat(sin(midH),numel(LRings)+1,1).*rings;
    y=repmat(cos(midH),numel(LRings)+1,1).*rings;
    vol=sum(volmap(:));
end