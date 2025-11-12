function Bj = Block6p_CalculateBj(target, SCH, targets_protect, fire_units, cfg)
    %% KHỐI 6': TÍNH MỨC ĐỘ QUAN TRỌNG Bⱼ THEO 8 QUY TẮC
    % Mô tả: Tính điểm ưu tiên Bⱼ theo 8 quy tắc đánh giá
    % Input:
    %   - target: Cấu trúc mục tiêu
    %   - SCH: Sở Chỉ Huy
    %   - targets_protect: Danh sách đối tượng bảo vệ
    %   - fire_units: Danh sách đơn vị hỏa lực
    %   - cfg: Cấu hình hệ thống (optional)
    % Output:
    %   - Bj: Mức độ quan trọng (0-10)
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % TẢI CẤU HÌNH
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if nargin < 5
        cfg = config();
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % KHỐI 2: KIỂM TRA VÙNG PHÂN PHỐI
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    in_zone = Block2_CheckZone(target.pos, SCH.pos, ...
        cfg.distribution_range_min, cfg.distribution_range_max);
    
    if ~in_zone
        Bj = 0;
        return;
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % QUY TẮC 1: CHỈ THỊ TỪ CẤP TRÊN (Ưu tiên tuyệt đối)
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if target.priority_from_command
        Bj = cfg.command_priority_score;
        return;
    end
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % TÍNH ĐIỂM THEO CÁC QUY TẮC 2-8
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    score = 0;
    
    % Sử dụng hàm calculateThreatLevel hiện có (đã implement đầy đủ 8 quy tắc)
    Bj = calculateThreatLevel(target, SCH.pos(1:2), targets_protect, fire_units);
    
end
