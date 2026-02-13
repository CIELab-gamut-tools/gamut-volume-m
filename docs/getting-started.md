# Getting Started

This guide walks you through installing the toolkit and performing your first gamut analysis.

## Prerequisites

You need either:
- **MATLAB** - Commercial software from [MathWorks](https://www.mathworks.com)
- **GNU Octave** - Free open source from [GNU](https://www.gnu.org/software/octave/)

## Installation

### Using Git

```bash
git clone https://github.com/CIELab-gamut-tools/gamut-volume-m.git
```

### Without Git

1. Download the [ZIP file](https://github.com/CIELab-gamut-tools/gamut-volume-m/archive/master.zip)
2. Extract to a folder of your choice

## First Steps

### 1. Add to Path

Navigate to the project folder in MATLAB/Octave, or add it to your path:

```matlab
addpath('/path/to/gamut-volume-m');
```

### 2. Load a Gamut

Load sample data using the file browser:

```matlab
gamut = CIELabGamut();
```

Or specify a file directly:

```matlab
gamut = CIELabGamut('samples/lcd.txt');
```

### 3. Create a Reference Gamut

Generate a standard reference gamut:

```matlab
srgb = SyntheticGamut('sRGB');
```

Available reference gamuts:
- `'sRGB'` - Standard RGB (web/consumer displays)
- `'BT.2020'` - Ultra HD / HDR television
- `'DCI-P3'` - Digital cinema
- `'D65-P3'` - Display P3 (Apple devices)
- `'D60-P3'` - D60 white point variant

### 4. Plot Gamut Rings

```matlab
figure;
PlotRings(gamut, srgb);
legend('LCD gamut', 'sRGB');
```

![Gamut Rings](images/basic_rings_with_reference.png)

### 5. Calculate Coverage

```matlab
% Get the intersection
intersection = IntersectGamuts(gamut, srgb);

% Calculate percentage coverage
coverage = GetVolume(intersection) / GetVolume(srgb) * 100;
fprintf('sRGB coverage: %.1f%%\n', coverage);

% Add to plot title
title(sprintf('LCD gamut - sRGB coverage: %.0f%%', coverage));
```

### 6. 3D Visualization

```matlab
figure;
PlotVolume(gamut);
```

![3D Volume](images/basic_volume_srgb.png)

## Comparing Gamuts

### Compare Two Files

```matlab
gamut1 = CIELabGamut('samples/lcd.txt');
gamut2 = CIELabGamut('samples/sRGB.txt');

vol1 = GetVolume(gamut1);
vol2 = GetVolume(gamut2);

fprintf('Gamut 1 volume: %g\n', vol1);
fprintf('Gamut 2 volume: %g\n', vol2);
fprintf('Ratio: %.2fx\n', vol1 / vol2);
```

### Compare Reference Standards

```matlab
srgb = SyntheticGamut('sRGB');
bt2020 = SyntheticGamut('BT.2020');
dcip3 = SyntheticGamut('DCI-P3');

fprintf('sRGB volume: %g\n', GetVolume(srgb));
fprintf('BT.2020 volume: %g\n', GetVolume(bt2020));
fprintf('DCI-P3 volume: %g\n', GetVolume(dcip3));
```

## Intersection Plots

Visualize where gamuts overlap:

```matlab
PlotRings(SyntheticGamut('sRGB'), SyntheticGamut('BT.2020'), ...
    'IntersectionPlot', true);
```

![Intersection Plot](images/rings_intersection_plot.png)

## Next Steps

- Learn about [PlotRings parameters](functions/PlotRings.md) for customizing visualizations
- Understand the [CGATS file format](guides/cgats-file-format.md) for preparing your data
- Explore [SyntheticGamut options](functions/SyntheticGamut.md) for custom reference gamuts

## Getting Help

Within MATLAB/Octave:

```matlab
help CIELabGamut
help PlotRings
doc CIELabGamut  % MATLAB only - opens documentation browser
```
