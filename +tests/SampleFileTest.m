import tests.*

%% Check the loaded sample file
% check the properties are all present and are of the expected size
gamut = CIELabGamut('samples/sRGB.txt');
assert(all(isfield(gamut,{'RGB','XYZ','LAB','TRI','XYZn','Lsteps','hsteps','cylmap','RGBmax'})));
assert(all(size(gamut.RGB)==[602,3]));
assert(all(size(gamut.XYZ)==[602,3]));
assert(all(size(gamut.LAB)==[602,3]));
assert(all(size(gamut.TRI)==[1200,3]));
assert(size(gamut.cylmap,1)==gamut.Lsteps);
assert(size(gamut.cylmap,2)==gamut.hsteps);

%% Check the volume calculation
gamut = CIELabGamut('samples/sRGB.txt');
vol = GetVolume(gamut);
assert(almostEqual(vol, 830732, 0.01));

%% Check the intersection of the volume with itself
gamut = CIELabGamut('samples/sRGB.txt');
vol = GetVolume(IntersectGamuts(gamut,gamut));
assert(almostEqual(vol, 830732, 0.01));

%% test 3D plot of the volume
%(just make sure there are no assertions)
gamut = CIELabGamut('samples/sRGB.txt');
fh=figure(1);
PlotVolume(gamut);
close(fh);

%% test the rings plot
%(just make sure there are no assertions)
gamut = CIELabGamut('samples/sRGB.txt');
fh=figure(1);
PlotRings(gamut);
close(fh);