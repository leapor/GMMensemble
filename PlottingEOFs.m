close all; clear all;

% Plotting the figure for the paper with EOFs and class means for the 3
% presented models for the whole area.
% Includes the 250 and 1000 m isobaths.
% Needs m_map and othercolor packages.

% files and folders
bathyfile = 'gebco_2022_n76.0_s48.0_w-12.0_e32.0.nc';
resfolder = '../Results/';
models = {'Large_PCs3_tr90_K4_r98_p00_gp100_N200_t1', ...
    'Large_PCs5_tr90_K6_r98_p00_gp100_N200_t1', ...
    'Large_PCs11_tr90_K10_r98_p00_gp100_N200_t1'};
nexp = length(models);
eoffile = '../Data/Large_PCs.mat';
figname = '../FiguresFinal/EOFs';
modtitles = {'d) K = 4 (3 EOFs)', 'c) K = 6 (5 EOFs)', 'b) K = 10 (11 EOFs)'};
npcs = [3, 5, 11];
K = [4, 6, 10];

% isobaths
isobaths = [250, 1000];

% colormap
cmap = flipud(othercolor('Mredbluetones', 100));
gray = [0.7 0.7 0.7];

% max number of EOF maps
pcmax = 7;

% map borders
lonborders = [-10, 30];
latborders = [50, 75];


% --- Load and prepare the bathymetry ---
% lonb = ncread(bathyfile, 'lon');
% latb = ncread(bathyfile, 'lat');
% bathy = ncread(bathyfile, 'elevation');
% 
% indlon = find(lonb>=lonborders(1) & lonb<=lonborders(2));
% indlat = find(latb>=latborders(1) & latb<=latborders(2));
% lonb = lonb(indlon);
% latb = latb(indlat);
% bathy = bathy(indlon, indlat);
% 
% bathy(bathy >0) = NaN;
% bathy = -bathy;
% 
% bathys = imgaussfilt(bathy, [20, 35]); % smoothing


% --- Load EOF maps and classification results ---
% load all EOFs and keep only the EOFs that will be plotted
load(eoffile);
eof_maps = eof_maps(1:pcmax, :, :);
exp_var = exp_var(1:pcmax);

% load results and create a class means grid file
%npcs = zeros(nexp, 1);
%K = zeros(nexp, 1);
mean_eof_maps = zeros(nexp, pcmax, length(lat), length(lon));
for i = 1 : nexp
    % load data
    load(strcat(resfolder, models{i}, '.mat'))
    %load(strcat(resfolder, models{i}, 'class_means.mat'))
    %[K(i), npcs(i)] = size(class_means);

    % calculate class means for each EOF and class
    for j = 1 : min(npcs(i), pcmax)
        temp_mean = res_grid;
        for k = 1 : K(i)
            temp = eof_maps(j, :, :);
            temp_mean(res_grid == k) = mean(temp(res_grid == k), 'omitmissing');
        end
        mean_eof_maps(i, j, :, :) = temp_mean;
    end
end


% --- Prepare for plotting with pcolor (meshgrid + edge) ---
dlon = lon(2) - lon(1);
dlat = lat(2) - lat(1);
lonp = [lon, lon(end)+dlon] - dlon/2;
latp = [lat, lat(end)+dlat] - dlat/2;
[Lon, Lat] = meshgrid(lonp, latp);

eof_maps(:, end+1, :) = eof_maps(:, end, :);
eof_maps(:, :, end+1) = eof_maps(:, :, end);

mean_eof_maps(:, :, end+1, :) = mean_eof_maps(:, :, end, :);
mean_eof_maps(:, :, :, end+1) = mean_eof_maps(:, :, :, end);


% --- Plotting ---
fig = figure('Position', [10, 10, 1100, 1700]);
tiledlayout(pcmax, nexp+1, 'TileSpacing', 'compact', 'Padding', 'compact', 'TileIndexing', 'columnmajor');

% plotting the EOF map in the first column
lims = zeros(pcmax, 2);
for i = 1 : pcmax
    nexttile;
    colormap(cmap);
    m_proj('lambert', 'lon', lonborders, 'lat', latborders); hold on;
    m_pcolor(Lon, Lat, squeeze(eof_maps(i, :, :)));
    m_gshhs_l('patch',gray, 'edgecolor', gray);
    m_grid;

    % finding the limits for each EOF
    lims(i, 1) = min(eof_maps(i, :, :), [], 'all');
    lims(i, 2) = max(eof_maps(i, :, :), [], 'all');
    caxis(lims(i, :));
    fprintf('%2i | %f  %f\n', i, lims(i, 1), lims(i, 2))

    % eof number and percentage of variance
    a = strjoin({'EOF', num2str(i), strcat('(', num2str(exp_var(i)*100, '%3.1f'), '%)')});
    t = text(-0.23, 0.95, a, 'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'bottom', 'Units', 'normalized', ...
        'Interpreter', 'none', 'FontSize', 14);
    t.Rotation = 90;

    % adding isobaths
    % m_contour(lonb, latb, bathys', [isobaths(1), isobaths(1)], 'LineWidth', 1, 'LineColor', 'k', ...
    %     'ShowText', 0);
    % m_contour(lonb, latb, bathys', [isobaths(2), isobaths(2)], 'LineWidth', 2, 'LineColor', 'k', ...
    %     'ShowText', 0);

    % adding title on the top tile
    if i == 1
        text(0.5, 1.2, 'a) EOFs', 'Units', 'normalized', ...
            'HorizontalAlignment','center', 'FontSize', 14);
    end
end

% plotting the mean EOFs for all 3 models in reverse order in columns 2-4
for j = nexp : -1 : 1
    for i = 1 : min(npcs(j), pcmax)
        nexttile((1+3-j)*pcmax + i);
        colormap(cmap);
        m_proj('lambert', 'lon', lonborders, 'lat', latborders); hold on;
        m_pcolor(Lon, Lat, squeeze(mean_eof_maps(j, i, :, :)));
        m_gshhs_l('patch',gray, 'edgecolor', gray);
        m_grid;
        caxis(lims(i, :));

        % adding isobaths
        % m_contour(lonb, latb, bathys', [isobaths(1), isobaths(1)], 'LineWidth', 1, 'LineColor', 'k', ...
        %     'ShowText', 0);
        % m_contour(lonb, latb, bathys', [isobaths(2), isobaths(2)], 'LineWidth', 2, 'LineColor', 'k', ...
        %     'ShowText', 0);

        % adding title on the top tile
        if i == 1
            text(0.5, 1.2, modtitles{j}, 'Units', 'normalized', ...
                'HorizontalAlignment','center', 'FontSize', 14);
        end
    end
end
print(figname, '-dpng')