import tests.*
import CIEtools.*

%% IDMS v1.3 reflective display file can be loaded via readCGATS
cgats = readCGATS('example_reflective_cge_measurement.txt');
assert(isstruct(cgats));
assert(isfield(cgats, 'RGB'));
assert(isfield(cgats, 'XYZ'));

%% IDMS v1.3 file is detected correctly
cgats = readCGATS('example_reflective_cge_measurement.txt');
assert(isfield(cgats, 'IDMS13'));
assert(cgats.IDMS13 == true, 'IDMS v1.3 file should set IDMS13 flag to true');

%% Reflective display type is detected
cgats = readCGATS('example_reflective_cge_measurement.txt');
assert(isfield(cgats, 'display'));
assert(strcmp(cgats.display, 'REFLECTIVE'), ...
    'Reflective display file should have display type REFLECTIVE');

%% Legacy files are detected as emissive
cgats = readCGATS('samples/sRGB.txt');
assert(isfield(cgats, 'display'));
assert(strcmp(cgats.display, 'EMISSIVE'), ...
    'Legacy files should default to EMISSIVE display type');

%% Legacy files have IDMS13 flag set to false
cgats = readCGATS('samples/sRGB.txt');
assert(isfield(cgats, 'IDMS13'));
assert(cgats.IDMS13 == false, 'Legacy files should have IDMS13 flag false');

%% Reflective display can be loaded via CIELabGamut
gamut = CIELabGamut('example_reflective_cge_measurement.txt');
assert(isstruct(gamut));
assert(isfield(gamut, 'display'));
assert(strcmp(gamut.display, 'REFLECTIVE'));

%% Reflective display uses illumination white point
gamut = CIELabGamut('example_reflective_cge_measurement.txt');
% The white point should come from ILLUMINATION_PERFECT_DIFFUSE_REFLECTOR_XYZ
% which is approximately [102, 100, 63.7] in the example file
assert(isfield(gamut, 'XYZn'));
% Check that white point Y is approximately 100 (normalized)
assert(almostEqual(gamut.XYZn(2), 100, 0.05), ...
    'Reflective display white point Y should be ~100');

%% Reflective display gamut has valid volume
gamut = CIELabGamut('example_reflective_cge_measurement.txt');
vol = GetVolume(gamut);
assert(vol > 0, 'Reflective display gamut should have positive volume');

%% Reflective display has LAB values calculated
gamut = CIELabGamut('example_reflective_cge_measurement.txt');
assert(isfield(gamut, 'LAB'));
assert(size(gamut.LAB, 1) == size(gamut.RGB, 1));
assert(size(gamut.LAB, 2) == 3);
% L* should be in reasonable range (0-100 for most points)
assert(all(gamut.LAB(:,1) >= 0), 'L* values should be >= 0');
% Reflective displays may have lower max L* due to surface reflectance
assert(any(gamut.LAB(:,1) > 50), 'Should have some mid-bright L* values');

%% Reflective display can be intersected with reference gamut
gamut = CIELabGamut('example_reflective_cge_measurement.txt');
srgb = SyntheticGamut('sRGB');
inter = IntersectGamuts(gamut, srgb);
vol = GetVolume(inter);
assert(vol > 0, 'Reflective gamut should have intersection with sRGB');

%% Emissive file white point comes from max RGB
gamut = CIELabGamut('samples/sRGB.txt');
% For emissive, white point should be the XYZ at max RGB
% Find the row where RGB is all max
maxRGB = gamut.RGBmax;
whiteIdx = find(all(gamut.RGB == maxRGB, 2));
assert(~isempty(whiteIdx), 'Should find white point row');
% The XYZn should match that row
assert(almostEqual(gamut.XYZn, gamut.XYZ(whiteIdx,:), 0.001, 1), ...
    'Emissive white point should come from max RGB XYZ values');
