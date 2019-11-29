function [XYZ] = lab2xyz(Lab,XYZn)

fY=(Lab(:,1)+16)/116;
fX=Lab(:,2)/500+fY;
fZ=fY-Lab(:,3)/200;
f=[fX,fY,fZ];
ratio = f.^3;
idx = ratio <= 0.008856;
ratio(idx)=(f(idx)-(16/116))/7.787;
XYZ=ratio*diag(XYZn);
