function Bj = calculateThreatLevel(target, SCH_pos, targets_protect, fire_units)
    %% TÍNH MỨC ĐỘ QUAN TRỌNG CỦA MỤC TIÊU (8 QUY TẮC)
    %
    % Output: Bj ∈ [0, 1]
    
    % Kiểm tra vùng phân phối 50km
    DISTRIBUTION_RANGE_MAX = 50000;
    dist_to_SCH = norm(target.pos(1:2) - SCH_pos);
    
    if dist_to_SCH > DISTRIBUTION_RANGE_MAX
        Bj = 0;
        return;
    end
    
    % QUY TẮC 1: Lệnh cấp trên (inline - ưu tiên tuyệt đối)
    if target.priority_from_command
        Bj = 1.0;
        return;
    end
    
    % Chuẩn bị all_targets (tạm thời dùng chỉ 1 target)
    all_targets = target;
    
    % Tính điểm các quy tắc (gọi hàm trong rules/)
    R2 = targetTypeRule(target);
    R3 = tacticalTypeRule(target, all_targets);
    R4 = formationSizeRule(target, all_targets);

    SCH_struct = struct('pos', [SCH_pos(1), SCH_pos(2), 0]);
    R5 = missionPredictRule(target, SCH_struct, targets_protect, fire_units);
    R6 = trajectoryThreatRule(target, targets_protect);
    R7 = timeToKillRule(target, fire_units);
    R8 = optimalPositionRule(target, fire_units);
    
    % Trọng số (tổng = 1.0)
    w2 = 0.20;  % Loại mục tiêu
    w3 = 0.10;  % Dạng tác chiến
    w4 = 0.10;  % Số lượng
    w5 = 0.15;  % Nhiệm vụ
    w6 = 0.15;  % Hướng bay
    w7 = 0.15;  % Thời gian tiếp cận
    w8 = 0.15;  % Vị trí tối ưu
    
    % Tính tổng có trọng số
    Bj = w2*R2 + w3*R3 + w4*R4 + w5*R5 + w6*R6 + w7*R7 + w8*R8;
    
    % Đảm bảo trong khoảng [0, 10]
    Bj = max(0, min(10, Bj))/10;
end