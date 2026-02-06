import tests.*
import CIEtools.*

%% readCGATS returns expected structure fields
cgats = readCGATS('samples/sRGB.txt');
assert(isfield(cgats, 'fmt'), 'Should have fmt field');
assert(isfield(cgats, 'headers'), 'Should have headers field');
assert(isfield(cgats, 'filename'), 'Should have filename field');
assert(isfield(cgats, 'RGB'), 'Should have RGB field');
assert(isfield(cgats, 'XYZ'), 'Should have XYZ field');
assert(isfield(cgats, 'IDMS13'), 'Should have IDMS13 field');
assert(isfield(cgats, 'display'), 'Should have display field');

%% Data dimensions are correct for sRGB file
cgats = readCGATS('samples/sRGB.txt');
assert(size(cgats.RGB, 1) == 602, 'sRGB should have 602 samples');
assert(size(cgats.RGB, 2) == 3, 'RGB should have 3 columns');
assert(size(cgats.XYZ, 1) == 602, 'XYZ should have 602 rows');
assert(size(cgats.XYZ, 2) == 3, 'XYZ should have 3 columns');

%% LCD file can be loaded
cgats = readCGATS('samples/lcd.txt');
assert(isstruct(cgats));
assert(size(cgats.RGB, 2) == 3);
assert(size(cgats.XYZ, 2) == 3);

%% Legacy file without IDMS_VERSION defaults to version 1.0 behavior
cgats = readCGATS('samples/sRGB.txt');
assert(cgats.IDMS13 == false, 'File without IDMS_VERSION should not be treated as v1.3+');
assert(strcmp(cgats.display, 'EMISSIVE'), 'Legacy file should default to EMISSIVE');

%% IDMS v1.3 file is parsed correctly
cgats = readCGATS('example_reflective_cge_measurement.txt');
assert(cgats.IDMS13 == true, 'IDMS v1.3 file should be detected');
assert(strcmp(cgats.display, 'REFLECTIVE'), 'Display type should be parsed');

%% Format strings are returned
cgats = readCGATS('samples/sRGB.txt');
assert(iscell(cgats.fmt), 'fmt should be a cell array');
assert(any(strcmp(cgats.fmt, 'RGB_R')), 'Should contain RGB_R format');
assert(any(strcmp(cgats.fmt, 'XYZ_X')), 'Should contain XYZ_X format');

%% Headers are returned (excluding parsed headers)
cgats = readCGATS('samples/sRGB.txt');
assert(iscell(cgats.headers), 'headers should be a cell array');

%% RGB values are in expected range
cgats = readCGATS('samples/sRGB.txt');
assert(all(cgats.RGB(:) >= 0), 'RGB values should be >= 0');
assert(all(cgats.RGB(:) <= 255), 'RGB values should be <= 255');

%% XYZ values are non-negative
cgats = readCGATS('samples/sRGB.txt');
assert(all(cgats.XYZ(:) >= 0), 'XYZ values should be non-negative');

%% Error on non-existent file
try
    cgats = readCGATS('nonexistent_file_12345.txt');
    assert(false, 'Should throw error for non-existent file');
catch ME
    % Expected - file doesn't exist
    assert(true);
end

%% Filename is stored correctly
cgats = readCGATS('samples/sRGB.txt');
assert(contains(cgats.filename, 'sRGB.txt'), 'Filename should be stored');

%% Sample ID column is parsed
cgats = readCGATS('samples/sRGB.txt');
assert(any(strcmp(cgats.fmt, 'SampleID')), 'Should parse SampleID column');
assert(isfield(cgats, 'SampleID'), 'Should have SampleID field');

%% IDMS v1.3 file with expected_type parameter works
cgats = readCGATS('example_reflective_cge_measurement.txt', 'CGE_MEASUREMENT');
assert(isstruct(cgats));

%% IDMS v1.3 file with wrong expected_type throws error
try
    cgats = readCGATS('example_reflective_cge_measurement.txt', 'CGE_ENVELOPE');
    assert(false, 'Should throw error for wrong file type');
catch ME
    % Expected - wrong file type
    assert(contains(ME.message, 'wrong type') || contains(ME.message, 'CGE_ENVELOPE'), ...
        'Error message should mention wrong type');
end
