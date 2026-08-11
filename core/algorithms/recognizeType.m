function target_type = recognizeType(target, targetDB)
    %% NHẬN DẠNG DẠNG MỤC TIÊU
    % Mô tả: Nhận dạng loại mục tiêu dựa trên đặc trưng kỹ thuật (Bảng 2)
    % Input:
    %   - target: Cấu trúc mục tiêu
    %   - targetDB: Database đặc trưng kỹ thuật (từ TargetDatabase.mat)
    % Output:
    %   - target_type: Cấu trúc chứa thông tin nhận dạng
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % KHỞI TẠO KẾT QUẢ
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    target_type = struct();
    target_type.name = target.type;
    target_type.category = 'Unknown';
    target_type.confidence = 0;
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % TRÍCH XUẤT THAM SỐ MỤC TIÊU
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    v_current = norm(target.vel);
    H_current = target.pos(3);
    RCS_current = target.RCS;
    n_current = target.maneuver_ability;
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % NHẬN DẠNG DỰA TRÊN TÊN (FAST PATH)
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    type_lower = lower(target.type);
    
    if contains(type_lower, 'b52') || contains(type_lower, 'b-52') || ...
       contains(type_lower, 'chiến lược') || contains(type_lower, 'strategic bomber')
        target_type.category = 'strategic_bomber';
        target_type.confidence = 0.95;
        return;
        
    elseif contains(type_lower, 'tên lửa') || contains(type_lower, 'hành trình') || ...
           contains(type_lower, 'cruise missile') || contains(type_lower, 'tlht')
        target_type.category = 'cruise_missile';
        target_type.confidence = 0.95;
        return;
        
    elseif contains(type_lower, 'ném bom') && ~contains(type_lower, 'chiến lược')
        target_type.category = 'fighter_bomber';
        target_type.confidence = 0.9;
        return;
        
    elseif contains(type_lower, 'tiêm kích') || contains(type_lower, 'fighter')
        target_type.category = 'tactical_fighter';
        target_type.confidence = 0.9;
        return;
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % NHẬN DẠNG DỰA TRÊN ĐẶC TRƯNG KỸ THUẬT (SLOW PATH)
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % Nếu không nhận dạng được qua tên, sử dụng đặc trưng kỹ thuật
    
    if nargin < 2 || isempty(targetDB)
        % Không có database, sử dụng logic đơn giản
        if RCS_current < 1 && v_current > 800
            target_type.category = 'cruise_missile';
            target_type.confidence = 0.7;
        elseif RCS_current > 10
            target_type.category = 'strategic_bomber';
            target_type.confidence = 0.6;
        elseif n_current > 7
            target_type.category = 'tactical_fighter';
            target_type.confidence = 0.6;
        else
            target_type.category = 'fighter_bomber';
            target_type.confidence = 0.5;
        end
        return;
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % SO SÁNH VỚI DATABASE
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    best_match = 'Unknown';
    best_score = 0;
    
    categories = fieldnames(targetDB);
    for i = 1:length(categories)
        cat = categories{i};
        db_entry = targetDB.(cat);
        
        % Tính điểm phù hợp (0-1)
        score = 0;
        
        % Kiểm tra vận tốc
        if v_current >= db_entry.v_min && v_current <= db_entry.v_max
            score = score + 0.3;
        end
        
        % Kiểm tra độ cao
        if H_current >= db_entry.H_min && H_current <= db_entry.H_max
            score = score + 0.2;
        end
        
        % Kiểm tra RCS
        if RCS_current >= db_entry.RCS_min && RCS_current <= db_entry.RCS_max
            score = score + 0.3;
        end
        
        % Kiểm tra khả năng cơ động
        if n_current >= db_entry.n_min && n_current <= db_entry.n_max
            score = score + 0.2;
        end
        
        if score > best_score
            best_score = score;
            best_match = cat;
        end
    end
    
    target_type.category = best_match;
    target_type.confidence = best_score;
    
end
