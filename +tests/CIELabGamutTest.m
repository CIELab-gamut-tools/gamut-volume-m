import tests.*
import CIEtools.*

%% CIELabGamut function exists
assert(~isempty(which('CIELabGamut')));

%% CIELabGamut can load from file
gamut = CIELabGamut('samples/sRGB.txt');
assert(isstruct(gamut));

%% CIELabGamut accepts RGB and XYZ matrices directly
% Create simple test data - a minimal cube
RGB = [0 0 0; 255 0 0; 0 255 0; 0 0 255; 255 255 0; 255 0 255; 0 255 255; 255 255 255];
% Approximate XYZ for sRGB primaries (simplified)
XYZ = [0 0 0; 0.4124 0.2126 0.0193; 0.3576 0.7152 0.1192; 0.1805 0.0722 0.9505; ...
       0.77 0.9278 0.1385; 0.5929 0.2848 0.9698; 0.5381 0.7874 1.0697; 0.9505 1 1.089];
gamut = CIELabGamut(RGB, XYZ, 'Test Gamut');
assert(isstruct(gamut));
assert(isfield(gamut, 'RGB'));
assert(isfield(gamut, 'XYZ'));

%% Matrix input gamut has title set
RGB = [0 0 0; 255 0 0; 0 255 0; 0 0 255; 255 255 255];
XYZ = [0 0 0; 0.4 0.2 0.02; 0.35 0.7 0.12; 0.18 0.07 0.95; 0.95 1 1.09];
gamut = CIELabGamut(RGB, XYZ, 'My Custom Gamut');
assert(strcmp(gamut.title, 'My Custom Gamut'));

%% Matrix input gamut has LAB values computed
% Load reference data and use it
ref = CIELabGamut('samples/sRGB.txt');
gamut = CIELabGamut(ref.RGB, ref.XYZ_raw, 'Copy of sRGB');
assert(isfield(gamut, 'LAB'));
assert(size(gamut.LAB, 1) == size(ref.RGB, 1));
assert(size(gamut.LAB, 2) == 3);

%% Matrix input gamut has cylmap computed
ref = CIELabGamut('samples/sRGB.txt');
gamut = CIELabGamut(ref.RGB, ref.XYZ_raw, 'Copy of sRGB');
assert(isfield(gamut, 'cylmap'));
assert(size(gamut.cylmap, 1) == gamut.Lsteps);
assert(size(gamut.cylmap, 2) == gamut.hsteps);

%% Matrix input gamut has TRI (triangulation) computed
ref = CIELabGamut('samples/sRGB.txt');
gamut = CIELabGamut(ref.RGB, ref.XYZ_raw, 'Copy of sRGB');
assert(isfield(gamut, 'TRI'));
assert(size(gamut.TRI, 2) == 3, 'TRI should have 3 columns (triangle indices)');

%% Matrix input gamut volume matches file-loaded volume
ref = CIELabGamut('samples/sRGB.txt');
gamut = CIELabGamut(ref.RGB, ref.XYZ_raw, 'Copy of sRGB');
vol_ref = GetVolume(ref);
vol_gamut = GetVolume(gamut);
assert(almostEqual(vol_ref, vol_gamut, 0.01), ...
    sprintf('Matrix input volume (%g) should match file volume (%g)', vol_gamut, vol_ref));

%% Reference white point parameter overrides default
ref = CIELabGamut('samples/sRGB.txt');
custom_white = [0.9642957, 1, 0.8251046]; % D50
gamut = CIELabGamut('samples/sRGB.txt', 'reference', custom_white);
% The XYZn should be set to D50 (after scaling)
assert(almostEqual(gamut.XYZn(2), custom_white(2) * ref.XYZn(2), 0.01), ...
    'Custom reference should be used');

%% RGBmax is correctly determined
gamut = CIELabGamut('samples/sRGB.txt');
assert(isfield(gamut, 'RGBmax'));
assert(gamut.RGBmax == 255, 'RGBmax should be 255 for 8-bit data');

%% XYZn (white point) is set
gamut = CIELabGamut('samples/sRGB.txt');
assert(isfield(gamut, 'XYZn'));
assert(numel(gamut.XYZn) == 3, 'XYZn should have 3 elements');

%% XYZ_raw is preserved before chromatic adaptation
gamut = CIELabGamut('samples/sRGB.txt');
assert(isfield(gamut, 'XYZ_raw'));
assert(all(size(gamut.XYZ_raw) == size(gamut.XYZ)));

%% L* values are in expected range
gamut = CIELabGamut('samples/sRGB.txt');
% L* should be 0-100 for all points
assert(all(gamut.LAB(:,1) >= 0), 'L* should be >= 0');
assert(all(gamut.LAB(:,1) <= 100.1), 'L* should be <= 100 (with small tolerance)');

%% White point has L*=100 approximately
gamut = CIELabGamut('samples/sRGB.txt');
whiteIdx = find(all(gamut.RGB == gamut.RGBmax, 2));
if ~isempty(whiteIdx)
    whiteLAB = gamut.LAB(whiteIdx, :);
    assert(almostEqual(whiteLAB(1), 100, 0.01), 'White point L* should be ~100');
end

%% Black point has L*=0 approximately
gamut = CIELabGamut('samples/sRGB.txt');
blackIdx = find(all(gamut.RGB == 0, 2));
if ~isempty(blackIdx)
    blackLAB = gamut.LAB(blackIdx, :);
    assert(almostEqual(blackLAB(1), 0, 0.01, 1), 'Black point L* should be ~0');
end

%% Lsteps and hsteps are set to expected values
gamut = CIELabGamut('samples/sRGB.txt');
assert(gamut.Lsteps == 100, 'Lsteps should be 100');
assert(gamut.hsteps == 360, 'hsteps should be 360');

%% LCD file can be loaded and processed
lcd = CIELabGamut('samples/lcd.txt');
assert(isstruct(lcd));
assert(isfield(lcd, 'LAB'));
assert(isfield(lcd, 'cylmap'));
vol = GetVolume(lcd);
assert(vol > 0, 'LCD gamut should have positive volume');
