function drawPlannedPaths(ax_main, ax_3d, targets)
    % Vẽ đường dự kiến và waypoints
    
    for i = 1:length(targets)
        smooth_path = targets(i).smooth_path;
        wp = targets(i).waypoints;
        color = targets(i).color;
        
        % 2D - Đường cong mượt
        plot(ax_main, smooth_path(:,1), smooth_path(:,2), '-', ...
             'Color', [color, 0.3], ...
             'LineWidth', 1.2);
        
        % Waypoints
        for j = 1:size(wp, 1)
            plot(ax_main, wp(j,1), wp(j,2), 'o', ...
                 'MarkerEdgeColor', color * 0.8, ...
                 'MarkerFaceColor', color * 0.5, ...
                 'MarkerSize', 5, ...
                 'LineWidth', 1.2);
        end
        
        % 3D
        smooth_path_3d = [smooth_path, ones(size(smooth_path,1),1) * targets(i).H];
        plot3(ax_3d, smooth_path_3d(:,1), smooth_path_3d(:,2), smooth_path_3d(:,3), '-', ...
              'Color', [color, 0.3], ...
              'LineWidth', 1.2);
    end
end