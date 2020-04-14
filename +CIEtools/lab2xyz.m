function [XYZ] = lab2xyz(Lab,XYZn)

fY=(Lab(:,1)+16)/116;
fX=Lab(:,2)/500+fY;
fZ=fY-Lab(:,3)/200;
f=[fX,fY,fZ];
idx = f > 6/29;
ratio=(f*3132-432)/24389;
ratio(idx) = f(idx).^3;
XYZ=ratio*diag(XYZn);
