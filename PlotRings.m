function PlotRings(gamut, refgamut)
%GAMUTRINGS Plots a gamut rings figure from CIELab gamut data

[x,y,~,vol] = calcRings(gamut);
%plot the figure
plot(x(10:10:end,[1:end 1])',y(10:10:end,[1:end 1])','k');
hold on
%add labels for L* 10, 50 and 100
for n=[10 50 100]
    text(x(n,floor(end*15/16)),y(n,floor(end*15/16)),sprintf('L*=%d',n),'Color',[0.5,0.3,0]);
end
%add a central marker
plot(0,0,'+','MarkerSize',20);
%if a reference is supplied, add a dotted outline
if nargin>1
    [x,y] = calcRings(refgamut);
    plot(x(end,[1:end 1]),y(end,[1:end 1]),'--k');
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

function [x,y,rings,vol]=calcRings(gamut)
    dH=2*pi/gamut.hsteps;
    dL=100/gamut.Lsteps;
    %get the map of the volume in cylintrical coordinates
    volmap=cellfun(@(a) sum(a(:,1).*(a(:,2).^2)*dL*dH/2),gamut.cylmap);
    %Get the accumulated volume sum (the final row will be the total)
    %and calculate the radius required to represent that volume
    rings=(2*cumsum(volmap)/dH).^0.5;
    %Plot against the mid-point of the angle ranges
    midH=dH/2:dH:2*pi;
    x=repmat(sin(midH),gamut.Lsteps,1).*rings;
    y=repmat(cos(midH),gamut.Lsteps,1).*rings;
    vol=sum(volmap(:));
end