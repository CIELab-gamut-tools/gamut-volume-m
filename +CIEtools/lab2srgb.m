function [rgb] = lab2srgb(lab)
M=[0.4124564  0.3575761  0.1804375
 0.2126729  0.7151522  0.0721750
 0.0193339  0.1191920  0.9503041]';
rgb=floor(max(0,min(1,(CIEtools.lab2xyz(lab,sum(M))/M))).^(1/2.2)*255);
end

