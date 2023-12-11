close all; clear all;

% Author: Lea Poropat
% Last edited: 2023-12-11

% Plotting the classification results for the ensemble classification with GMMs.
% Calculation of the mean likelihood over the whole area.
% Prints a warning if the actual ensemble decided number of classes is
% different from inputted K.
% Class numbers are printed outomatically in the middle (mean lon and lat)
% of each class. This can cause the class number to be outside of the class
% if the class consist of two or more geographically separate areas or has
% a very irregular shape. If that is the case, set plot_colorbar_for_classes
% to true and instead of numbers a colorbar for class assignment is
% plotted.

%% REQUUIREMENTS
% Needs m_map package.
% Uses the colormap stored in colormap.csv as triplets
% of numbers between 0 and 1 (Matlab standard). The colormap needs to have
% at least K numbers. If it has more, the first K will be used. We used the
% matplotlib qualitative colormap Paired.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
reg = 'NWeuropeSeas';   % region
npc = 3;                % number of EOFs
K = 4;                  % number of classes
ens = 1;                % ensemble number (in case of multiple runs)
y1 = 1995;              % first year of the time span used
y2 = 2021;              % last year of the time span used

plot_colorbar_for_classes = false; % true -> colorbar, false -> class numbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% --- Input and output file names ---
filein = strcat('../Data/s04_ClassificationResults/', reg, '_', ...
    num2str(y1), '-', num2str(y2), ...
    '_PCs', num2str(npc), '_K', ...
    num2str(K), '_tr90_r98_gp100_N200_t', num2str(ens), '.nc');

fileout = strcat('../Figures/s05_ClassificationResultsMap/', ...
    reg, num2str(y1), '-', num2str(y2), ...
    '_PCs', num2str(npc), '_K', num2str(K), '_ens', num2str(ens));

figtitle = "Classification with " + num2str(npc) + " EOFs and K = " + num2str(K);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% --- Creating colormaps for the plots (needs the number of classes K) ---
cmapfile = 'colormap.csv'; % load the colormap exported from python as csv
cmapc = load(cmapfile);
cmapc = cmapc(1:K, :);
cmapc = brighten(cmapc, 0.2);
cmapl = flipud(othercolor('GnBu6', 10));
gray = [1 1 1]*0.7;


%% --- Load the data ---
lon = ncread(filein, 'longitude');
lat = ncread(filein, 'latitude');
xc = ncread(filein, 'classification');
xl = ncread(filein, 'likelihood');

%% --- Calculate and print the average and the lowest likelihood ---
likeav = mean(xl, 'all', 'omitmissing');
likelow = min(xl, [], 'all', 'omitmissing');
fprintf('%s, EOFs = %2i, K = %2i \n', reg, npc, K)
fprintf("Average likelihood over the whole area: %4.2f\n", likeav)
fprintf("Lowest likelihood in the whole area:    %4.2f\n", likelow)
Kreal = max(xc, [], 'all', 'omitmissing');
if Kreal ~= K
    fprintf(', actual K = %2i!\n', Kreal)
else
    fprintf('\n')
end


%% --- Create a meshgrid ---
[Lon, Lat] = meshgrid(lon, lat);


%% --- Figure size and position ---
fig = figure('Units', 'centimeters', 'Position', [2, 6, 18, 12]);
fig.Visible = 'on';
t = tiledlayout(1, 2, 'PositionConstraint', 'outerposition', 'TileSpacing', 'tight');
title(t, figtitle, 'FontSize', 16, 'FontWeight', 'bold');

%% --- Plot classification ---
ax1 = nexttile;
m_proj('lambert', 'lon', [min(lon), max(lon)], 'lat', [min(lat), max(lat)]);
m_pcolor(Lon, Lat, xc); hold on;
m_gshhs_l('patch',gray, 'edgecolor', gray);
m_grid('fontsize', 14);
colormap(ax1, cmapc);

% class numbers (either text on the map or colorbar)
caxis([1, K+1]);
if plot_colorbar_for_classes
    orientation = 'horizontal';
    colorbar(orientation, 'Ticks', [1:K]+0.5, 'TickLabels', [1:K]);
else
    orientation = 'vertical';

    % add class numbers
    for i = 1 : K
        lonc = median(Lon(xc == i));
        latc = median(Lat(xc == i));
        if mean(cmapc(i, :) >= 0.3)
            textcol = [0 0 0];
        else
            textcol = [1 1 1];
        end
        m_text(lonc, latc, num2str(i), 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', 'FontSize', 16, 'FontWeight', 'bold', ...
            'Color', textcol);
    end
end

%% --- Plot likelihood ---
ax2 = nexttile;
m_proj('lambert', 'lon', [min(lon), max(lon)], 'lat', [min(lat), max(lat)]);
m_pcolor(Lon, Lat, xl); hold on;
m_gshhs_l('patch',gray, 'edgecolor', gray);
m_grid('fontsize', 14);
colormap(ax2, cmapl);
h = colorbar(orientation, 'FontSize', 14, ...
    'Ticks', [0:0.2:1], ...
    'TickLabels', compose('%3.1f', [0:0.2:1.0]));
set(get(h, 'label'), 'string', 'Likelihood', 'FontSize', 16);
caxis([0 1]);

%% --- Save figure ---
print(fileout, '-dpng', '-r400')