function vol = GetVolume(gamut)
%GetVolume calculate the volume of the supplied CIELab gamut
%
% Syntax:
%   volume = GetVolume(gamut)
%
% Input arguments:
%   gamut is a gamut object returned by one of CIELabGamut,
%     IntersectGamuts or SyntheticGamut.
%
% Returned values:
%   volume is the calculated gamut volume
%
% Examples:
%   % Create reference gamut data
%   gamut = SyntheticGamut('BT.2020');
%   % display the gamut volume
%   fprints('BT.2020 gamut volume = %g\n',GetVolume(gamut));
%
% See also CIELabGamut, SyntheticGamut, IntersectGamuts, PlotRings, PlotVolume

dH=2*pi/gamut.hsteps;
dL=100/gamut.Lsteps;
volmap=cellfun(@(a) sum(a(:,1).*(a(:,2).^2)*dL*dH/2),gamut.cylmap);
vol=sum(volmap(:));
end

