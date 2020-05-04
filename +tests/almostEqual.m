function r = almostEqual(a,b,tol,mn)
if (nargin<4), mn=1e-6; end
% check a and b are within the tolerance
r = all(abs((a-b)./(a+b+mn))<=tol*0.5);
% ensure reduction to a scalar
while (~isscalar(r)), r=all(r); end
end

