import tests.*
import CIEtools.*

%% calcGamutRings function exists
assert(~isempty(which('calcGamutRings')));

%% Returns correct structure fields
gamut = SyntheticGamut('sRGB');
rings = calcGamutRings(gamut);
assert(isfield(rings, 'x'), 'Should have x field');
assert(isfield(rings, 'y'), 'Should have y field');
assert(isfield(rings, 'r'), 'Should have r field');
assert(isfield(rings, 'r2'), 'Should have r2 field');
assert(isfield(rings, 'vol'), 'Should have vol field');
assert(isfield(rings, 'volmap'), 'Should have volmap field');
assert(isfield(rings, 'cumvol'), 'Should have cumvol field');
assert(isfield(rings, 'LRings'), 'Should have LRings field');
assert(isfield(rings, 'LQuery'), 'Should have LQuery field');
assert(isfield(rings, 'midH'), 'Should have midH field');
assert(isfield(rings, 'dH'), 'Should have dH field');
assert(isfield(rings, 'dL'), 'Should have dL field');
assert(isfield(rings, 'ux'), 'Should have ux field');
assert(isfield(rings, 'uy'), 'Should have uy field');

%% Default LRings is 10:10:90
gamut = SyntheticGamut('sRGB');
rings = calcGamutRings(gamut);
assert(isequal(rings.LRings, 10:10:90), 'Default LRings should be 10:10:90');
assert(isequal(rings.LQuery, [0, 10:10:90, 100]), 'LQuery should include 0 and 100');

%% Custom LRings works
gamut = SyntheticGamut('sRGB');
rings = calcGamutRings(gamut, [25, 50, 75]);
assert(isequal(rings.LRings, [25, 50, 75]), 'Custom LRings should be stored');
assert(isequal(rings.LQuery, [0, 25, 50, 75, 100]), 'LQuery should include 0 and 100');

%% Output dimensions are correct
gamut = SyntheticGamut('sRGB');
rings = calcGamutRings(gamut, 10:10:90);
nRings = 11; % 0, 10, 20, ..., 90, 100
hsteps = gamut.hsteps;
assert(size(rings.x, 1) == nRings, 'x should have nRings rows');
assert(size(rings.x, 2) == hsteps, 'x should have hsteps columns');
assert(size(rings.y, 1) == nRings, 'y should have nRings rows');
assert(size(rings.r, 1) == nRings, 'r should have nRings rows');

%% Returned volume matches GetVolume
gamut = SyntheticGamut('sRGB');
rings = calcGamutRings(gamut);
vol = GetVolume(gamut);
assert(almostEqual(rings.vol, vol, 0.001), ...
    sprintf('rings.vol (%g) should match GetVolume (%g)', rings.vol, vol));

%% Outer ring area equals total gamut volume
gamut = SyntheticGamut('sRGB');
rings = calcGamutRings(gamut);
vol = GetVolume(gamut);
% Area of outer ring = sum of pie slices = sum(r^2 * dH / 2)
outerR = rings.r(end, :);
ringArea = sum(outerR.^2 * rings.dH / 2);
assert(almostEqual(ringArea, vol, 0.001), ...
    sprintf('Outer ring area (%g) should equal volume (%g)', ringArea, vol));

%% Ring radii are monotonically increasing from center
gamut = SyntheticGamut('sRGB');
rings = calcGamutRings(gamut);
% For each hue angle, radii should increase from inner to outer
for h = 1:size(rings.r, 2)
    radii = rings.r(:, h);
    assert(all(diff(radii) >= 0), ...
        sprintf('Radii should be monotonically increasing at hue %d', h));
end

%% First ring (L*=0) has zero radius
gamut = SyntheticGamut('sRGB');
rings = calcGamutRings(gamut);
assert(all(rings.r(1, :) == 0), 'L*=0 ring should have zero radius');

%% Works with loaded gamut (sRGB file)
gamut = CIELabGamut('samples/sRGB.txt');
rings = calcGamutRings(gamut);
vol = GetVolume(gamut);
outerR = rings.r(end, :);
ringArea = sum(outerR.^2 * rings.dH / 2);
assert(almostEqual(ringArea, vol, 0.001), ...
    'Outer ring area should equal volume for loaded gamut');

%% Works with LCD gamut
lcd = CIELabGamut('samples/lcd.txt');
rings = calcGamutRings(lcd);
vol = GetVolume(lcd);
outerR = rings.r(end, :);
ringArea = sum(outerR.^2 * rings.dH / 2);
assert(almostEqual(ringArea, vol, 0.001), ...
    'Outer ring area should equal volume for LCD gamut');

%% Works with BT.2020 (larger gamut)
gamut = SyntheticGamut('BT.2020');
rings = calcGamutRings(gamut);
vol = GetVolume(gamut);
outerR = rings.r(end, :);
ringArea = sum(outerR.^2 * rings.dH / 2);
assert(almostEqual(ringArea, vol, 0.001), ...
    'Outer ring area should equal volume for BT.2020');

%% Intermediate ring areas match cumulative volume
gamut = SyntheticGamut('sRGB');
rings = calcGamutRings(gamut, 50); % Just L*=50 ring
% Ring at L*=50 should have area equal to cumulative volume up to L*=50
% The ring at index 2 is L*=50 (index 1 is L*=0, index 3 is L*=100)
r50 = rings.r(2, :);
area50 = sum(r50.^2 * rings.dH / 2);
% Get cumulative volume at L*=50 from the cumvol
L50_idx = round(50 / rings.dL);
cumvol50 = sum(rings.cumvol(L50_idx, :));
assert(almostEqual(area50, cumvol50, 0.01), ...
    sprintf('L*=50 ring area (%g) should equal cumulative volume (%g)', area50, cumvol50));

%% Unit vectors ux, uy have correct length
gamut = SyntheticGamut('sRGB');
rings = calcGamutRings(gamut);
% ux^2 + uy^2 should equal 1
magnitudes = sqrt(rings.ux.^2 + rings.uy.^2);
assert(all(almostEqual(magnitudes, 1, 1e-9, 1)), 'Unit vectors should have magnitude 1');

%% x and y are consistent with r, ux, uy
gamut = SyntheticGamut('sRGB');
rings = calcGamutRings(gamut);
% x should equal r .* ux, y should equal r .* uy
expected_x = rings.r .* rings.ux;
expected_y = rings.r .* rings.uy;
assert(almostEqual(rings.x, expected_x, 1e-9, 1), 'x should equal r .* ux');
assert(almostEqual(rings.y, expected_y, 1e-9, 1), 'y should equal r .* uy');

%% Empty LRings gives just L*=0 and L*=100 rings
gamut = SyntheticGamut('sRGB');
rings = calcGamutRings(gamut, []);
assert(size(rings.r, 1) == 2, 'Empty LRings should give 2 rings (0 and 100)');
assert(isequal(rings.LQuery, [0, 100]), 'LQuery should be [0, 100]');

%% volmap dimensions match gamut Lsteps x hsteps
gamut = SyntheticGamut('sRGB');
rings = calcGamutRings(gamut);
assert(size(rings.volmap, 1) == gamut.Lsteps, 'volmap rows should equal Lsteps');
assert(size(rings.volmap, 2) == gamut.hsteps, 'volmap cols should equal hsteps');
