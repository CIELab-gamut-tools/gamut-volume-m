import tests.*
import CIEtools.*

%% xy2XYZ function exists
assert(~isempty(which('xy2XYZ')));

%% xy2XYZ converts D65 chromaticity correctly
% D65 white point: x=0.3127, y=0.3290
xy_d65 = [0.3127, 0.3290];
XYZ = xy2XYZ(xy_d65);
% With Y=1 (default), check that Y component is 1
assert(almostEqual(XYZ(2), 1, 1e-9, 1), 'Y should be 1 by default');
% Check x+y+z = 1 relationship: X/Y = x/y, Z/Y = z/y where z = 1-x-y
expected_X = xy_d65(1) / xy_d65(2);
expected_Z = (1 - xy_d65(1) - xy_d65(2)) / xy_d65(2);
assert(almostEqual(XYZ(1), expected_X, 1e-6, 1), 'X calculation incorrect');
assert(almostEqual(XYZ(3), expected_Z, 1e-6, 1), 'Z calculation incorrect');

%% xy2XYZ with custom Y value
xy = [0.3127, 0.3290];
Y = 100;
XYZ = xy2XYZ(xy, Y);
assert(almostEqual(XYZ(2), Y, 1e-9, 1), 'Y should match input');

%% xy2XYZ works with multiple rows
xy = [0.64, 0.33; 0.3, 0.6; 0.15, 0.06]; % sRGB primaries
XYZ = xy2XYZ(xy);
assert(size(XYZ, 1) == 3, 'Should return 3 rows');
assert(size(XYZ, 2) == 3, 'Should return 3 columns');
assert(all(XYZ(:,2) == 1), 'All Y values should be 1 (default)');

%% xy2XYZ with multiple rows and custom Y values
xy = [0.64, 0.33; 0.3, 0.6; 0.15, 0.06];
Y = [0.2126; 0.7152; 0.0722]; % sRGB luminance coefficients
XYZ = xy2XYZ(xy, Y);
assert(all(almostEqual(XYZ(:,2), Y, 1e-9, 1)), 'Y values should match input');

%% sRGBgamma function exists
assert(~isempty(which('sRGBgamma')));

%% sRGBgamma returns 0 for input 0
d = sRGBgamma(0);
assert(d == 0, 'sRGBgamma(0) should be 0');

%% sRGBgamma returns 1 for input 1
d = sRGBgamma(1);
assert(almostEqual(d, 1, 1e-6, 1), 'sRGBgamma(1) should be ~1');

%% sRGBgamma linear region (v <= 0.04045)
% For small values, sRGBgamma uses linear function: d = 25*v/323
v = 0.04045;
d = sRGBgamma(v);
expected = 25 * v / 323;
assert(almostEqual(d, expected, 1e-9, 1), 'Linear region calculation incorrect');

%% sRGBgamma power region (v > 0.04045)
% For larger values: d = ((200*v+11)/211)^2.4
v = 0.5;
d = sRGBgamma(v);
expected = ((200*v+11)/211)^2.4;
assert(almostEqual(d, expected, 1e-9, 1), 'Power region calculation incorrect');

%% sRGBgamma is monotonically increasing
v = 0:0.01:1;
d = sRGBgamma(v);
assert(all(diff(d) >= 0), 'sRGBgamma should be monotonically increasing');

%% sRGBgamma works with matrices
v = [0 0.5 1; 0.25 0.75 0.1];
d = sRGBgamma(v);
assert(all(size(d) == size(v)), 'Output should match input size');

%% lab2srgb function exists
assert(~isempty(which('lab2srgb')));

%% lab2srgb returns black for L*=0
lab = [0, 0, 0];
rgb = lab2srgb(lab);
assert(all(rgb == 0), 'L*=0 should give black RGB');

%% lab2srgb returns white for L*=100 (approximately)
lab = [100, 0, 0];
rgb = lab2srgb(lab);
% Should be close to [255, 255, 255] or at least very bright
assert(all(rgb >= 250), 'L*=100 should give near-white RGB');

%% lab2srgb clips to valid range
% Out of gamut colors should be clipped to 0-255
lab = [50, 200, 200]; % Very saturated, likely out of sRGB gamut
rgb = lab2srgb(lab);
assert(all(rgb >= 0), 'RGB should be >= 0');
assert(all(rgb <= 255), 'RGB should be <= 255');

%% lab2srgb returns integers
lab = [50, 20, -30];
rgb = lab2srgb(lab);
assert(all(rgb == floor(rgb)), 'RGB values should be integers');

%% lab2srgb works with multiple rows
lab = [0 0 0; 50 0 0; 100 0 0];
rgb = lab2srgb(lab);
assert(size(rgb, 1) == 3, 'Should return 3 rows');
assert(size(rgb, 2) == 3, 'Should return 3 columns');

%% lab2srgb grey axis (a*=b*=0) gives equal RGB values
lab = [50, 0, 0];
rgb = lab2srgb(lab);
% For grey, R=G=B (or very close)
assert(all(abs(diff(rgb)) <= 1), 'Grey should have R≈G≈B');

%% Primary colors are roughly correct
% Red should have high R, low G and B
lab_red = [53, 80, 67]; % Approximate LAB for sRGB red
rgb_red = lab2srgb(lab_red);
assert(rgb_red(1) > rgb_red(2) && rgb_red(1) > rgb_red(3), 'Red should dominate');

% Green should have high G
lab_green = [88, -86, 83]; % Approximate LAB for sRGB green
rgb_green = lab2srgb(lab_green);
assert(rgb_green(2) > rgb_green(1) && rgb_green(2) > rgb_green(3), 'Green should dominate');

% Blue should have high B
lab_blue = [32, 79, -108]; % Approximate LAB for sRGB blue
rgb_blue = lab2srgb(lab_blue);
assert(rgb_blue(3) > rgb_blue(1) && rgb_blue(3) > rgb_blue(2), 'Blue should dominate');
