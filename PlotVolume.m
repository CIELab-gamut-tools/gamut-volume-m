function PlotVolume(gamut)
%PLOTVOLUME plot a 3D CIELab gamut volume

trisurf(gamut.TRI, gamut.CIELAB(:,2),gamut.CIELAB(:,3),gamut.CIELAB(:,1),...
    'FaceVertexCData',gamut.RGB/gamut.RGBmax,'FaceColor','interp');
view([30 30]);
xlabel('CIE a^*','FontSize',14);
ylabel('CIE b^*','FontSize',14);
zlabel('CIE L^*','FontSize',14);
t=sprintf('CIELab gamut volume = %g from file "%s"\n', GetVolume(gamut),gamut.title);
title(t);
fprintf('%s\n',t);
axis equal;

end

