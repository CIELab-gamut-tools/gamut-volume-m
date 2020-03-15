function [Lab] = XYZ2Lab(XYZ,XYZn)

%create ratio matrix
ratio = XYZ*diag(1./XYZn);

%calculate f(X/Xn),f(Y/Yn),f(Y/Yn)
fX = ratio.^(1/3);
idx = ratio <= 0.008856;
fX(idx) = ratio(idx).*7.787 + (16/116);

%calculate L*,a*,b*
Lab = [116*fX(:,2)-16, ...
       500*(fX(:,1)-fX(:,2)),...
       200*(fX(:,2)-fX(:,3))];
