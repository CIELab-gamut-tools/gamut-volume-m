import tests.*

%% IntersectGamuts function exists
assert(~isempty(which('IntersectGamuts')));

%% Intersection of gamut with itself equals original volume
gamut = SyntheticGamut('sRGB');
inter = IntersectGamuts(gamut, gamut);
vol_orig = GetVolume(gamut);
vol_inter = GetVolume(inter);
assert(almostEqual(vol_orig, vol_inter, 0.01), ...
    'Self-intersection should equal original volume');

%% sRGB intersected with BT.2020 should equal approximately sRGB
% Since sRGB is a subset of BT.2020
srgb = SyntheticGamut('sRGB');
bt2020 = SyntheticGamut('BT.2020');
inter = IntersectGamuts(srgb, bt2020);
vol_srgb = GetVolume(srgb);
vol_inter = GetVolume(inter);
% The intersection should be very close to sRGB volume
assert(almostEqual(vol_srgb, vol_inter, 0.05), ...
    sprintf('sRGB ∩ BT.2020 (%g) should ≈ sRGB (%g)', vol_inter, vol_srgb));

%% Intersection is commutative
srgb = SyntheticGamut('sRGB');
bt2020 = SyntheticGamut('BT.2020');
inter1 = IntersectGamuts(srgb, bt2020);
inter2 = IntersectGamuts(bt2020, srgb);
vol1 = GetVolume(inter1);
vol2 = GetVolume(inter2);
assert(almostEqual(vol1, vol2, 0.01), ...
    'Intersection should be commutative');

%% LCD gamut intersection with sRGB
lcd = CIELabGamut('samples/lcd.txt');
srgb = SyntheticGamut('sRGB');
inter = IntersectGamuts(lcd, srgb);
vol_lcd = GetVolume(lcd);
vol_srgb = GetVolume(srgb);
vol_inter = GetVolume(inter);
% Intersection should be smaller than or equal to both gamuts
assert(vol_inter <= vol_lcd * 1.01, 'Intersection should be <= LCD volume');
assert(vol_inter <= vol_srgb * 1.01, 'Intersection should be <= sRGB volume');
assert(vol_inter > 0, 'LCD and sRGB should have non-zero intersection');

%% Coverage percentage calculation (LCD coverage of sRGB)
lcd = CIELabGamut('samples/lcd.txt');
srgb = SyntheticGamut('sRGB');
inter = IntersectGamuts(lcd, srgb);
coverage = GetVolume(inter) / GetVolume(srgb) * 100;
% LCD should cover a reasonable percentage of sRGB
assert(coverage > 50, 'LCD should cover at least 50% of sRGB');
assert(coverage <= 100, 'Coverage cannot exceed 100%');

%% DCI-P3 intersection with sRGB
dcip3 = SyntheticGamut('DCI-P3');
srgb = SyntheticGamut('sRGB');
inter = IntersectGamuts(dcip3, srgb);
vol_inter = GetVolume(inter);
vol_srgb = GetVolume(srgb);
% Most of sRGB should be within DCI-P3
coverage = vol_inter / vol_srgb * 100;
assert(coverage > 80, 'DCI-P3 should cover most of sRGB');

%% Intersection result has correct structure
srgb = SyntheticGamut('sRGB');
bt2020 = SyntheticGamut('BT.2020');
inter = IntersectGamuts(srgb, bt2020);
assert(isfield(inter, 'Lsteps'));
assert(isfield(inter, 'hsteps'));
assert(isfield(inter, 'cylmap'));
assert(isfield(inter, 'title'));
assert(inter.Lsteps == srgb.Lsteps);
assert(inter.hsteps == srgb.hsteps);

%% Intersection title contains both gamut names
srgb = SyntheticGamut('sRGB', 'Name', 'sRGB');
bt2020 = SyntheticGamut('BT.2020', 'Name', 'BT2020');
inter = IntersectGamuts(srgb, bt2020);
assert(contains(inter.title, 'sRGB') || contains(inter.title, 'BT2020'), ...
    'Intersection title should reference source gamuts');

%% Triple intersection works
srgb = SyntheticGamut('sRGB');
dcip3 = SyntheticGamut('DCI-P3');
bt2020 = SyntheticGamut('BT.2020');
inter1 = IntersectGamuts(srgb, dcip3);
inter2 = IntersectGamuts(inter1, bt2020);
vol = GetVolume(inter2);
% Triple intersection should still have positive volume
assert(vol > 0, 'Triple intersection should have positive volume');
% Should be approximately sRGB since it's the smallest
vol_srgb = GetVolume(srgb);
assert(almostEqual(vol, vol_srgb, 0.1), ...
    'Triple intersection should be approximately sRGB');

%% Loaded gamut self-intersection
loaded = CIELabGamut('samples/sRGB.txt');
inter = IntersectGamuts(loaded, loaded);
vol_orig = GetVolume(loaded);
vol_inter = GetVolume(inter);
assert(almostEqual(vol_orig, vol_inter, 0.01), ...
    'Loaded gamut self-intersection should equal original');

%% LCD self-intersection
lcd = CIELabGamut('samples/lcd.txt');
inter = IntersectGamuts(lcd, lcd);
vol_orig = GetVolume(lcd);
vol_inter = GetVolume(inter);
assert(almostEqual(vol_orig, vol_inter, 0.01), ...
    'LCD self-intersection should equal original');
