function [h_marker, h_label, h_traj] = drawTarget3D(sim_state, target_idx)
    %% VẼ MỤC TIÊU TRÊN MÀN HÌNH 3D
    % Output: [h_marker, h_label, h_traj]
    
    target = sim_state.targets(target_idx);
    pos = target.pos;  % [x, y, z]
    
    % Lấy RCS_eff và distance
    if isfield(target, 'RCS_eff')
        RCS_eff = target.RCS_eff;
    else
        RCS_eff = target.RCS;
    end
    
    if isfield(target, 'distance_to_DVHL')
        distance = target.distance_to_DVHL;
    else
        distance = inf;
    end
    
    % Tính điểm Bj
    Bj = calculateThreatLevel(target, sim_state.SCH.pos(1:2), ...
        sim_state.targets_protect, sim_state.fire_units);
    
    % Lấy màu theo Bj
    color = getThreatColor(Bj);
    bg_color = getThreatBackgroundColor(Bj);
    
    % Kích thước marker CỐ ĐỊNH (KHÔNG thay đổi theo RCS)
    markerSize = 12;  % Kích thước cố định cho tất cả mục tiêu
    
    % Vẽ marker (chấm tròn)
    h_marker = plot3(sim_state.ax_3d, pos(1), pos(2), pos(3), 'o', ...
        'MarkerSize', markerSize, ...
        'MarkerFaceColor', color, ...
        'MarkerEdgeColor', [1, 1, 1], ...
        'LineWidth', 1.3);
    
    % Label với thông tin RCS, độ cao, khoảng cách
    dist_to_sch = norm(pos(1:2) - sim_state.SCH.pos(1:2)) / 1000;
    
    if target.priority_from_command
        label_text = sprintf('⚡ %s\nBj=%.2f ★\nRCS=%.2f | H=%dk', ...
            target.name, Bj, RCS_eff, round(pos(3)/1000));
    else
        label_text = sprintf('%s\nBj=%.2f ★\nRCS=%.2f | H=%dk', ...
            target.name, Bj, RCS_eff, round(pos(3)/1000));
    end
    
    h_label = text(sim_state.ax_3d, pos(1), pos(2), pos(3)+1500, label_text, ...
        'Color', [1, 1, 1], ...
        'FontWeight', 'bold', ...
        'FontSize', 7.5, ...
        'FontName', 'Arial', ...
        'BackgroundColor', bg_color, ...
        'EdgeColor', color, ...
        'LineWidth', 1, ...
        'Margin', 2);
    
    % Vẽ quỹ đạo 3D (toàn bộ trajectory)
    if isfield(sim_state, 'trajectories') && ...
       length(sim_state.trajectories) >= target_idx && ...
       ~isempty(sim_state.trajectories{target_idx})
        
        traj = sim_state.trajectories{target_idx};
        
        if size(traj, 1) > 1
            h_traj = plot3(sim_state.ax_3d, traj(:,1), traj(:,2), traj(:,3), '-', ...
                'Color', color * 0.6, ...
                'LineWidth', 1.8);
        else
            h_traj = gobjects(1);
        end
    else
        h_traj = gobjects(1);
    end
end

function sz = markerSizeFromRCS_local(RCS_eff, base, span, RCS_min, RCS_max)
    %% CHUYỂN RCS → MARKERSIZE
    % Ánh xạ tuyến tính từ [RCS_min, RCS_max] → [base, base+span]
    
    if RCS_max <= RCS_min
        sz = base + span / 2;
        return;
    end
    
    x = (RCS_eff - RCS_min) / (RCS_max - RCS_min);
    x = max(0, min(1, x));  % Clamp [0, 1]
    sz = base + x * span;
end