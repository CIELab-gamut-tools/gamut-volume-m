function rings = calcGamutRings(gamut, LRings)
%CALCGAMUTRINGS Calculate gamut ring coordinates for a rings plot
%
% Syntax:
%   rings = calcGamutRings(gamut)
%   rings = calcGamutRings(gamut, LRings)
%
% Input Arguments:
%   gamut   - A gamut structure with fields: hsteps, Lsteps, cylmap
%   LRings  - Optional vector of inner L* values for rings (default: 10:10:90)
%             The outer ring at L*=100 is always included.
%
% Output:
%   rings   - A structure containing:
%     .x, .y     - Ring coordinates (nRings x hsteps matrices)
%     .r         - Ring radii (nRings x hsteps matrix)
%     .r2        - Squared radii (for area calculations)
%     .vol       - Total gamut volume
%     .volmap    - Volume per L*/hue cell (Lsteps x hsteps matrix)
%     .cumvol    - Cumulative volume by L* (Lsteps x hsteps matrix)
%     .LRings    - The inner L* values (as input, without 0 and 100)
%     .LQuery    - The full L* query values [0, LRings, 100]
%     .midH      - Mid-point hue angles in radians
%     .dH, .dL   - Step sizes for hue and L*
%     .ux, .uy   - Unit vectors for each hue angle
%
% Notes:
%   The ring radii are calculated such that the area enclosed by each ring
%   equals the cumulative gamut volume up to that L* level. Specifically:
%     area = sum(r^2 * dH / 2) = cumulative volume
%
%   This means the area of the outer ring equals GetVolume(gamut).
%
% See also PlotRings, GetVolume, CIELabGamut

if nargin < 2
    LRings = 10:10:90;
end

% Calculate step sizes
dH = 2*pi / gamut.hsteps;
dL = 100 / gamut.Lsteps;

% Calculate volume per cell in cylindrical coordinates
% Each cell contributes: parity * radius^2 * dL * dH / 2
volmap = cellfun(@(a) sum(a(:,1) .* (a(:,2).^2) * dL * dH / 2), gamut.cylmap);

% Cumulative volume (summed over L* from 0 upward)
cumvol = cumsum(volmap);

% Calculate squared radii such that area = cumulative volume
% Area of ring segment = r^2 * dH / 2, so r^2 = 2 * cumvol / dH
r2_full = 2 * cumvol / dH;

% Interpolate to get radii at the requested L* values
% Include L*=0 (radius 0) and L*=100 (outer ring)
LSteps = 0:dL:100;
LQuery = [0, LRings, 100];
r2 = interp1(LSteps, [zeros(1, gamut.hsteps); r2_full], LQuery);

% Calculate radii and coordinates
r = sqrt(r2);
midH = dH/2 : dH : 2*pi;
ux = sin(midH);
uy = cos(midH);
x = r .* ux;
y = r .* uy;

% Build output structure
rings = struct();
rings.x = x;
rings.y = y;
rings.r = r;
rings.r2 = r2;
rings.vol = sum(volmap(:));
rings.volmap = volmap;
rings.cumvol = cumvol;
rings.LRings = LRings;       % Inner L* values only (without 0 and 100)
rings.LQuery = LQuery;       % Full query values [0, LRings, 100]
rings.midH = midH;
rings.dH = dH;
rings.dL = dL;
rings.ux = ux;
rings.uy = uy;

end
