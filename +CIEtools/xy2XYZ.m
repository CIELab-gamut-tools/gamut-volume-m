function [XYZ] = xy2XYZ(xy,Y)
%XY2XYZ Convert xy chromaticities to XYZ tristimulous values
%
% Syntax:
%  XYZ = xy2XYZ(xy);
%  XYZ = xy2XYZ(xy,Y);
%
if (nargin<2), Y=1; end
XYZ = [xy,1-sum(xy,2)].*repmat(Y./xy(:,2),1,3);
end

