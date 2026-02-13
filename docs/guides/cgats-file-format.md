# CGATS File Format Guide

This toolkit uses the ASCII CGATS.17 file format for gamut measurement data. This guide covers both standard CGATS files and the extended IDMS v1.3 format for reflective displays.

## Basic Structure

A CGATS file consists of:
1. Header section with metadata
2. Data format definition
3. Data table

### Minimal Example

```
CGATS.17
NUMBER_OF_FIELDS 7
BEGIN_DATA_FORMAT
SampleID RGB_R RGB_G RGB_B XYZ_X XYZ_Y XYZ_Z
END_DATA_FORMAT
NUMBER_OF_SETS 3
BEGIN_DATA
1 0 0 0 0.5 0.5 0.5
2 255 0 0 41.2 21.3 1.9
3 255 255 255 95.0 100.0 108.9
END_DATA
```

## Required Elements

### CGATS Version Header

First line must specify CGATS.17:

```
CGATS.17
```

### Data Format Definition

Columns must be defined between `BEGIN_DATA_FORMAT` and `END_DATA_FORMAT`:

```
BEGIN_DATA_FORMAT
SampleID RGB_R RGB_G RGB_B XYZ_X XYZ_Y XYZ_Z
END_DATA_FORMAT
```

### Required Columns

| Column | Description |
|--------|-------------|
| `RGB_R` | Red signal level (0-255 typical) |
| `RGB_G` | Green signal level |
| `RGB_B` | Blue signal level |
| `XYZ_X` | CIE 1931 X tristimulus |
| `XYZ_Y` | CIE 1931 Y tristimulus |
| `XYZ_Z` | CIE 1931 Z tristimulus |

`SampleID` is optional but recommended.

### Number of Sets

Must match the actual row count:

```
NUMBER_OF_SETS 602
```

### Data Section

Tab or space-separated values between `BEGIN_DATA` and `END_DATA`:

```
BEGIN_DATA
1 0 0 0 0.747 0.724 1.639
2 0 0 25 1.393 0.970 5.157
...
END_DATA
```

## Optional Headers

Common metadata headers (informational only):

```
FORMAT_VERSION 2
CREATED 2017-10-17 15:05:08 UTC+9
PRODUCT MOBILE PHONE
DISPLAY_TYPE RGBW LCD
INSTRUMENT Konica-Minolta CA-410
SYNC_MODE INT 60 Hz
MEASUREMENT_SPEED FAST
AVERAGING_TIMES 5
AMBIENT_TEMPERATURE 24
```

## RGB Sampling Requirements

The RGB cube must be fully sampled. A typical 11-step sampling (0, 25, 51, 76, 102, 127, 153, 178, 204, 229, 255) produces:

- 6 faces x 11 x 11 points = 726 surface points
- Minus 12 edge duplicates = 602 unique points

All edges of the RGB cube must be represented.

## IDMS v1.3 Format (Reflective Displays)

For reflective displays that depend on ambient illumination, use the IDMS v1.3 extended format.

### Additional Required Headers

```
IDMS_VERSION 1.3
FORMAT_VERSION 2
IDMS_FILE_TYPE CGE_MEASUREMENT
CGV_DISPLAY_TYPE REFLECTIVE
ILLUMINATION_PERFECT_DIFFUSE_REFLECTOR_XYZ 102 100 63.7
```

| Header | Description |
|--------|-------------|
| `IDMS_VERSION` | Must be 1.3 or higher |
| `FORMAT_VERSION` | Must be 2 |
| `IDMS_FILE_TYPE` | `CGE_MEASUREMENT` or `CGE_ENVELOPE` |
| `CGV_DISPLAY_TYPE` | `EMISSIVE` or `REFLECTIVE` |
| `ILLUMINATION_PERFECT_DIFFUSE_REFLECTOR_XYZ` | White point XYZ for reflective displays |

### Optional IDMS Headers

```
DISPLAY_MFR DisplayCo
DISPLAY_MODEL DC-1
DISPLAY_SERIAL AA1234567890
DISPLAY_MODE ModeName
ORIGINATOR LabCo
EXPERIMENTER Firstname Lastname
FILE_CREATED Tuesday, February 2, 2024, 10:55:40 AM
INSTRUMENT Instrument model
INSTRUMENT_SN IN1234567890
CIE_OBSERVER 1931
CIE_OBSERVER_ANGLE 2
ILLUMINATION_TYPE_NAME Indoor, normalized to Yn
ILLUMINATION_DIRECT_XYZ 110 100 35.5
ILLUMINATION_HEMISPHERE_XYZ 96.4 100 82.5
```

### Complete IDMS v1.3 Example

```
CGATS.17
FORMAT_VERSION 2
IDMS_FILE_TYPE CGE_MEASUREMENT
IDMS_VERSION 1.3
CGV_DISPLAY_TYPE REFLECTIVE
DISPLAY_MFR DisplayCo
DISPLAY_MODEL DC-1
ILLUMINATION_TYPE_NAME Indoor, normalized to Yn
ILLUMINATION_PERFECT_DIFFUSE_REFLECTOR_XYZ 102 100 63.7
KEYWORD SampleID
NUMBER_OF_FIELDS 7
BEGIN_DATA_FORMAT
SampleID RGB_R RGB_G RGB_B XYZ_X XYZ_Y XYZ_Z
END_DATA_FORMAT
NUMBER_OF_SETS 602
BEGIN_DATA
1 0 0 0 3.90 4.51 4.08
2 0 0 25 3.92 4.51 4.16
...
END_DATA
```

## White Point Handling

### Emissive Displays

For emissive displays (the default), the white point is automatically detected as the XYZ value at RGB = (max, max, max).

### Reflective Displays

For reflective displays, the white point is read from the `ILLUMINATION_PERFECT_DIFFUSE_REFLECTOR_XYZ` header. This represents the XYZ of a perfect diffuse reflector under the measurement illumination.

### Manual Override

You can override the automatic white point detection:

```matlab
gamut = CIELabGamut('file.txt', 'reference', [95.047 100 108.883]);
```

## Chromatic Adaptation

All XYZ data is chromatically adapted to D50 using the Bradford transform before conversion to CIELab. This ensures consistent volume calculations regardless of the original white point.

## Troubleshooting

### "Missing RGB data" Error

This occurs when required RGB combinations are missing. Ensure all surface points of the RGB cube are included.

### "Invalid CGATS file" Error

Check that:
- First line is `CGATS.17`
- `BEGIN_DATA_FORMAT` and `END_DATA_FORMAT` are present
- `BEGIN_DATA` and `END_DATA` are present
- `NUMBER_OF_SETS` matches actual data rows

### "NUMER_OF_SETS does not match" Error

The value in `NUMBER_OF_SETS` must exactly match the number of data rows.

## Sample Files

The toolkit includes sample files in the `samples/` directory:

| File | Description |
|------|-------------|
| `lcd.txt` | Standard LCD display measurement |
| `sRGB.txt` | sRGB reference gamut |

And in the root directory:

| File | Description |
|------|-------------|
| `example_reflective_cge_measurement.txt` | IDMS v1.3 reflective display example |
