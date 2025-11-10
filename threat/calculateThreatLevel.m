function Bj = calculateThreatLevel(target, SCH_pos, targets_protect, fire_units)
    %% TÍNH MỨC ĐỘ QUAN TRỌNG CỦA MỤC TIÊU
      
       % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % BƯỚC 0: KIỂM TRA MỤC TIÊU CÓ TRONG VÙNG PHÂN PHỐI KHÔNG
    % Vùng phân phối: Tâm tại SCH, bán kính 300m - 50km
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    % Tham số vùng phân phối
    DISTRIBUTION_RANGE_MIN = 300;     % Cự ly gần: 300m
    DISTRIBUTION_RANGE_MAX = 50000;   % Cự ly xa: 50km
    
    % Tính khoảng cách từ mục tiêu đến SCH (tâm vùng phân phối)
    dist_to_SCH = norm(target.pos(1:2) - SCH_pos);
    
    % Kiểm tra có trong vùng phân phối không
    in_distribution_zone = (dist_to_SCH >= DISTRIBUTION_RANGE_MIN && ...
                           dist_to_SCH <= DISTRIBUTION_RANGE_MAX);
    
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % NẾU KHÔNG TRONG VÙNG PHÂN PHỐI MỤC TIÊU
    % → Bj = 0 (KHÔNG XÉT TIẾP)
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    if ~in_distribution_zone
        Bj = 0;
        return;
    end
    
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % TÌM ĐƠN VỊ HỎA LỰC GẦN NHẤT (CHO QUY TẮC 7, 8)
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    closest_fire_unit_idx = 0;
    min_dist = inf;
    
    for i = 1:length(fire_units)
        dist = norm(target.pos(1:2) - fire_units(i).pos(1:2));
        if dist < min_dist
            min_dist = dist;
            closest_fire_unit_idx = i;
        end
    end
    
    % Lấy đơn vị hỏa lực gần nhất
    closest_unit = fire_units(closest_fire_unit_idx);
    dist_to_unit = min_dist;
    
    % Vùng tối ưu của vùng phân phối (từ SCH)
    optimal_range = (DISTRIBUTION_RANGE_MIN + DISTRIBUTION_RANGE_MAX) / 2;  % 25150 m
    
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % QUY TẮC 1: CHỈ THỊ TỪ CẤP TRÊN (ƯU TIÊN TUYỆT ĐỐI)
    % Nếu có chỉ thị → Bj = 10, KHÔNG XÉT CÁC QUY TẮC TIẾP
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    if target.priority_from_command
        Bj = 10;
        return;
    end
    
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % NẾU KHÔNG CÓ CHỈ THỊ → XÉT TUẦN TỰ CÁC QUY TẮC 2-8
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    score = 0;
    
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % QUY TẮC 2: DẠNG MỤC TIÊU
    % Mục tiêu mang vũ khí sát thương hàng loạt nguy hiểm nhất
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    if contains(target.type, 'B52', 'IgnoreCase', true) || ...
       contains(target.type, 'B-52', 'IgnoreCase', true) || ...
       contains(target.type, 'ném bom chiến lược', 'IgnoreCase', true) || ...
       contains(target.type, 'strategic bomber', 'IgnoreCase', true) || ...
       contains(target.type, 'chiến lược', 'IgnoreCase', true)
        score = score + 100;  % Vũ khí hủy diệt hàng loạt
        
    elseif contains(target.type, 'ném bom', 'IgnoreCase', true) || ...
           contains(target.type, 'bomber', 'IgnoreCase', true)
        score = score + 85;   % Máy bay ném bom thông thường
        
    elseif contains(target.type, 'tên lửa', 'IgnoreCase', true) || ...
           contains(target.type, 'hành trình', 'IgnoreCase', true) || ...
           contains(target.type, 'cruise missile', 'IgnoreCase', true) || ...
           contains(target.type, 'TLHT', 'IgnoreCase', true)
        score = score + 90;   % Tên lửa hành trình
        
    elseif contains(target.type, 'tiêm kích', 'IgnoreCase', true) || ...
           contains(target.type, 'fighter', 'IgnoreCase', true)
        score = score + 70;   % Tiêm kích thông thường
    end
    
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % QUY TẮC 3: DẠNG TÁC CHIẾN
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    % 3.1. Máy bay gây nhiễu điện tử
    switch target.jam_type
        case 'Chủ động'
            score = score + 95;   % Gây nhiễu chủ động - nguy hiểm nhất
        case 'Được che phủ'
            score = score + 80;   % Được che phủ bởi nhiễu
        case 'Thụ động'
            score = score + 65;   % Gây nhiễu thụ động
        otherwise
            score = score + 0;    % Không gây nhiễu
    end
    
    % 3.2. Máy bay có khả năng cơ động cao
    if target.maneuver_ability > 7
        score = score + 70;       % Cực kỳ linh hoạt (> 7G)
    elseif target.maneuver_ability > 5
        score = score + 50;       % Cơ động cao (5-7G)
    elseif target.maneuver_ability > 3
        score = score + 30;       % Cơ động trung bình (3-5G)
    else
        score = score + 10;       % Cơ động thấp (< 3G)
    end
    
    % 3.3. Máy bay tấn công SCH và trạm điều khiển hỏa lực
    task_lower = lower(target.task);
    if contains(task_lower, 'sch') || ...
       contains(task_lower, 'chỉ huy') || ...
       contains(task_lower, 'tấn công') || ...
       contains(task_lower, 'attack') || ...
       contains(task_lower, 'command center')
        score = score + 85;       % Tấn công trực tiếp SCH
    end
    
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % QUY TẮC 4: SỐ LƯỢNG THÀNH PHẦN VÀ TRÌNH TỰ CHIẾN ĐẤU
    % Nhóm lớn → Nhóm nhỏ → Đơn độc
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    if target.group_size >= 4
        score = score + 75;       % Nhóm lớn (≥ 4)
    elseif target.group_size >= 2
        score = score + 55;       % Nhóm nhỏ (2-3)
    else
        score = score + 25;       % Đơn độc (1)
    end
    
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % QUY TẮC 5: NHIỆM VỤ (Ưu tiên từ cao → thấp)
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    if (contains(task_lower, 'hậu phương') && ...
       contains(task_lower, 'tiêu diệt')) || ...
       (contains(task_lower, 'rear') && ...
       contains(task_lower, 'destroy'))
        score = score + 80;       % Tiêu diệt lực lượng hậu phương
        
    elseif contains(task_lower, 'chế áp') || ...
           contains(task_lower, 'suppress') || ...
           contains(task_lower, 'hỏa lực')
        score = score + 75;       % Chế áp hỏa lực/SCH
        
    elseif contains(task_lower, 'yểm trợ') || ...
           contains(task_lower, 'support') || ...
           contains(task_lower, 'cover')
        score = score + 55;       % Yểm trợ tác chiến
        
    elseif contains(task_lower, 'trinh sát') || ...
           contains(task_lower, 'recon')
        score = score + 45;       % Trinh sát mặt đất
        
    elseif contains(task_lower, 'phân tán') || ...
           contains(task_lower, 'distract') || ...
           contains(task_lower, 'decoy')
        score = score + 30;       % Phân tán SCH
    end
    
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % QUY TẮC 6: HƯỚNG BAY SO VỚI ĐỐI TƯỢNG BẢO VỆ
    % Mục tiêu bay qua vị trí đối tượng bảo vệ quan trọng nhất
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    max_threat_to_protected = 0;
    
    for i = 1:length(targets_protect)
        protected_pos = targets_protect(i).pos(1:2);
        dir_to_protected = protected_pos - target.pos(1:2);
        dist_to_protected = norm(dir_to_protected);
        
        if norm(target.vel(1:2)) > 0 && dist_to_protected > 0
            % Cos góc giữa vector vận tốc và hướng đến MTBV
            cos_angle = dot(target.vel(1:2), dir_to_protected) / ...
                        (norm(target.vel(1:2)) * dist_to_protected);
            
            % Điểm dựa trên góc
            if cos_angle > 0.95       % < 18° - Bay thẳng vào
                angle_score = 85;
            elseif cos_angle > 0.87   % 18-30°
                angle_score = 70;
            elseif cos_angle > 0.7    % 30-45°
                angle_score = 55;
            elseif cos_angle > 0.5    % 45-60°
                angle_score = 35;
            elseif cos_angle > 0      % 60-90°
                angle_score = 15;
            else                      % Bay ra xa
                angle_score = 0;
            end
            
            % Hệ số khoảng cách (gần hơn → nguy hiểm hơn)
            if dist_to_protected < 5000       % < 5km
                distance_factor = 1.5;
            elseif dist_to_protected < 10000  % < 10km
                distance_factor = 1.3;
            elseif dist_to_protected < 20000  % < 20km
                distance_factor = 1.1;
            else
                distance_factor = 1.0;
            end
            
            threat_score = angle_score * distance_factor;
            
            if threat_score > max_threat_to_protected
                max_threat_to_protected = threat_score;
            end
        end
    end
    
    score = score + max_threat_to_protected;
    
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % QUY TẮC 7: THỜI GIAN VÀO VÙNG TIÊU DIỆT (Sớm nhất)
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    % Vị trí tối ưu trong vùng tiêu diệt
    optimal_range = (closest_unit.range_min + closest_unit.range_max) / 2;
    
    % Kiểm tra vị trí hiện tại
    if dist_to_unit >= closest_unit.range_min && ...
       dist_to_unit <= closest_unit.range_max
        
        % ĐÃ TRONG VÙNG TIÊU DIỆT
        dist_to_optimal = abs(dist_to_unit - optimal_range);
        
        if dist_to_optimal < 3000         % Trong vùng tối ưu (±3km)
            score = score + 95;
        elseif dist_to_optimal < 7000     % Gần vùng tối ưu (±7km)
            score = score + 75;
        elseif dist_to_optimal < 12000    % Xa vùng tối ưu
            score = score + 55;
        else                              % Rất xa vùng tối ưu
            score = score + 35;
        end
        
    else
        % CHƯA TRONG VÙNG, tính thời gian tiếp cận
        if norm(target.vel(1:2)) > 0
            dir_to_unit = closest_unit.pos(1:2) - target.pos(1:2);
            cos_approach = dot(target.vel(1:2), dir_to_unit) / ...
                          (norm(target.vel(1:2)) * norm(dir_to_unit));
            
            if cos_approach > 0  % Đang bay vào vùng
                time_to_zone = (dist_to_unit - closest_unit.range_max) / ...
                              (norm(target.vel(1:2)) * cos_approach);
                
                if time_to_zone < 20          % < 20s
                    score = score + 90;
                elseif time_to_zone < 40      % 20-40s
                    score = score + 70;
                elseif time_to_zone < 60      % 40-60s
                    score = score + 50;
                elseif time_to_zone < 120     % 1-2 phút
                    score = score + 30;
                end
            end
        end
    end
    
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % QUY TẮC 8: VỊ TRÍ SO VỚI ĐƯỜNG PHÂN GIÁC VÙNG TIÊU DIỆT
    % Mục tiêu gần phân giác có hiệu quả bắn cao nhất
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    % Góc từ ĐVHL đến mục tiêu
    angle_to_target = atan2(target.pos(2) - closest_unit.pos(2), ...
                           target.pos(1) - closest_unit.pos(1));
    
    % Đường phân giác (giả định hướng Bắc = π/2)
    bisector_angle = pi/2;
    
    % Độ lệch so với phân giác
    angle_diff = abs(wrapToPi(angle_to_target - bisector_angle));
    
    if angle_diff < pi/12             % < 15°
        score = score + 80;
    elseif angle_diff < pi/6          % 15-30°
        score = score + 60;
    elseif angle_diff < pi/4          % 30-45°
        score = score + 40;
    elseif angle_diff < pi/3          % 45-60°
        score = score + 20;
    end
    
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % CHUẨN HÓA VỀ THANG 0-10
    % ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    % Tổng điểm tối đa lý thuyết: ~750 điểm
    % Chia cho 75 để chuẩn hóa về 0-10
    Bj = min(score / 75, 10);
    
    % Đảm bảo Bj >= 1 nếu trong vùng tiêu diệt
    if Bj < 1
        Bj = 1;
    end
end