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
git clone git@github.com:CIELab-gamut-tools/gamut-volume-m.git
```
### Without using `git`
Download the zip file with the project from [here](https://github.com/CIELab-gamut-tools/gamut-volume-m/archive/master.zip)
and unzip it into a suitable folder.  You may want to rename the unzipped folder from `gamut-volume-m-master` to `gamut-volume-m` to be consistant with the `git` instructions above. 
## Testing
To run all unit tests (contained in the `+tests` package folder), from matlab
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
### `GetVolume`
Calculates and returns the gamut volume.
```matlab
% Load reference gamut data
gamut = CIELabGamut('sRGB.txt');
% display the gamut volume
fprints('sRGB gamut volume = %g\n',GetVolume(gamut));
```
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
### `PlotVolume`
Creates a 3D surface plot of the CIELab gamut.
```matlab
% Load gamut data
gamut = CIELabGamut('sRGB.txt');
% Plot the data
figure;
PlotVolume(gamut);
```
### `PlotRings`
Creates a gamut rings plot of the CIELab gamut.
```matlab
% Load gamut data
gamut = CIELabGamut('sRGB.txt');
% Plot the data
figure;
PlotRings(gamut);
```
