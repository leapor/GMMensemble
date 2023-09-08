close all; clear all;

% Plotting the classification and likelihood of the 3 subregions for the
% paper.
% Includes adding letters for each row of subplots and class names. Also 
% plots isobaths for 250 and 1000 m.
% ISOBATHS TAKE A LONG TIME TO PLOT!
% Needs m_map and othercolor packages.

% -------------------------------------------------
% --- File names ---
% -------------------------------------------------
folder = '../Results/';
regs = {'Baltic_PCs4_tr90_K5_r98_p00_gp100_N200_t1', ...
    'North_PCs3_tr90_K6_r98_p00_gp100_N200_t1', ...
    'Norwegian_PCs7_tr90_K8_r98_p00_gp100_N200_t1'};
nexp = length(regs);
figname = '../FiguresFinal/ClassificationRegions';

% bathymetry file
bathyfile = 'gebco_2022_n76.0_s48.0_w-12.0_e32.0.nc';


% -------------------------------------------------
% --- Parameters and information for plotting ---
% -------------------------------------------------
% experiment titles
titles = {'a) Baltic Sea', 'b) North Sea', 'c) Norwegian Sea\n    (part)'};

% marker size
msize = 20;

% isobaths
isobaths = [250, 1000];

% order of the classes for these 3 specific models - done the oposite way
% compared to the figure for the whole region!
% new order is:
% Baltic - north to south, last is the Norwegian Sea class
% North - north to south + left to right
% Norwegian - west to east, then north to south, last is the Baltic
order1 = [3, 5, 4, 1, 2];
order2 = [4, 2, 6, 3, 5, 1];
order3 = [3, 7, 2, 8, 6, 1, 4, 5];
order = {order1; order2; order3};

% class names - not used here, class number will be used as name

% location of the class names
loclon1 = [19.0, 18.0, 12.0, 11.0];
loclat1 = [61.5, 55.8, 55.0, 57.7];
loclon2 = [-2.5,  0.0,  2.0,  2.7,  7.0,  5.0];
loclat2 = [62.0, 59.0, 55.5, 52.2, 54.5, 61.0];
loclon3 = [ 6.0,  6.0,  2.0,  8.0, 14.0, 21.0, 21.0];
loclat3 = [73.8, 70.0, 65.0, 65.0, 72.0, 74.5, 71.5];
loclon = {loclon1; loclon2; loclon3};
loclat = {loclat1; loclat2; loclat3};

% colors
cmap1 = [0.4039 0.7216 0.5922; 0.2078 0.4392 0.2863; 0.83 0.75 0.23; 0.76 0.07 0.07; 0.5 0.5 0.5];
cmap2 = [0.3333 0.5059 0.7608; 0.2078 0.4392 0.2863; 0.4039 0.7216 0.5922; ...
    0.83 0.75 0.23; 0.97 0.47 0.44; 0.76 0.07 0.07];
cmap3 = [0.4039 0.7216 0.5922; 0.2078 0.4392 0.2863; 0.5490 0.8275 0.9294; ...
    0.3333 0.5059 0.7608; 0.83 0.75 0.23; 0.97 0.47 0.44; 0.76 0.07 0.07; ...
    0.5 0.5 0.5];
cmapc = {cmap1; cmap2; cmap3};
gray = [0.7 0.7 0.7]; % color for continents
cmapl = flipud(othercolor('GnBu6', 10)); % color for likelihood



% ---------------------------------------------
% --- Loading the bathymetry ---
% ---------------------------------------------
% it can only be processed within the loop because the region is different
% every time
lonb0 = ncread(bathyfile, 'lon');
latb0 = ncread(bathyfile, 'lat');
bathy0 = ncread(bathyfile, 'elevation');


% ---------------------------------------------------
% --- Plotting ---
% ---------------------------------------------------
fig = figure('Position', [10, 10, 1100, 1720]);
tiledlayout(nexp, 2, 'TileSpacing', 'compact', 'Padding', 'compact', ...
    'PositionConstraint','innerposition', 'InnerPosition', [0.1300 0.1100 0.730 0.8150]);

for i = 1 : nexp
    % read data
    filein = strcat(folder, regs{i});
    load(filein);
    K = max(res_grid, [], 'all');

    % reorder classes - done in the opposite way than in fig for whole reg!
    ord = order{i};
    for j = 1 : K
        res_grid(res_grid == j) = ord(j)+100;
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

    % map borders (different for every plot)
    lonborders = [floor(min(lon)), ceil(max(lon))+0.2];
    latborders = [floor(min(lat)), ceil(max(lat))];

    % processing bathymetry
    indlon = find(lonb0>=lonborders(1) & lonb0<=lonborders(2));
    indlat = find(latb0>=latborders(1) & latb0<=latborders(2));
    lonb = lonb0(indlon);
    latb = latb0(indlat);
    bathy = bathy0(indlon, indlat);

    bathy(bathy >0) = NaN;
    bathy = -bathy;

    bathys = imgaussfilt(bathy, [20, 35]); % smoothing

    % plotting classes
    ax1 = nexttile;
    colormap(ax1, cmapc{i});                                         % !!!!!
    m_proj('lambert', 'lon', lonborders, 'lat', latborders); hold on;
    m_pcolor(Lon, Lat, res_grid);
    m_scatter(Lonte, Latte, msize, 'k', '.'); % adding test set grid points locations
    caxis([1, K+1]);
    m_gshhs_l('patch',gray, 'edgecolor', gray);
    m_grid;
    %colorbar;

    % adding bathymetry
    m_contour(lonb, latb, bathys', [isobaths(1), isobaths(1)], 'LineWidth', 1, 'LineColor', 'k', ...
        'ShowText', 0);
    m_contour(lonb, latb, bathys', [isobaths(2), isobaths(2)], 'LineWidth', 2, 'LineColor', 'k', ...
        'ShowText', 0);

    % adding the class name
    if (i == 2)
        Kreal = K;
    else
        Kreal = K-1;
    end
    for j = 1 : Kreal
        m_text(loclon{i}(j), loclat{i}(j), num2str(j), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'FontSize', 20, 'FontWeight', 'bold', 'BackgroundColor', [1 1 1 0.2], 'Margin', 1);
    end

    % adding the row title
    text(-0.2, 1.1, sprintf(titles{i}), 'Units', 'normalized', ...
        'HorizontalAlignment','left', 'VerticalAlignment', 'top', ...
        'FontSize', 14);

    % plotting likelihood
    ax2 = nexttile;
    colormap(ax2, cmapl);
    m_proj('lambert', 'lon', lonborders, 'lat', latborders); hold on;
    m_pcolor(Lon, Lat, like_grid);
    m_gshhs_l('patch',gray, 'edgecolor', gray);
    m_grid;
    % if i == 2
    %     cb = colorbar;
    %     cb.Position(1) = cbpos;
    % else
    %     cb = colorbar;
    %     cbpos = cb.Position(1);
    % end
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
