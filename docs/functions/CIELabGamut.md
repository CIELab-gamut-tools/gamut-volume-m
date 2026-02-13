# CIELabGamut

Build a representation of a CIELab gamut from measurement data.

## Syntax

```matlab
gamut = CIELabGamut();
gamut = CIELabGamut(filename);
gamut = CIELabGamut(filepath);
gamut = CIELabGamut(filepath, filter);
gamut = CIELabGamut(RGB, XYZ, title);
gamut = CIELabGamut(___, 'parameter', value, ...);
```

## Description

`CIELabGamut` creates a gamut data structure from either a CGATS data file or supplied RGB/XYZ matrices. The function:

1. Loads RGB and XYZ data
2. Chromatically adapts XYZ to D50 using Bradford chromatic adaptation
3. Creates a standard surface tessellation of the RGB data
4. Converts to CIELab color space
5. Calculates a cylindrical representation for volume computation

## Input Arguments

| Argument | Description |
|----------|-------------|
| *(none)* | Opens file browser to select a CGATS file |
| `filename` | Path to a CGATS.17 file |
| `filepath` | Directory path; opens browser starting at this location |
| `filter` | File pattern for browser (e.g., `'*.cgats'`) |
| `RGB` | Matrix of RGB triplets (N x 3) |
| `XYZ` | Matrix of XYZ tristimulus values (N x 3) |
| `title` | Name for the gamut (used in plot titles) |

## Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `reference` | White point XYZ values (3-element vector). If empty, uses R=G=B=max point for emissive displays, or reads from `ILLUMINATION_PERFECT_DIFFUSE_REFLECTOR_XYZ` header for reflective displays. | `[]` |

## Return Value

Returns a gamut structure containing:

| Field | Description |
|-------|-------------|
| `RGB` | Original RGB values |
| `XYZ` | Chromatically adapted XYZ values |
| `XYZ_raw` | Original XYZ values before adaptation |
| `LAB` | CIELab values |
| `TRI` | Surface tessellation indices |
| `XYZn` | White point (D50 adapted) |
| `RGBmax` | Maximum RGB value in data |
| `title` | Gamut name |
| `cylmap` | Cylindrical map for volume calculation |
| `Lsteps` | Number of L* steps (100) |
| `hsteps` | Number of hue steps (360) |

## Examples

### Browse for a File

```matlab
gamut = CIELabGamut();
```

### Load from Specific File

```matlab
gamut = CIELabGamut('samples/lcd.txt');
```

### Browse from Specific Directory

```matlab
gamut = CIELabGamut('/path/to/measurements/', '*.txt');
```

### Create from Matrix Data

```matlab
% RGB values (0-255 scale)
RGB = [0 0 0; 255 0 0; 0 255 0; 0 0 255; 255 255 255; ...];

% Corresponding XYZ measurements
XYZ = [0.5 0.5 0.5; 41.2 21.3 1.9; 35.8 71.5 11.9; ...];

gamut = CIELabGamut(RGB, XYZ, 'My Display');
```

### Specify Custom White Reference

```matlab
% Use a specific white point XYZ
gamut = CIELabGamut('measurement.txt', 'reference', [95.047 100 108.883]);
```

## File Format

The preferred input format is ASCII CGATS.17. See [CGATS File Format](../guides/cgats-file-format.md) for details.

### Required Columns

- `RGB_R`, `RGB_G`, `RGB_B` - Signal levels
- `XYZ_X`, `XYZ_Y`, `XYZ_Z` - Measured tristimulus values

### Reflective Displays (IDMS v1.3)

For reflective displays, the file must include:
- `CGV_DISPLAY_TYPE REFLECTIVE` header
- `ILLUMINATION_PERFECT_DIFFUSE_REFLECTOR_XYZ` header with white point

## Notes

- XYZ data is always chromatically adapted to D50
- The RGB cube must be fully sampled (all edge points required)
- Missing RGB combinations will produce an error

## See Also

- [SyntheticGamut](SyntheticGamut.md) - Generate reference gamuts
- [GetVolume](GetVolume.md) - Calculate volume
- [PlotRings](PlotRings.md) - 2D visualization
- [PlotVolume](PlotVolume.md) - 3D visualization
- [CGATS File Format](../guides/cgats-file-format.md)
