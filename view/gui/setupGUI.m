function [fig, ax_main, ax_3d] = setupGUI()
    % Tạo cửa sổ chính và các axes
    
    % Kích thước màn hình
    screenSize = get(0, 'ScreenSize');  % [left, bottom, width, height]
    
    % Kích thước cửa sổ figure mong muốn
    figWidth = 1700;
    figHeight = 900;
    
    % Tính tọa độ để căn giữa
    left = (screenSize(3) - figWidth) / 2;
    bottom = (screenSize(4) - figHeight) / 2;

    % Tạo figure
    fig = figure( ...
        'Name', 'HỆ THỐNG CHỈ HUY PHÒNG KHÔNG', ...
        'Position', [left, bottom, figWidth, figHeight], ...
        'Color', [0.08, 0.08, 0.12], ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none' ...
    );
    
    movegui(fig, 'center');  % Căn giữa màn hình
    
    % Axes 2D (màn hình chính)
    ax_main = subplot('Position', [0.05, 0.35, 0.55, 0.62]);
    setupAxis2D(ax_main);
    
    % Axes 3D (màn hình phụ)
    ax_3d = subplot('Position', [0.63, 0.35, 0.35, 0.62]);
    setupAxis3D(ax_3d);
end