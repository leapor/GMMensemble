close all; clear all;
% Plotting the classification and likelihood of the whole region for the
% paper.
% Plotting the figure with all 3 experiments (classification on the left
% and likelihood on the right). Includes adding letters for each row of
% subplots and class names. Also plots isobaths for 250 and 1000 m.
% PLOTTING ISOBATHS TAKES A LONG TIME!
% Needs m_map and othercolor packages.

% -------------------------------------------------
% --- File names ---
% -------------------------------------------------
% folder and file names
folder = '../Results/';
models = {'Large_PCs3_tr90_K4_r98_p00_gp100_N200_t1', ...
    'Large_PCs5_tr90_K6_r98_p00_gp100_N200_t1', ...
    'Large_PCs11_tr90_K10_r98_p00_gp100_N200_t1'};
nexp = length(models);
figname = '../FiguresFinal/ClassificationWholeRegion';

% bathymetry file
bathyfile = 'gebco_2022_n76.0_s48.0_w-12.0_e32.0.nc';

% -------------------------------------------------
% --- Parameters and information for plotting ---
% -------------------------------------------------
% experiment titles
titles = {'a) K=4\n    (3 EOFs)', 'b) K=6\n    (5 EOFs)', 'c) K=10\n    (11 EOFs)'};

% map borders
lonborders = [-10, 30];
latborders = [50, 75];

% marker size
msize = 20;

% isobaths
isobaths = [250, 1000];

% order of the classes for these specific 3 models
% (new order is: open ocean, coast, North, Baltic)
order1 = [2, 1, 4, 3];
order2 = [5, 2, 4, 6, 3, 1];
order3 = [4, 8, 7, 5, 6, 3, 1, 9, 10, 2];
order = {order1; order2; order3};

% class names
names1 = {'O', 'C', 'N', 'B'};
names2 = {'O1', 'O2', 'C1', 'C2', 'N', 'B'};
names3 = {'O1', 'O21', 'O22', 'C1', 'C21', 'C22', 'C23', 'N1', 'N2', 'B'};
classnames = {names1; names2; names3};

% location of the class names
loclon1 = [ 0.0, 22.0,  2.0, 20.0];
loclat1 = [67.5, 72.5, 56.5, 59.0];
loclon2 = [10.0, -3.0, 22.0, -7.0,  2.0, 20.0];
loclat2 = [72.0, 66.0, 72.5, 59.0, 56.5, 59.0];
loclon3 = [11.0, -3.0, -2.0, ...
    22.0,  9.0, -7.0, -8.0, ...
     2.0,  8.0, 20.0];
loclat3 = [72.2, 66.0, 74.0, ...
    72.5, 65.5, 61.0, 51.0, ...
    56.5, 54.5, 59.0];

loclon = {loclon1; loclon2; loclon3};
loclat = {loclat1; loclat2; loclat3};

% colors
cmap1 = [0.2078 0.4392 0.2863; ...
    0.07 0.17 0.84; ...
    0.76 0.07 0.07; ...
    0.83 0.75 0.23];
cmap2 = [0.4039 0.7216 0.5922; 0.2078 0.4392 0.2863; ...
    0.07 0.17 0.84; 0.5490 0.8275 0.9294; ...
    0.76 0.07 0.07; 0.83 0.75 0.23];
cmap3 = [0.4039 0.7216 0.5922; 0.2078 0.4392 0.2863; 0.2000 0.7686 0.1020; ...
    0.07 0.17 0.84; 0.3333 0.5059 0.7608; 0.5490 0.8275 0.9294; 0.5137 0.4824 0.9294; ...
    0.76 0.07 0.07; 0.97 0.47 0.44; ...
    0.83 0.75 0.23];
cmaps = {cmap1; cmap2; cmap3};
gray = [0.7 0.7 0.7];
cmapl = flipud(othercolor('GnBu6', 10));


% ---------------------------------------------
% --- Loading and processing the bathymetry ---
% ---------------------------------------------
lonb = ncread(bathyfile, 'lon');
latb = ncread(bathyfile, 'lat');
bathy = ncread(bathyfile, 'elevation');

indlon = find(lonb>=lonborders(1) & lonb<=lonborders(2));
indlat = find(latb>=latborders(1) & latb<=latborders(2));
lonb = lonb(indlon);
latb = latb(indlat);
bathy = bathy(indlon, indlat);

bathy(bathy >0) = NaN;
bathy = -bathy;

bathys = imgaussfilt(bathy, [20, 35]); % smoothing


% ---------------------------------------------------
% --- Plotting ---
% ---------------------------------------------------
fig = figure('Position', [10, 10, 1100, 1700]);
tiledlayout(nexp, 2, 'TileSpacing', 'compact', 'Padding', 'compact', ...
    'PositionConstraint','innerposition', 'InnerPosition', [0.1300 0.1100 0.730 0.8150]);

for i = 1 : nexp
    % read data
    filein = strcat(folder, models{i});
    load(filein);
    K = max(res_grid, [], 'all');

    % reorder classes to be ocean, coast, North, Baltic
    ord = order{i};
    for j = 1 : K
        res_grid(res_grid == ord(j)) = j+100;
    end
    res_grid = res_grid-100;

    % prepare for plotting
    dlon = lon(2) - lon(1);
    dlat = lat(2) - lat(1);
    lonp = [lon, lon(end)+dlon] - dlon/2;
    latp = [lat, lat(end)+dlat] - dlat/2;
    [Lon, Lat] = meshgrid(lonp, latp);
    
    res_grid(end+1, :) = K+1;
    res_grid(:, end+1) = K+1;

    like_grid(end+1, :) = 1.1;
    like_grid(:, end+1) = 1.1;


    % plotting classes
    ax1 = nexttile;
    colormap(ax1, cmaps{i});
    m_proj('lambert', 'lon', lonborders, 'lat', latborders); hold on;
    m_pcolor(Lon, Lat, res_grid);
    m_scatter(Lonte, Latte, msize, 'k', '.'); % adding test set grid points locations
    caxis([1, K+1]);
    m_gshhs_l('patch',gray, 'edgecolor', gray);
    m_grid;

    % adding bathymetry
    m_contour(lonb, latb, bathys', [isobaths(1), isobaths(1)], 'LineWidth', 1, 'LineColor', 'k', ...
        'ShowText', 0);
    m_contour(lonb, latb, bathys', [isobaths(2), isobaths(2)], 'LineWidth', 2, 'LineColor', 'k', ...
        'ShowText', 0);

    % adding the class name
    for j = 1 : K
        m_text(loclon{i}(j), loclat{i}(j), classnames{i}(j), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'FontSize', 20, 'FontWeight', 'bold', 'BackgroundColor', [1 1 1 0.2], 'Margin', 1);
    end

    % adding the row title
    text(-0.2, 1.08, sprintf(titles{i}), 'Units', 'normalized', ...
        'HorizontalAlignment','left', 'VerticalAlignment', 'top', ...
        'FontSize', 14);

    % plotting likelihood
    ax2 = nexttile;
    colormap(ax2, cmapl);
    m_proj('lambert', 'lon', lonborders, 'lat', latborders); hold on;
    m_pcolor(Lon, Lat, like_grid);
    m_gshhs_l('patch',gray, 'edgecolor', gray);
    m_grid;
    %colorbar;
    caxis([0, 1]);

    % adding bathymetry
    m_contour(lonb, latb, bathys', [isobaths(1), isobaths(1)], 'LineWidth', 1, 'LineColor', 'k', ...
        'ShowText', 0);
    m_contour(lonb, latb, bathys', [isobaths(2), isobaths(2)], 'LineWidth', 2, 'LineColor', 'k', ...
        'ShowText', 0);
end

% adding a common colorbar for the likelihood plots (vertical, right)
h = axes(fig,'visible','off');
colormap(h, cmapl);
cb = colorbar(h);
cb.Position(2) = 0.25;
cb.Position(4) = 0.5;
cb.Label.String = "Likelihood";
cb.Label.FontSize = 20;
cb.FontSize = 14;
cb.TickLabels = num2str(cb.Ticks', '% 3.1f');

print(figname, '-dpng');
