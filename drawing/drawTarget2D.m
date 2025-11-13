function [h_marker, h_label, h_traj] = drawTarget2D(sim_state, target_idx)
    % Vẽ mục tiêu trên màn hình 2D
    % Chỉnh: luôn dùng chấm tròn 'o', kích thước phụ thuộc RCS hiệu dụng (theo cự ly)
    
    target = sim_state.targets(target_idx);
    pos = target.pos;           % dùng vị trí hiện tại trong kịch bản có sẵn
    SCH_pos = sim_state.SCH.pos;
    
    % Tính RCS hiệu dụng theo cự ly (đơn giản hóa)
    dist = norm(pos(1:2) - SCH_pos(1:2));
    RCS_eff = computeEffectiveRCS_local(target.RCS, dist, 50000, 0.01, 20);  % ref 50km, clamp [0.01..20]
    
    % Tính điểm Bj (hàm có sẵn trong repo)
    Bj = calculateThreatLevel(target, sim_state.SCH.pos(1:2), sim_state.targets_protect, sim_state.fire_units);
    
    % Lấy màu theo Bj (hàm có sẵn trong repo)
    color = getThreatColor(Bj);
    bg_color = getThreatBackgroundColor(Bj);
    
    % Kích thước marker theo RCS_eff (2D: 8..38 điểm ảnh)
    markerSize = markerSizeFromRCS_local(RCS_eff, 8, 30, 0.01, 20);
    
    % Vẽ marker dạng chấm tròn
    h_marker = plot(sim_state.ax_main, pos(1), pos(2), 'o', ...
        'MarkerSize', markerSize, ...
        'MarkerFaceColor', color, ...
        'MarkerEdgeColor', [1, 1, 1], ...
        'LineWidth', 1.3);
    
    % Tạo label (thêm RCS hiệu dụng)
    dist_to_sch = norm(pos(1:2) - sim_state.SCH.pos(1:2)) / 1000;
    
    if target.priority_from_command
        label_text = sprintf('⚡ %s\n%s\nBj=%.2f ★\nRCS=%.2f | H=%dk | D=%.1fkm', ...
            target.name, target.type, Bj, RCS_eff, ...
            round(target.pos(3)/1000), dist_to_sch);  % ← SỬA ĐÂY
    else
        label_text = sprintf('%s\n%s\nBj=%.2f ★\nRCS=%.2f | H=%dk | D=%.1fkm', ...
            target.name, target.type, Bj, RCS_eff, ...
            round(target.pos(3)/1000), dist_to_sch);  % ← VÀ ĐÂY
    end
    
    h_label = text(sim_state.ax_main, pos(1)+2000, pos(2)+2000, label_text, ...
        'Color', [1, 1, 1], ...
        'FontWeight', 'bold', ...
        'FontSize', 7.5, ...
        'FontName', 'Arial', ...
        'BackgroundColor', bg_color, ...
        'EdgeColor', color, ...
        'LineWidth', 1, ...
        'Margin', 2.5);
    
    % Vẽ quỹ đạo ĐÃ ĐI QUA (thay vì vẽ toàn bộ trajectory)
    if isfield(target, 'trajectory_history') && size(target.trajectory_history, 1) > 1
        h_traj = plot(sim_state.ax_main, ...
            target.trajectory_history(:,1), ...
            target.trajectory_history(:,2), '-', ...
            'Color', color * 0.6, ...
            'LineWidth', 1.8);
    else
        h_traj = gobjects(1);
    end
end

function r = computeEffectiveRCS_local(RCS_base, distance, ref_distance, RCS_min, RCS_max)
    if distance <= 1, distance = 1; end
    dist_factor = sqrt(ref_distance / distance);
    r = RCS_base * dist_factor;
    r = min(max(r, RCS_min), RCS_max);
end

function sz = markerSizeFromRCS_local(RCS_eff, base, span, RCS_min, RCS_max)
    % Chuyển RCS → MarkerSize tuyến tính, có kẹp biên
    x = (RCS_eff - RCS_min) / (RCS_max - RCS_min);
    x = max(0, min(1, x));
    sz = base + span * x;
end