function [gamut] = IntersectGamuts(g1,g2)
%GAMUTINTERSECT intersects two gamuts producing a new gamut
%   gamut = IntersectGamuts(gamut1, gamut2)

if (g1.Lsteps~=g2.Lsteps || g1.hsteps~=g2.hsteps)
    error('The gamut cylindrical mappings must match');
end
gamut.Lsteps=g1.Lsteps;
gamut.hsteps=g1.hsteps;
gamut.title=[g1.title ' \cap ' g2.title];

%INTERSECTION intersects the two gamut volume objects raw1 and raw2
gamut.cylmap=cellfun(@intersect,g1.cylmap,g2.cylmap,'UniformOutput',false);

end

function [c]=intersect(a,b)
    sa=size(a,1);
    sb=size(b,1);
    c=zeros(sa+sb,4);
    if (sa==0 || sb==0), return; end
    c(1:sa,1:3)=a(:,[1 2 1]);
    c(sa+1:sa+sb,[1:2 4])=b(:,[1 2 1]);
    [~,i]=sort(c(:,2),'descend');
    t=min(cumsum(c(i,3:4)),[],2);
    c=c(i([false; diff(t)~=0]),1:2);
end

