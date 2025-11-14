function [target_type, confidence, detailed_match] = classifyTarget(target)
    %% NHẬN DẠNG LOẠI MỤC TIÊU
    % Dựa vào Bảng 2: Đặc trưng kỹ thuật bay của mục tiêu
    % 
    % Input:
    %   target - struct chứa thông tin mục tiêu
    % Output:
    %   target_type - loại mục tiêu (string)
    %   confidence - độ tin cậy (0-100)
    %   detailed_match - struct chi tiết các tham số khớp
    
    % ═══════════════════════════════════════════════════════
    % LẤY THÔNG TIN ĐẶC TRƯNG TỪ TARGET
    % ═══════════════════════════════════════════════════════
    
    % RCS (m²)
    if isfield(target, 'RCS_eff')
        RCS = target.RCS_eff;
    else
        RCS = target.RCS;
    end
    
    % Vận tốc (m/s)
    V = target.speed;
    
    % Độ cao (m)
    H = target.pos(3);
    
    % Khả năng cơ động (G)
    if isfield(target, 'maneuver_ability')
        n = target.maneuver_ability;
    else
        n = 5;  % Mặc định
    end
    
    % Gia tốc (m/s²) - nếu cần
    if isfield(target, 'current_accel')
        a = target.current_accel;
    else
        a = 0;
    end
    
    % ═══════════════════════════════════════════════════════
    % BẢNG 2: ĐẶC TRƯNG KỸ THUẬT BAY CỦA MỤC TIÊU
    % ═══════════════════════════════════════════════════════
    % 
    % | Loại MB   | RCS (m²) | V (m/s)   | H (m)        | n (G)   |
    % |-----------|----------|-----------|--------------|---------|
    % | B52       | 5-20     | 250-700   | 100-19000    | 2-4     |
    % | TK-NB     | 2-5      | 320-750   | 50-18000     | 5-6     |
    % | TK-CT     | 1-5      | 350-750   | 50-22000     | 6.5-9   |
    % | TLHT      | 0.01-2.5 | 250-1200  | 60-40000     | 1-2     |
    % 
    % ═══════════════════════════════════════════════════════
    
    % Danh sách các loại mục tiêu với đặc trưng
    aircraft_types = {
        struct('name', 'MBNB chiến lược', ...
               'RCS_min', 5, 'RCS_max', 20, ...
               'V_min', 250, 'V_max', 700, ...
               'H_min', 100, 'H_max', 19000, ...
               'n_min', 2, 'n_max', 4);
        
        struct('name', 'TK ném bom', ...
               'RCS_min', 2, 'RCS_max', 5, ...
               'V_min', 320, 'V_max', 750, ...
               'H_min', 50, 'H_max', 18000, ...
               'n_min', 5, 'n_max', 6);
        
        struct('name', 'TK chiến thuật', ...
               'RCS_min', 1, 'RCS_max', 5, ...
               'V_min', 350, 'V_max', 750, ...
               'H_min', 50, 'H_max', 22000, ...
               'n_min', 6.5, 'n_max', 9);
        
        struct('name', 'TL hành trình', ...
               'RCS_min', 0.01, 'RCS_max', 2.5, ...
               'V_min', 250, 'V_max', 1200, ...
               'H_min', 60, 'H_max', 40000, ...
               'n_min', 1, 'n_max', 2);
    };
    
    % ═══════════════════════════════════════════════════════
    % TÍNH ĐIỂM KHỚP CHO TỪNG LOẠI
    % ═══════════════════════════════════════════════════════
    best_score = 0;
    best_type = 'Không xác định';
    best_match = struct('RCS', 0, 'V', 0, 'H', 0, 'n', 0);
    
    for i = 1:length(aircraft_types)
        type_spec = aircraft_types{i};
        
        % Tính điểm khớp cho từng tham số (0-100)
        score_RCS = calculateMatchScore(RCS, type_spec.RCS_min, type_spec.RCS_max);
        score_V = calculateMatchScore(V, type_spec.V_min, type_spec.V_max);
        score_H = calculateMatchScore(H, type_spec.H_min, type_spec.H_max);
        score_n = calculateMatchScore(n, type_spec.n_min, type_spec.n_max);
        
        % ───────────────────────────────────────────────────
        % TRỌNG SỐ CÁC THAM SỐ (tổng = 1.0)
        % ───────────────────────────────────────────────────
        w_RCS = 0.35;  % RCS quan trọng nhất (35%)
        w_V   = 0.25;  % Vận tốc (25%)
        w_n   = 0.25;  % Cơ động (25%)
        w_H   = 0.15;  % Độ cao (15%)
        
        % Tính điểm tổng có trọng số
        total_score = w_RCS * score_RCS + ...
                      w_V * score_V + ...
                      w_H * score_H + ...
                      w_n * score_n;
        
        % Cập nhật loại tốt nhất
        if total_score > best_score
            best_score = total_score;
            best_type = type_spec.name;
            best_match.RCS = score_RCS;
            best_match.V = score_V;
            best_match.H = score_H;
            best_match.n = score_n;
        end
    end
    
    % ═══════════════════════════════════════════════════════
    % XÁC ĐỊNH ĐỘ TIN CẬY
    % ═══════════════════════════════════════════════════════
    if best_score >= 90
        confidence = 95;  % Rất chắc chắn
    elseif best_score >= 75
        confidence = 85;  % Khá chắc chắn
    elseif best_score >= 60
        confidence = 70;  % Trung bình
    elseif best_score >= 40
        confidence = 55;  % Thấp
    else
        confidence = 40;  % Rất thấp
        best_type = 'Không xác định';
    end
    
    % ═══════════════════════════════════════════════════════
    % TRẢ VỀ KẾT QUẢ
    % ═══════════════════════════════════════════════════════
    target_type = best_type;
    
    detailed_match = struct( ...
        'total_score', best_score, ...
        'RCS_match', best_match.RCS, ...
        'V_match', best_match.V, ...
        'H_match', best_match.H, ...
        'n_match', best_match.n, ...
        'measured_RCS', RCS, ...
        'measured_V', V, ...
        'measured_H', H, ...
        'measured_n', n ...
    );
end

% ═══════════════════════════════════════════════════════
% HÀM PHỤ: TÍNH ĐIỂM KHỚP CHO 1 THAM SỐ
% ═══════════════════════════════════════════════════════
function score = calculateMatchScore(value, min_val, max_val)
    %% TÍNH ĐIỂM KHỚP (0-100)
    % value: giá trị đo được
    % min_val, max_val: khoảng giá trị chuẩn
    
    % Nếu nằm trong khoảng → điểm cao
    if value >= min_val && value <= max_val
        % Tính vị trí trong khoảng (càng giữa càng tốt)
        center = (min_val + max_val) / 2;
        range = max_val - min_val;
        
        if range > 0
            % Khoảng cách đến tâm (chuẩn hóa)
            distance_from_center = abs(value - center) / (range / 2);
            
            % Điểm cao nếu gần tâm
            score = 100 * (1 - 0.2 * distance_from_center);
        else
            score = 100;
        end
        
    else
        % Nằm ngoài khoảng → tính mức độ lệch
        if value < min_val
            % Nhỏ hơn min
            deviation = (min_val - value) / min_val;
        else
            % Lớn hơn max
            deviation = (value - max_val) / max_val;
        end
        
        % Phạt theo mức độ lệch (càng lệch càng thấp điểm)
        score = max(0, 100 * (1 - deviation));
    end
    
    % Đảm bảo trong khoảng [0, 100]
    score = max(0, min(100, score));
end