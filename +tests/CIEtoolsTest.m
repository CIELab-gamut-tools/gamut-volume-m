import tests.*
import CIEtools.*
D50 = [0.9642957, 1, 0.8251046];

%% check almost equal
assert(almostEqual([99,0,0],[100,0,0],0.02));
assert(almostEqual([0,0,0],0,1e-9,1));

%% check xyz2lab is defined
assert(~isempty(which('xyz2lab')))

%% xyz2lab should return 100,0,0 for the reference white
XYZn=D50;
lab=xyz2lab(XYZn,XYZn);
assert(almostEqual(lab,[100,0,0],1e-9,1));

%% for any grey input, a* and b* should be zero
XYZn=D50;
XYZ=(0:0.01:1)'*XYZn;
lab=xyz2lab(XYZ,XYZn);
assert(almostEqual(lab(:,2:3),0,1e-9,1));

%% for XYZ = 216/3132 of XYZn, lab=[8,0,0]
XYZn=D50;
XYZ=XYZn*216/24389;
lab=xyz2lab(XYZ,XYZn);
assert(almostEqual(lab,[8,0,0],1e-9,1));

%% for XYZ < 216/3132 of XYZn, lab scales linearly to 8
XYZn=D50;
XYZ=(0:0.125:1)'*XYZn*216/24389;
lab=xyz2lab(XYZ,XYZn);
assert(almostEqual(lab,[(0:8)',zeros(9,2)],1e-9,1));

%% check lab2xyz is defined
assert(~isempty(which('lab2xyz')));

%% check random XYZ values return after xyz=>lab=>xyz
XYZn=0.8+0.4*rand(1,3);
XYZ=rand(100,3).*XYZn;
lab=xyz2lab(XYZ,XYZn);
XYZr=lab2xyz(lab,XYZn);
assert(almostEqual(XYZ,XYZr,1e-9,1e-2));

%% check camcat_cc is defined
assert(~isempty(which('camcat_cc')));

%% check that a random set of xyz values are returned when the white points are the same
XYZn=0.8+0.4*rand(1,3);
XYZ=rand(100,3).*XYZn;
XYZr=camcat_cc(XYZ,XYZn,XYZn);
assert(almostEqual(XYZ,XYZr,1e-9,1e-2));

%% check that a white point is correctly converted
XYZn=0.8+0.4*rand(1,3);
XYZa=0.8+0.4*rand(1,3);
XYZr=camcat_cc(XYZn,XYZn,XYZa);
assert(almostEqual(XYZa,XYZr,1e-9,1e-2));

%% check map_rows exists
assert(~isempty(which('map_rows')));

%% check rows are mapped as expected
% make a list of random rows (use integers)
irows = unique(floor(100*rand(100,3)),'rows');
% make a random permutation vector
[~,p] = sort(rand(size(irows,1),1));
% then get map_rows to return the same permutation vector
pr = map_rows(irows(p,:),irows);
assert(all(p==pr));

%% check readCGATS exists
assert(~isempty(which('readCGATS')));

%% read the sRGB.tst test file and check the correct fields are present
cgats=readCGATS('samples\sRGB.txt');
assert(all(isfield(cgats,{'RGB','XYZ','filename'})));
assert(all(size(cgats.RGB)==[602,3]));
assert(all(size(cgats.XYZ)==[602,3]));



