function [fig, ax_main, ax_3d] = setupGUI()
    % Tạo cửa sổ chính và các axes
    
    % Tạo figure
    fig = figure( ...
        'Name', 'HỆ THỐNG CHỈ HUY PHÒNG KHÔNG', ...
        'Position', [50, 50, 1700, 900], ...
        'Color', [0.08, 0.08, 0.12], ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none' ...
    );
    
    % Axes 2D (màn hình chính)
    ax_main = subplot('Position', [0.05, 0.35, 0.55, 0.62]);
    setupAxis2D(ax_main);
    
    % Axes 3D (màn hình phụ)
    ax_3d = subplot('Position', [0.63, 0.35, 0.35, 0.62]);
    setupAxis3D(ax_3d);
end