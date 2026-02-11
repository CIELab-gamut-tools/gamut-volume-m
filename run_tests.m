function results = run_tests(testFolder)
%RUN_TESTS Run unit tests in MATLAB or Octave
%
% Syntax:
%   run_tests()
%   run_tests('tests')
%   results = run_tests()
%
% This function provides a simple test runner that parses test files with
% %% section markers and runs each section as a separate test. Works in
% both MATLAB and Octave.
%
% The preamble (code before the first %% section) is executed before each
% test, allowing shared constants and setup code.
%
% See also runtests (MATLAB built-in)

if nargin < 1
    testFolder = 'tests';
end

try
    import CIEtools.*;
    import tests.*;
catch
    octimport CIEtools;
    octimport tests;
end

% Find all test files
pkgPath = ['+' testFolder];
if ~exist(pkgPath, 'dir')
    error('Test folder not found: %s', pkgPath);
end

% Get list of .m files in the test folder
files = dir(fullfile(pkgPath, '*.m'));
testFiles = {files.name};

% Filter out non-test files (like almostEqual.m)
testFiles = testFiles(~strcmp(testFiles, 'almostEqual.m'));

% Initialize counters
totalPassed = 0;
totalFailed = 0;
totalTests = 0;
failedTests = {};

fprintf('\nRunning tests...\n');
fprintf('========================================\n\n');

% Process each test file
for f = 1:length(testFiles)
    filename = testFiles{f};
    filepath = fullfile(pkgPath, filename);

    fprintf('File: %s\n', filename);
    fprintf('----------------------------------------\n');

    % Read the file
    fid = fopen(filepath, 'r');
    content = fread(fid, '*char')';
    fclose(fid);

    % Split into lines
    lines = strsplit(content, '\n');

    % Parse into sections based on %% markers
    % Also capture the preamble (code before first %%) to run before each test
    sections = {};
    sectionNames = {};
    currentSection = {};
    currentName = '';
    preambleLines = {};
    inSection = false;

    for i = 1:length(lines)
        line = lines{i};

        % Skip import statements (handled globally)
        if ~isempty(regexp(line, '^\s*import\s+', 'once'))
            continue;
        end

        % Check for section marker
        if length(line) >= 2 && strcmp(line(1:2), '%%')
            % Save previous section if exists
            if inSection && ~isempty(currentSection)
                sections{end+1} = strjoin(currentSection, '\n');
                sectionNames{end+1} = currentName;
            end
            % Start new section
            currentName = strtrim(line(3:end));
            currentSection = {};
            inSection = true;
        elseif inSection
            currentSection{end+1} = line;
        else
            % Before first %% - this is preamble code
            preambleLines{end+1} = line;
        end
    end

    % Don't forget the last section
    if inSection && ~isempty(currentSection)
        sections{end+1} = strjoin(currentSection, '\n');
        sectionNames{end+1} = currentName;
    end

    % Build preamble string (constants, helper definitions, etc.)
    preamble = strjoin(preambleLines, '\n');

    % Run each section
    filePassed = 0;
    fileFailed = 0;

    for s = 1:length(sections)
        testName = sectionNames{s};
        testCode = sections{s};
        totalTests = totalTests + 1;

        try
            % Execute preamble first (constants, setup code)
            if ~isempty(preamble)
                eval(preamble);
            end
            % Execute the test code
            eval(testCode);
            fprintf('  [PASS] %s\n', testName);
            filePassed = filePassed + 1;
            totalPassed = totalPassed + 1;
        catch err
            fprintf('  [FAIL] %s\n', testName);
            fprintf('         %s\n', err.message);
            fileFailed = fileFailed + 1;
            totalFailed = totalFailed + 1;
            failedTests{end+1} = sprintf('%s: %s', filename, testName);
        end
    end

    fprintf('  (%d passed, %d failed)\n\n', filePassed, fileFailed);
end

% Print summary
fprintf('========================================\n');
fprintf('SUMMARY\n');
fprintf('========================================\n');
fprintf('Total:  %d tests\n', totalTests);
fprintf('Passed: %d\n', totalPassed);
fprintf('Failed: %d\n', totalFailed);

if totalFailed > 0
    fprintf('\nFailed tests:\n');
    for i = 1:length(failedTests)
        fprintf('  - %s\n', failedTests{i});
    end
end

fprintf('\n');

% Return results if requested
if nargout > 0
    results = struct();
    results.total = totalTests;
    results.passed = totalPassed;
    results.failed = totalFailed;
    results.failedTests = failedTests;
end

end
