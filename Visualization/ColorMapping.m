function color = ColorMapping(priority, cfg)
    %% ÁNH XẠ MÀU THEO MỨC ĐỘ QUAN TRỌNG
    % Mô tả: Chuyển đổi mức độ ưu tiên thành màu sắc gradient
    % Input:
    %   - priority: Mức độ ưu tiên (0-1)
    %   - cfg: Cấu hình hệ thống (optional)
    % Output:
    %   - color: Vector màu RGB [R, G, B]
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % TẢI CẤU HÌNH MẶC ĐỊNH
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if nargin < 2
        cfg = config();
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % GRADIENT MÀU SẮC THEO NGƯỠNG
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % Đỏ tươi (Priority ≥ 0.8): Cực nguy hiểm
    % Đỏ cam (0.6 ≤ Priority < 0.8): Nguy hiểm cao
    % Cam (0.4 ≤ Priority < 0.6): Nguy hiểm trung bình
    % Vàng (0.2 ≤ Priority < 0.4): Nguy hiểm thấp
    % Xanh lá (Priority < 0.2): Ít nguy hiểm
    
    if priority >= cfg.priority_threshold_critical
        % Đỏ tươi
        color = cfg.color_critical;
        
    elseif priority >= cfg.priority_threshold_high
        % Đỏ cam
        color = cfg.color_high;
        
    elseif priority >= cfg.priority_threshold_medium
        % Cam
        color = cfg.color_medium;
        
    elseif priority >= cfg.priority_threshold_low
        % Vàng
        color = cfg.color_low;
        
    else
        % Xanh lá
        color = cfg.color_minimal;
    end
    
end
