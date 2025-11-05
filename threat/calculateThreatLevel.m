function Bj = calculateThreatLevel(target, SCH_pos, targets_protect)
    % Tính điểm nguy hiểm theo 8 quy tắc
    
    score = 0;
    
    % QUY TẮC 1: Chỉ thị từ cấp trên
    if target.priority_from_command
        score = score + 150;
    end
    
    % QUY TẮC 2: Vũ khí hủy diệt hàng loạt
    if contains(target.type, 'B52', 'IgnoreCase', true) || ...
       contains(target.type, 'ném bom chiến lược', 'IgnoreCase', true)
        score = score + 100;
    elseif contains(target.type, 'ném bom', 'IgnoreCase', true)
        score = score + 85;
    end
    
    % QUY TẮC 3: Dạng tác chiến
    switch target.jam_type
        case 'Chủ động'
            score = score + 90;
        case 'Được che phủ'
            score = score + 75;
        case 'Thụ động'
            score = score + 60;
    end
    
    % Cơ động cao
    if target.maneuver_ability > 7
        score = score + 70;
    elseif target.maneuver_ability > 5
        score = score + 50;
    end
    
    % Tấn công SCH
    if contains(target.task, 'SCH', 'IgnoreCase', true) || ...
       contains(target.task, 'Tấn công', 'IgnoreCase', true)
        score = score + 80;
    end
    
    % QUY TẮC 4: Số lượng nhóm
    if target.group_size >= 4
        score = score + 70;
    elseif target.group_size >= 2
        score = score + 50;
    end
    
    % QUY TẮC 5: Nhiệm vụ
    if contains(target.task, 'hậu phương', 'IgnoreCase', true) || ...
       contains(target.task, 'Tiêu diệt', 'IgnoreCase', true)
        score = score + 75;
    elseif contains(target.task, 'chế áp', 'IgnoreCase', true)
        score = score + 70;
    elseif contains(target.task, 'yểm trợ', 'IgnoreCase', true)
        score = score + 50;
    end
    
    % QUY TẮC 6: Hướng bay đến MTBV
    best_angle = -1;
    for i = 1:length(targets_protect)
        protected_pos = targets_protect(i).pos(1:2);
        dir_to_protected = protected_pos - target.pos(1:2);
        
        if norm(target.vel(1:2)) > 0 && norm(dir_to_protected) > 0
            cos_angle = dot(target.vel(1:2), dir_to_protected) / ...
                        (norm(target.vel(1:2)) * norm(dir_to_protected));
            if cos_angle > best_angle
                best_angle = cos_angle;
            end
        end
    end
    
    if best_angle > 0.9
        score = score + 70;
    elseif best_angle > 0.7
        score = score + 50;
    elseif best_angle > 0.3
        score = score + 30;
    end
    
    % QUY TẮC 7: Thời gian vào vùng
    D_pz = 35000;
    dist_to_SCH = norm(target.pos(1:2) - SCH_pos);
    
    if dist_to_SCH <= D_pz
        score = score + 80;
    elseif norm(target.vel(1:2)) > 0
        dir_to_SCH = SCH_pos - target.pos(1:2);
        cos_angle = dot(target.vel(1:2), dir_to_SCH) / ...
                    (norm(target.vel(1:2)) * norm(dir_to_SCH) + eps);
        
        if cos_angle > 0
            time_to_zone = (dist_to_SCH - D_pz) / (norm(target.vel(1:2)) * cos_angle);
            
            if time_to_zone < 30
                score = score + 70;
            elseif time_to_zone < 60
                score = score + 50;
            elseif time_to_zone < 120
                score = score + 30;
            end
        end
    end
    
    % QUY TẮC 8: Vị trí so với phân giác
    angle_to_target = atan2(target.pos(2) - SCH_pos(2), ...
                           target.pos(1) - SCH_pos(1));
    bisector_angle = pi/2;
    angle_diff = abs(wrapToPi(angle_to_target - bisector_angle));
    
    if angle_diff < pi/12
        score = score + 60;
    elseif angle_diff < pi/6
        score = score + 40;
    elseif angle_diff < pi/4
        score = score + 20;
    end
    
    % Chuẩn hóa về thang 0-10
    Bj = min(score / 80, 10);
end