function generate_docs_images()
%GENERATE_DOCS_IMAGES Generate documentation images for the gamut-volume-m toolkit
%
% This script generates all images used in the documentation.
% Run this script from the project root directory.
%
% Output: 20 PNG files in docs/images/
%
% Usage:
%   generate_docs_images()

% Ensure we're in the right directory
if ~exist('CIELabGamut.m', 'file')
    error('Please run this script from the gamut-volume-m root directory');
end

% Create output directory if it doesn't exist
outputDir = fullfile('docs', 'images');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Set figure defaults for consistent output
set(0, 'DefaultFigureColor', 'white');

fprintf('Generating documentation images...\n');

% Load sample gamut for examples
lcd = CIELabGamut('samples/lcd.txt');

% Create reference gamuts
srgb = SyntheticGamut('sRGB');
bt2020 = SyntheticGamut('BT.2020');
dcip3 = SyntheticGamut('DCI-P3');

% ========== BASIC IMAGES (1-5) ==========

% 1. basic_rings_single.png - Single gamut
fprintf('  1/20: basic_rings_single.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 600 500]);
PlotRings(srgb);
title('sRGB Gamut Rings');
saveFigure(fig, fullfile(outputDir, 'basic_rings_single.png'));

% 2. basic_rings_with_reference.png - Gamut vs sRGB
fprintf('  2/20: basic_rings_with_reference.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 600 500]);
PlotRings(lcd, srgb);
legend('LCD', 'sRGB', 'Location', 'northeast');
title('LCD vs sRGB Reference');
saveFigure(fig, fullfile(outputDir, 'basic_rings_with_reference.png'));

% 3. basic_volume_srgb.png - 3D volume
fprintf('  3/20: basic_volume_srgb.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 600 500]);
PlotVolume(srgb);
title('sRGB 3D Gamut Volume');
saveFigure(fig, fullfile(outputDir, 'basic_volume_srgb.png'));

% 4. volume_comparison.png - Overlaid sRGB/BT.2020
fprintf('  4/20: volume_comparison.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 600 500]);
PlotVolume(srgb);
hold on;
PlotVolume(bt2020, 0.2);
title('sRGB (inner) vs BT.2020 (outer)');
legend('sRGB', 'BT.2020', 'Location', 'northeast');
saveFigure(fig, fullfile(outputDir, 'volume_comparison.png'));

% 5. synthetic_gamuts_comparison.png - sRGB, BT.2020, DCI-P3 side-by-side
fprintf('  5/20: synthetic_gamuts_comparison.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 900 300]);
subplot(1, 3, 1);
PlotRings(srgb);
title('sRGB');
subplot(1, 3, 2);
PlotRings(dcip3);
title('DCI-P3');
subplot(1, 3, 3);
PlotRings(bt2020);
title('BT.2020');
saveFigure(fig, fullfile(outputDir, 'synthetic_gamuts_comparison.png'));

% ========== PLOTRINGS PARAMETERS (6-17) ==========

% 6. rings_lrings_custom.png - Custom L* values
fprintf('  6/20: rings_lrings_custom.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 600 500]);
PlotRings(srgb, 'LRings', [25, 50, 75]);
title('Custom L* Rings: [25, 50, 75]');
saveFigure(fig, fullfile(outputDir, 'rings_lrings_custom.png'));

% 7. rings_llabel_customization.png - Label colors
fprintf('  7/20: rings_llabel_customization.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 600 500]);
PlotRings(srgb, 'LLabelIndices', 1:10, 'LLabelColors', 'blue');
title('All Rings Labeled in Blue');
saveFigure(fig, fullfile(outputDir, 'rings_llabel_customization.png'));

% 8. rings_line_styles.png - Line style options
fprintf('  8/20: rings_line_styles.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 600 500]);
PlotRings(lcd, srgb, 'RingLine', 'b', 'RefLine', '--r');
legend('LCD (blue)', 'sRGB (red dashed)', 'Location', 'northeast');
title('Custom Line Styles');
saveFigure(fig, fullfile(outputDir, 'rings_line_styles.png'));

% 9. rings_intersection_plot.png - IntersectionPlot mode
fprintf('  9/20: rings_intersection_plot.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 600 500]);
PlotRings(srgb, bt2020, 'IntersectionPlot', true);
title('Intersection Plot: sRGB vs BT.2020');
saveFigure(fig, fullfile(outputDir, 'rings_intersection_plot.png'));

% 10. rings_ring_reference_modes.png - 3-panel: none/intersection/ref
fprintf('  10/20: rings_ring_reference_modes.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 900 300]);
subplot(1, 3, 1);
PlotRings(lcd, srgb, 'RingReference', 'none');
title('RingReference: none');
subplot(1, 3, 2);
PlotRings(lcd, srgb, 'RingReference', 'intersection');
title('RingReference: intersection');
subplot(1, 3, 3);
PlotRings(lcd, srgb, 'RingReference', 'ref');
title('RingReference: ref');
saveFigure(fig, fullfile(outputDir, 'rings_ring_reference_modes.png'));

% 11. rings_bands_chroma.png - BandChroma 0 vs 100
fprintf('  11/20: rings_bands_chroma.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 800 400]);
subplot(1, 2, 1);
PlotRings(srgb, 'BandChroma', 0);
title('BandChroma = 0 (grayscale)');
subplot(1, 2, 2);
PlotRings(srgb, 'BandChroma', 100);
title('BandChroma = 100 (saturated)');
saveFigure(fig, fullfile(outputDir, 'rings_bands_chroma.png'));

% 12. rings_bands_hue_fixed.png - Fixed vs match hue
fprintf('  12/20: rings_bands_hue_fixed.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 800 400]);
subplot(1, 2, 1);
PlotRings(srgb, 'BandHue', 'match');
title('BandHue = match');
subplot(1, 2, 2);
PlotRings(srgb, 'BandHue', 240);
title('BandHue = 240 (blue)');
saveFigure(fig, fullfile(outputDir, 'rings_bands_hue_fixed.png'));

% 13. rings_show_bands_off.png - Lines only
fprintf('  13/20: rings_show_bands_off.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 600 500]);
PlotRings(srgb, 'ShowBands', false);
title('ShowBands = false (lines only)');
saveFigure(fig, fullfile(outputDir, 'rings_show_bands_off.png'));

% 14. rings_chroma_rings.png - Constant chroma circles
fprintf('  14/20: rings_chroma_rings.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 600 500]);
PlotRings(srgb, 'ChromaRings', [500, 1000]);
title('ChromaRings at 500 and 1000');
saveFigure(fig, fullfile(outputDir, 'rings_chroma_rings.png'));

% 15. rings_primaries_all.png - RGBCMY arrows
fprintf('  15/20: rings_primaries_all.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 600 500]);
PlotRings(srgb, 'Primaries', 'all');
title('All Primaries (RGBCMY)');
saveFigure(fig, fullfile(outputDir, 'rings_primaries_all.png'));

% 16. rings_primaries_with_reference.png - Test vs reference primaries
fprintf('  16/20: rings_primaries_with_reference.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 600 500]);
PlotRings(lcd, srgb, 'Primaries', 'all', 'RefPrimaries', 'all');
title('Test and Reference Primaries');
saveFigure(fig, fullfile(outputDir, 'rings_primaries_with_reference.png'));

% 17. rings_primary_origin_modes.png - centre vs ring
fprintf('  17/20: rings_primary_origin_modes.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 800 400]);
subplot(1, 2, 1);
PlotRings(srgb, 'Primaries', 'rgb', 'PrimaryOrigin', 'centre');
title('PrimaryOrigin = centre');
subplot(1, 2, 2);
PlotRings(srgb, 'Primaries', 'rgb', 'PrimaryOrigin', 'ring');
title('PrimaryOrigin = ring');
saveFigure(fig, fullfile(outputDir, 'rings_primary_origin_modes.png'));

% ========== ADVANCED IMAGES (18-20) ==========

% 18. coverage_calculation_workflow.png - Coverage visualization
fprintf('  18/20: coverage_calculation_workflow.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 600 500]);
intersection = IntersectGamuts(lcd, srgb);
coverage = GetVolume(intersection) / GetVolume(srgb) * 100;
PlotRings(lcd, srgb, 'RingReference', 'intersection');
title(sprintf('sRGB Coverage: %.1f%%', coverage));
legend('LCD', 'sRGB', 'Location', 'northeast');
saveFigure(fig, fullfile(outputDir, 'coverage_calculation_workflow.png'));

% 19. reflective_display_example.png - IDMS v1.3 format
fprintf('  19/20: reflective_display_example.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 600 500]);
if exist('example_reflective_cge_measurement.txt', 'file')
    reflective = CIELabGamut('example_reflective_cge_measurement.txt');
    PlotRings(reflective, srgb);
    title('Reflective Display (IDMS v1.3)');
    legend('Reflective', 'sRGB', 'Location', 'northeast');
else
    % Fallback if file doesn't exist
    PlotRings(lcd, srgb);
    title('Reflective Display Example');
end
saveFigure(fig, fullfile(outputDir, 'reflective_display_example.png'));

% 20. scatter_data_overlay.png - ScatterData demo
fprintf('  20/20: scatter_data_overlay.png\n');
fig = figure('Visible', 'off', 'Position', [100 100 600 500]);
% Generate random Lab scatter points within sRGB gamut
rng(42); % For reproducibility
scatter_lab = zeros(200, 3);
scatter_lab(:,1) = rand(200,1) * 100;  % L*: 0-100
scatter_lab(:,2) = (rand(200,1) - 0.5) * 200;  % a*: -100 to 100
scatter_lab(:,3) = (rand(200,1) - 0.5) * 200;  % b*: -100 to 100
PlotRings(srgb, 'ScatterData', scatter_lab);
title('ScatterData Overlay');
saveFigure(fig, fullfile(outputDir, 'scatter_data_overlay.png'));

fprintf('Done! Generated 20 images in %s\n', outputDir);

end

function saveFigure(fig, filepath)
%SAVEFIGURE Save figure to PNG file
    % Ensure figure is rendered
    drawnow;

    % Save as PNG
    print(fig, filepath, '-dpng', '-r150');

    % Close figure
    close(fig);
end
