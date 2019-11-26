function vol = GetVolume(gamut)
%CIELABVOLUME calculate the volume of the supplied CIELab gamut
%   vol = GetVolume(gamut)

dH=2*pi/gamut.hsteps;
dL=100/gamut.Lsteps;
volmap=cellfun(@(a) sum(a(:,1).*(a(:,2).^2)*dL*dH/2),gamut.cylmap);
vol=sum(volmap(:));
end

