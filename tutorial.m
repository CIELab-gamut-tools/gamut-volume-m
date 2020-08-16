% This is a tutorial to introduce what can be done with this codebase
% Running this script will generate a number of figures and report results
% to the command line.  More detailed information will be in the comments
% of this file.

% This script relies entirely on simulated synthetic gamut data so the
% CIELabGamut function will be little used, however it should be clear that
% the various options to use to plot and analyse gamuts are as applicable
% to experimental data loaded from a CGATS file as they are to synthetic
% data.

%% 3D CIELab and Gamut Rings plot of reference gamuts.

% First, the most basic reference point, the standard gamuts.  We will look
% at three - sRGB, D65-P3 and BT.2020.  Most variants of the P3 gamut are
% supported - D50-P3, D65-P3 and DCI-P3.  They vary in their white point
% and so the D65 one is used for reference here as sRGB and BT.2020 also
% use a D65 white.

srgb = SyntheticGamut('srgb');
bt2020 = SyntheticGamut('bt.2020');
p3 = SyntheticGamut('d65-p3');

% each of these variables are gamut objects which have a number of
% sub-properties.  The ones which might be usefule are .RGB (e.g.
% srgb.RGB), .RGBmax, .XYZ and .LAB

% we will make two plots on one figure, a 3D volume plot on the right and a
% Gamut Rings plot on the left.
% For any of the commands, use "help <command>" or "doc <command>" for more
% information.

fh=figure(1);               % use figure 1
fh.Position(3:4)=[1000,420];% set the figure dimensions
clf;                        % clear the selected figure;
subplot(1,2,1);             % 1 row, 2 columns, select the 1st.
PlotVolume(bt2020, 0.2);    % plot bt2020 with an alpha (opacity) of 0.2
hold on;                    % 'hold' the plot - overlay subsiquent plots
PlotVolume(p3, 0.3);
PlotVolume(srgb);
hold off;
view(-10, 40);              % set the 3D view, -20° azimuth, 30° elevation
% set the title.  {\it...} indicates to use italics
title('{\itCIEL*a*b*} plot of Standard Reference Gamuts');
% rather than use a legend, put text on the chart.  To do so we need the
% locations of some points in CIELab space.
% for sRGB use the red position, so get the index of the red primary.
iRed = getIndex(srgb, [1, 0, 0]);
% use the corresponding LAB values to position the text.  The 3D plot
% X-axis is a*, the Y-axis is b* and the Z-axis is L*.
text(srgb.LAB(iRed,2), srgb.LAB(iRed,3), srgb.LAB(iRed,1), ' sRGB');
% for P3 use a point half-way from red to magenta
iMag = getIndex(p3, [1, 0, 0.5]);
text(p3.LAB(iMag,2), p3.LAB(iMag,3), p3.LAB(iMag,1), ' D65-P3');
% and for BT.2020 use the blue
iBlue = getIndex(bt2020, [0, 0, 1]);
text(bt2020.LAB(iBlue,2), bt2020.LAB(iBlue,3), bt2020.LAB(iBlue,1), ' BT.2020');

% now for the rings plot.
subplot(1,2,2);
% up to two reference gamuts can be included
PlotRings(srgb,p3,bt2020);
title('{\itCIEL*a*b*} Gamut Rings plot of Standard Reference Gamuts');
% as a 2D line plot the standard legend works well, no need to manually put
% text on the chart.
legend('sRGB','D65-P3','BT.2020');

% finally display some information about the gamuts on screen
% The format %7d means 7 characters wide decimal integer 
% The round function rounds a value to the places shown, a negative number
% rounds to the left of the decimal point, so -4 is to the nearest 10,000
fprintf('CIELab Colour Gamut Volumes\n');
fprintf('sRGB    : %7d\n',round(GetVolume(srgb),-4));
fprintf('D65-P3  : %7d\n',round(GetVolume(p3),-4));
fprintf('BT.2020 : %7d\n',round(GetVolume(bt2020),-4));

%% Simulating a synthetic gamut

% The second example is to use the Synthetic Gamut function to investigate
% the impact of changing the chromaticities of one primary.

% the reference here will use the sRGB primaries and a D65 white.  A
% default gamma of 2.4 will be assumed.

refGmt = SyntheticGamut([.68,.32;.265,.69;.15,.06],'D65');

% as a comparison, use the more saturated BT.2020 green

deepBlueGmt = SyntheticGamut([.68,.32;.17,.797;.15,.06],'D65');

% plot the rings

figure(2);               % use figure 2
PlotRings(deepBlueGmt, refGmt);
title(sprintf('sRGB red and blue with BT.2020 green\n'));
legend('sRGB RB + BT2020 G','sRGB primaries');



%% helper functions

srgb = SyntheticGamut('srgb','Steps',[0, 1/255, 0.1:0.1:0.9, 1-1/255, 1]);
i1 = getIndex(srgb,[0,0,0]);
i2 = getIndex(srgb,[0,1/255,0]);
i3 = getIndex(srgb,[0,1,1]);
i4 = getIndex(srgb,[1/255,1,1]);
i5 = getIndex(srgb,[1,0,0]);
i6 = getIndex(srgb,[1-1/255,0,0]);
i7 = getIndex(srgb,[1,1,1]);
i8 = getIndex(srgb,[1,1-1/255,1]);
LAB = srgb.LAB([i1,i2,i3,i4,i5,i6,i7,i8],:);
display(LAB);
disp(norm(LAB(2,:)-LAB(1,:)));
disp(norm(LAB(4,:)-LAB(3,:)));
disp(norm(LAB(6,:)-LAB(5,:)));
disp(norm(LAB(8,:)-LAB(7,:)));
% find the index of a particular rgb colour
function i = getIndex(gamut, rgb)
  % normalise the target RGB triplet
  targ = rgb * gamut.RGBmax;
  % first get an exact match
  i = find(all(gamut.RGB == targ, 2), 1);
  % if no exact match was found
  if isempty(i)
      % find the closest (by Euclidean distance)
      [~,i]=min(sum((gamut.RGB - targ).^2, 2));
  end
end

