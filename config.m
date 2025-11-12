%% ============================================================
%% CẤU HÌNH HỆ THỐNG TỰ ĐỘNG HÓA CHỈ HUY PHÒNG KHÔNG
%% ============================================================
% Tác giả: Trần Tiến Dũng
% Ngày: 2025-11-12
% Mô tả: File cấu hình các tham số hệ thống
%% ============================================================

function cfg = config()
    %% CONFIG - Trả về cấu trúc cấu hình hệ thống
    
    cfg = struct();
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % CẤU HÌNH VÙNG PHÂN PHỐI (DISTRIBUTION ZONE)
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    cfg.distribution_range_min = 300;      % Cự ly gần: 300m
    cfg.distribution_range_max = 50000;    % Cự ly xa: 50km
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % CẤU HÌNH MÔ PHỎNG
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    cfg.simulation_dt = 1;                 % Bước thời gian: 1 giây
    cfg.simulation_max_time = 200;         % Thời gian tối đa: 200 giây
    cfg.animation_pause = 0.05;            % Độ trễ animation: 50ms
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % CẤU HÌNH HỆ TỌA ĐỘ
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    cfg.coordinate_system = 'XYH';         % Hệ tọa độ vuông góc
    cfg.distance_unit = 'meters';          % Đơn vị khoảng cách
    cfg.velocity_unit = 'm/s';             % Đơn vị vận tốc
    cfg.time_unit = 'seconds';             % Đơn vị thời gian
    cfg.altitude_unit = 'meters';          % Đơn vị độ cao
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % CẤU HÌNH GRADIENT MÀU SẮC ƯU TIÊN
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    cfg.color_critical = [1, 0, 0];        % Đỏ tươi (Priority ≥ 0.8)
    cfg.color_high = [1, 0.3, 0];          % Đỏ cam (0.6 ≤ Priority < 0.8)
    cfg.color_medium = [1, 0.6, 0];        % Cam (0.4 ≤ Priority < 0.6)
    cfg.color_low = [1, 1, 0];             % Vàng (0.2 ≤ Priority < 0.4)
    cfg.color_minimal = [0, 1, 0];         % Xanh lá (Priority < 0.2)
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % CẤU HÌNH NGƯỠNG ƯU TIÊN
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    cfg.priority_threshold_critical = 0.8;
    cfg.priority_threshold_high = 0.6;
    cfg.priority_threshold_medium = 0.4;
    cfg.priority_threshold_low = 0.2;
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % CẤU HÌNH ĐÁNH GIÁ MỨC ĐỘ QUAN TRỌNG
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    cfg.score_normalization_factor = 75;   % Hệ số chuẩn hóa điểm về 0-10
    cfg.max_priority_score = 10;           % Điểm tối đa
    cfg.command_priority_score = 10;       % Điểm khi có chỉ thị cấp trên
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % CẤU HÌNH ĐƯỜNG DẪN (PATH)
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    cfg.path_smoothness = 100;             % Số điểm trên đường cong
    cfg.path_curvature = 0.3;              % Độ cong đường đi
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % CẤU HÌNH HIỂN THỊ
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    cfg.display_trajectory = true;         % Hiển thị quỹ đạo
    cfg.display_labels = true;             % Hiển thị nhãn
    cfg.display_zones = true;              % Hiển thị vùng tiêu diệt
    cfg.display_grid = true;               % Hiển thị lưới tọa độ
    
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    % CẤU HÌNH DATABASE
    %% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    cfg.database_path = 'Data/TargetDatabase.mat';
    
end
