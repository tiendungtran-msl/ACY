function drawPlannedPaths(ax_main, ax_3d, targets)
    %% VẼ ĐƯỜNG DỰ KIẾN (CHỈ VẼ 3D)
    % 2D: KHÔNG VẼ GÌ - quỹ đạo chỉ hiện sau khi mục tiêu đi qua
    
    for i = 1:length(targets)
        smooth_path = targets(i).smooth_path;
        wp = targets(i).waypoints;
        color = targets(i).color;
        
        if size(smooth_path, 2) < 3 || size(wp, 2) < 3
            continue;
        end
        
        % ════════════════════════════════════════════
        % 3D - Vẽ đường cong 3D đầy đủ
        % ════════════════════════════════════════════
        light_col = lightenColor(color, 0.3);
        plot3(ax_3d, smooth_path(:,1), smooth_path(:,2), smooth_path(:,3), '--', ...
              'Color', light_col, ...
              'LineWidth', 1.0);
        
        % Waypoints 3D
        for j = 1:size(wp, 1)
            plot3(ax_3d, wp(j,1), wp(j,2), wp(j,3), 'o', ...
                  'MarkerEdgeColor', color * 0.8, ...
                  'MarkerFaceColor', color * 0.5, ...
                  'MarkerSize', 6, ...
                  'LineWidth', 1.2);
        end
    end
    
    % ════════════════════════════════════════════
    % 2D - KHÔNG VẼ GÌ CẢ
    % ════════════════════════════════════════════
end

function c = lightenColor(color, alpha)
    c = color * (1 - alpha) + [1, 1, 1] * alpha;
    c = max(0, min(1, c));
end