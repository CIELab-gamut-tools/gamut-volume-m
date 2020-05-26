# gamut-volume-m
CIELab gamut volume calculation and visualisation in matlab/octave
## Installing pre-requisites
### Matlab / Octave
To use this code you need _either_ Matlab or Octave installed.  Matlab is commercial software and can be obtained from the [Mathworks Website](https://www.mathworks.com).
GNU/Octave is free open source software which can be downloaded from [the GNU website](https://www.gnu.org/software/octave/). 
### GIT
Optionally, if you would like to contribute to this project, you will also need a GIT client.  For Linux or MacOS it will already be installed, for windows you can install the [git-scm](https://git-scm.com/) client.
Other git clients are also available if preferred, a full list can be found [here](https://git-scm.com/download/gui/windows).
## Installation
### Using `git`
From a suitable containing folder:
```bash
git clone https://github.com/CIELab-gamut-tools/gamut-volume-m.git
```
### Without using `git`
Download the zip file with the project from [here](https://github.com/CIELab-gamut-tools/gamut-volume-m/archive/master.zip)
and unzip it into a suitable folder.  You may want to rename the unzipped folder from `gamut-volume-m-master` to `gamut-volume-m` to be consistant with the `git` instructions above. 
## Testing
To run all unit tests (contained in the `+tests` package folder), navigate to the project folder from within matlab, then:
```matlab
runtests('tests');
```
## Use

### `CIELabGamut`
The `CIELabGamut` function creates a gamut data structure from either supplied matrix data or from a CGATS data file.
This gamut volume code is simplest to use with the standard ASCII CGATS.17 file format and this is recommended.

The `CIELabGamut` function does the following:
- Loads the `RGB` and `XYZ` data.
- Chromatically adapts the `XYZ` data to a D50 reference using [Bradford chromatic adaptation](http://www.brucelindbloom.com/index.html?Eqn_ChromAdapt.html).
- Forms a standard surface tesselation of the RGB data
- Calculates the CIELab data from the `XYZ` data.
- Calculates a cylindrical representation of the CIELab data which is then used by all other included functions.

The following are examples of use of the `CIELabGamut` function
```matlab
% Browse for a file
gamut = CIELabGamut();
% Browse for a file from a particular location
gamut = CIELabGamut('/path/to/folder','*.cgats');
% Load data from a particular file
gamut = CIELabGamut('sRGB.txt');
% Initialise data from supplied matrices
gamut = CIELabGamut(RGB, XYZ, 'simulated gamut');
```
see more detailed help within Matlab/Octave using `help CIELabGamut` or `doc CIELabGamut` (Matlab only) from within the project folder.

### `SyntheticGamut`
Creates a synthetic display gamut either from a standard reference or from supplied data.
```matlab
% Compare the gamut volumes of BT2020 and sRGB
sRGBvol = GetVolume(SyntheticGamut('sRGB'));
BT2020vol = GetVolume(SyntheticGamut('BT.2020'));
r = BT2020vol/sRGBvol;
sprintf('The BT2020 gamut volume is %gx that of sRGB\n', r);

% Assess the impact of white point selection on a gamut volume
D50gmt = SyntheticGamut([.68,.32;.265,.69;.15,.06],'D50');
D65gmt = SyntheticGamut([.68,.32;.265,.69;.15,.06],'D65');
sprintf('Gamut assuming a D50 white point is %g\n',GetVolume(D50gmt));
sprintf('Gamut assuming a D65 white point is %g\n',GetVolume(D65gmt));

% Assess the impact on gamut volume of the use of a white boosted RGBW
for wb=0:0.25:1
  mapping = @(s) [s, wb*min(s,[],2)];
  gamut = SyntheticGamut([.64,.33;.3,.6;.15,.06], mapping);
  sprintf('Gamut volume with %g%% white boost is %g\n',...
    wb*100, GetVolume(gamut));
end
```
see more detailed help within Matlab/Octave using `help SyntheticGamut` or `doc SyntheticGamut` (Matlab only) from within the project folder.

### `GetVolume`
Calculates and returns the gamut volume.
```matlab
% Load reference gamut data
gamut = CIELabGamut('sRGB.txt');
% display the gamut volume
fprints('sRGB gamut volume = %g\n',GetVolume(gamut));
```
see more detailed help within Matlab/Octave using `help GetVolume` or `doc GetVolume` (Matlab only) from within the project folder.

### `IntersectGamuts`
Calculates the intersection of two gamut volumes.  The resultant data can be used
for volume calculation and plotting the gamut rings but not 3D gamut visualisation.
```matlab
% Load test and reference gamut data
gamut = CIELabGamut('laser.txt');
ref = CIELabGamut('sRGB.txt');
% calculate the intersection
igamut = IntersectGamuts(gamut,ref);
% display the intersected gamut volume
fprints('sRGB gamut volume = %g\n',GetVolume(igamut));
```
see more detailed help within Matlab/Octave using `help IntersectGamuts` or `doc IntersectGamuts` (Matlab only) from within the project folder.

### `PlotVolume`
Creates a 3D surface plot of the CIELab gamut.
```matlab
% Load gamut data
gamut = CIELabGamut('sRGB.txt');
% Plot the data
figure;
PlotVolume(gamut);
```
see more detailed help within Matlab/Octave using `help PlotVolume` or `doc PlotVolume` (Matlab only) from within the project folder.

### `PlotRings`
Creates a gamut rings plot of the CIELab gamut.
```matlab
% A simple rings plot with a reference
sRGB = CIELabGamut('sRGB.txt');
gamut = CIELabGamut('sampleGamut.txt');
figure;
PlotRings(gamut, sRGB);
% The same figure showing the difference in the primary colours
figure;
PlotRings(gamut, sRGB,... 
  'LLabelIndices',[], ... %Turn of the label indices
  'RingReference','intersection', ... %Show, per ring, the intersection
  'ChromaRing',1000, ... %Show a ring of constant chroma
  'Primaries','all', ... %Show all primaries - RGBCMY
  'RefPrimaries','all'); %And the reference primaries
```
see more detailed help within Matlab/Octave using `help PlotRings` or `doc PlotRings` (Matlab only) from within the project folder.
