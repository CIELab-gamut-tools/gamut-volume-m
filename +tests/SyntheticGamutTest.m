import tests.*

%% SyntheticGamut function exists
assert(~isempty(which('SyntheticGamut')));

%% sRGB reference gamut can be created
gamut = SyntheticGamut('sRGB');
assert(isstruct(gamut));
assert(all(isfield(gamut, {'RGB', 'XYZ', 'LAB', 'TRI', 'XYZn', 'cylmap'})));

%% BT.2020 reference gamut can be created
gamut = SyntheticGamut('BT.2020');
assert(isstruct(gamut));
assert(all(isfield(gamut, {'RGB', 'XYZ', 'LAB', 'TRI', 'XYZn', 'cylmap'})));

%% DCI-P3 reference gamut can be created
gamut = SyntheticGamut('DCI-P3');
assert(isstruct(gamut));
assert(all(isfield(gamut, {'RGB', 'XYZ', 'LAB', 'TRI', 'XYZn', 'cylmap'})));

%% BT.2020 gamut volume is larger than sRGB
srgb = SyntheticGamut('sRGB');
bt2020 = SyntheticGamut('BT.2020');
vol_srgb = GetVolume(srgb);
vol_bt2020 = GetVolume(bt2020);
assert(vol_bt2020 > vol_srgb, 'BT.2020 should have larger volume than sRGB');
% BT.2020 is roughly 1.5-1.8x larger than sRGB in CIELab
assert(vol_bt2020 / vol_srgb > 2.0, 'BT.2020 should be at least 2x sRGB volume');
assert(vol_bt2020 / vol_srgb < 2.5, 'BT.2020 should be less than 2.5x sRGB volume');

%% DCI-P3 gamut volume is between sRGB and BT.2020
srgb = SyntheticGamut('sRGB');
dcip3 = SyntheticGamut('DCI-P3');
bt2020 = SyntheticGamut('BT.2020');
vol_srgb = GetVolume(srgb);
vol_dcip3 = GetVolume(dcip3);
vol_bt2020 = GetVolume(bt2020);
assert(vol_dcip3 > vol_srgb, 'DCI-P3 should be larger than sRGB');
assert(vol_dcip3 < vol_bt2020, 'DCI-P3 should be smaller than BT.2020');

%% Synthetic sRGB volume matches file-loaded sRGB volume (within tolerance)
synth = SyntheticGamut('sRGB');
loaded = CIELabGamut('samples/sRGB.txt');
vol_synth = GetVolume(synth);
vol_loaded = GetVolume(loaded);
% Allow 5% tolerance due to different sampling
assert(almostEqual(vol_synth, vol_loaded, 0.05), ...
    sprintf('Synthetic (%g) and loaded (%g) sRGB volumes should be similar', vol_synth, vol_loaded));

%% Custom RGB chromaticities can be used
% Use sRGB primaries manually
RGBxy = [.64, .33; .3, .6; .15, .06];
gamut = SyntheticGamut(RGBxy, 'D65');
assert(isstruct(gamut));
vol = GetVolume(gamut);
assert(vol > 0, 'Custom gamut should have positive volume');

%% Different white points produce different results
RGBxy = [.64, .33; .3, .6; .15, .06];
gamut_d50 = SyntheticGamut(RGBxy, 'D50');
gamut_d65 = SyntheticGamut(RGBxy, 'D65');
vol_d50 = GetVolume(gamut_d50);
vol_d65 = GetVolume(gamut_d65);
% Volumes should be different (white point affects LAB conversion)
assert(~almostEqual(vol_d50, vol_d65, 0.001), ...
    'Different white points should produce different volumes');

%% White point as xy coordinates works
RGBxy = [.64, .33; .3, .6; .15, .06];
gamut = SyntheticGamut(RGBxy, [0.3127, 0.3290]); % D65 coordinates
assert(isstruct(gamut));
vol = GetVolume(gamut);
assert(vol > 0);

%% Steps parameter affects tesselation density
gamut_10 = SyntheticGamut('sRGB', 'Steps', 10);
gamut_5 = SyntheticGamut('sRGB', 'Steps', 5);
% More steps = more RGB points
assert(size(gamut_10.RGB, 1) > size(gamut_5.RGB, 1), ...
    'Higher Steps should produce more RGB points');

%% Gamma parameter works with scalar value
gamut = SyntheticGamut('sRGB', 'Gamma', 2.2);
assert(isstruct(gamut));
vol = GetVolume(gamut);
assert(vol > 0);

%% Gamma parameter works with function
gammaFn = @(x) x.^2.4;
gamut = SyntheticGamut('sRGB', 'Gamma', gammaFn);
assert(isstruct(gamut));
vol = GetVolume(gamut);
assert(vol > 0);

%% Name parameter is stored
gamut = SyntheticGamut('sRGB', 'Name', 'Test Gamut');
assert(strcmp(gamut.title, 'Test Gamut'));

%% Reference gamuts are case-insensitive
gamut1 = SyntheticGamut('sRGB');
gamut2 = SyntheticGamut('SRGB');
gamut3 = SyntheticGamut('srgb');
vol1 = GetVolume(gamut1);
vol2 = GetVolume(gamut2);
vol3 = GetVolume(gamut3);
assert(almostEqual(vol1, vol2, 1e-9, 1));
assert(almostEqual(vol1, vol3, 1e-9, 1));

%% Model struct is stored with synthetic gamut
gamut = SyntheticGamut('sRGB');
assert(isfield(gamut, 'model'));
assert(isfield(gamut.model, 'gammaFn'));
assert(isfield(gamut.model, 'colorantXYZ'));
assert(isfield(gamut.model, 'XYZn'));
