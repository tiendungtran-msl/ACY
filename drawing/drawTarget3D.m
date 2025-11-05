function [h_marker, h_label, h_traj] = drawTarget3D(sim_state, target_idx)
    % Vẽ mục tiêu trên màn hình 3D
    
    target = sim_state.targets(target_idx);
    pos = target.pos;
    
    % Tính điểm Bj
    Bj = calculateThreatLevel(target, sim_state.SCH.pos(1:2), sim_state.targets_protect);
    
    % Lấy màu
    color = getThreatColor(Bj);
    bg_color = getThreatBackgroundColor(Bj);
    
    % Vẽ marker
    h_marker = plot3(sim_state.ax_3d, pos(1), pos(2), pos(3), target.marker, ...
        'MarkerSize', 10, ...
        'MarkerFaceColor', color, ...
        'MarkerEdgeColor', [1, 1, 1], ...
        'LineWidth', 1.2);
    
    % Label đơn giản
    label_text = sprintf('%s\nBj=%.1f', target.name, Bj);
    
    h_label = text(sim_state.ax_3d, pos(1), pos(2), pos(3)+1500, label_text, ...
        'Color', [1, 1, 1], ...
        'FontSize', 7.5, ...
        'FontName', 'Arial', ...
        'BackgroundColor', bg_color, ...
        'EdgeColor', 'none', ...
        'Margin', 1.5);
    
    % Vẽ quỹ đạo
    traj = sim_state.trajectories{target_idx};
    if size(traj, 1) > 1
        h_traj = plot3(sim_state.ax_3d, traj(:,1), traj(:,2), traj(:,3), '-', ...
            'Color', [color, 0.6], ...
            'LineWidth', 1.8);
    else
        h_traj = gobjects(1);
    end
end