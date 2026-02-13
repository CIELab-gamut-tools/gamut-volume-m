# GetVolume

Calculate the volume of a CIELab gamut.

## Syntax

```matlab
volume = GetVolume(gamut)
```

## Description

`GetVolume` computes the gamut volume in cubic CIELab units using cylindrical integration over the gamut's internal representation.

## Input Arguments

| Argument | Description |
|----------|-------------|
| `gamut` | Gamut object from `CIELabGamut`, `SyntheticGamut`, or `IntersectGamuts` |

## Return Value

| Value | Description |
|-------|-------------|
| `volume` | Gamut volume in CIELab units (L* a* b*) |

## Examples

### Basic Volume Calculation

```matlab
gamut = CIELabGamut('samples/lcd.txt');
vol = GetVolume(gamut);
fprintf('Gamut volume: %g\n', vol);
```

### Compare Reference Gamuts

```matlab
srgb = SyntheticGamut('sRGB');
bt2020 = SyntheticGamut('BT.2020');
dcip3 = SyntheticGamut('DCI-P3');

fprintf('sRGB:    %g\n', GetVolume(srgb));
fprintf('BT.2020: %g\n', GetVolume(bt2020));
fprintf('DCI-P3:  %g\n', GetVolume(dcip3));
```

### Volume Ratio

```matlab
gamut = CIELabGamut('samples/lcd.txt');
ref = SyntheticGamut('sRGB');

ratio = GetVolume(gamut) / GetVolume(ref);
fprintf('Gamut is %.1f%% of sRGB volume\n', ratio * 100);
```

### Coverage Calculation

To calculate what percentage of a reference gamut is covered:

```matlab
gamut = CIELabGamut('samples/lcd.txt');
ref = SyntheticGamut('sRGB');

% Get the intersection
intersection = IntersectGamuts(gamut, ref);

% Coverage = intersection volume / reference volume
coverage = GetVolume(intersection) / GetVolume(ref);
fprintf('sRGB coverage: %.1f%%\n', coverage * 100);
```

## Typical Reference Volumes

| Gamut | Approximate Volume |
|-------|-------------------|
| sRGB | ~820,000 |
| DCI-P3 | ~1,030,000 |
| BT.2020 | ~1,770,000 |

*Note: Exact values depend on calculation parameters*

## Algorithm

The volume is computed by integrating over the cylindrical representation:

```
V = sum over all (L*, hue) cells of: dL * dH * r^2 / 2
```

Where:
- `dL` = L* step size (100 / Lsteps)
- `dH` = hue step size (2*pi / hsteps)
- `r` = chroma at each (L*, hue) position

## See Also

- [CIELabGamut](CIELabGamut.md) - Load gamut data
- [SyntheticGamut](SyntheticGamut.md) - Generate reference gamuts
- [IntersectGamuts](IntersectGamuts.md) - Compute gamut intersection
- [PlotRings](PlotRings.md) - Visualize gamut
