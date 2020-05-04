function h=PlotVolume(gamut,alpha)
%PLOTVOLUME plot a 3D CIELab gamut volume
%
% Syntax:
%   h = PlotVolume(gamut)
%   h = PlotVolume(gamut, alpha)
%
% Input arguments:
%   gamut is a gamut object returned by one of CIELabGamut or
%     SyntheticGamut. Note that objects returned by IntersectGamuts cannot
%     be plotted in this way as they do not contain surface tile data.
%   alpha is the opacity used for the faces and edges of the 3D plot.  
%
% Returned values:
%   h is the handle of the plot.
%
% Examples:
%   % Show the difference between two reference standards
%   srgb = SyntheticGamut('sRGB');
%   bt2020 = SyntheticGamut('BT.2020');
%   figure;
%   PlotVolume(srgb);
%   hold on;
%   PlotVolume(bt2020, 0.2);
%   title('Comparison of sRGB (inner) and BT.2020 (outer) CIE1931 {\itL*a*b*} Display gamuts');
%
% See also CIELabGamut, SyntheticGamut, IntersectGamuts, PlotRings, GetVolume

h=trisurf(gamut.TRI, gamut.LAB(:,2),gamut.LAB(:,3),gamut.LAB(:,1),...
    'FaceVertexCData',gamut.RGB/gamut.RGBmax,'FaceColor','interp');
if (nargin>1)
  h.FaceAlpha=alpha;
  h.EdgeAlpha=alpha;
end
view([30 30]);
xlabel('{\ita^*}');
ylabel('{\itb^*}');
zlabel('{\itL^*}');
t=sprintf('CIELab gamut volume = %g from file "%s"\n', GetVolume(gamut),gamut.title);
title(t);
axis equal;

end
