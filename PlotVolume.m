function PlotVolume(gamut,alph)
%PLOTVOLUME plot a 3D CIELab gamut volume

h=trisurf(gamut.TRI, gamut.CIELAB(:,2),gamut.CIELAB(:,3),gamut.CIELAB(:,1),...
    'FaceVertexCData',gamut.RGB/gamut.RGBmax,'FaceColor','interp');
if (nargin>1)
  h.FaceAlpha=alph;
  h.EdgeAlpha=alph;
end
view([30 30]);
xlabel('a^*');
ylabel('b^*');
zlabel('L^*');
t=sprintf('CIELab gamut volume = %g from file "%s"\n', GetVolume(gamut),gamut.title);
title(t);
fprintf('%s\n',t);
axis equal;

end

