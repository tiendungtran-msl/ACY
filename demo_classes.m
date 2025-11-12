%% ============================================================
%% DEMO - SỬ DỤNG CLASSES VÀ ALGORITHMS
%% ============================================================
% Tác giả: Trần Tiến Dũng
% Ngày: 2025-11-12
% Mô tả: Script demo sử dụng các Classes và Algorithms mới
%% ============================================================

clear; clc; close all;

fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════╗\n');
fprintf('║              DEMO - OOP CLASSES & ALGORITHMS         ║\n');
fprintf('╚══════════════════════════════════════════════════════╝\n');
fprintf('\n');

%% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% BƯỚC 1: TẢI CẤU HÌNH
%% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fprintf('[1/6] Tải cấu hình hệ thống...\n');
cfg = config();
fprintf('  ✓ Vùng phân phối: %.0f - %.0f m\n', ...
    cfg.distribution_range_min, cfg.distribution_range_max);

%% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% BƯỚC 2: TẠO SỞ CHỈ HUY
%% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fprintf('[2/6] Tạo Sở Chỉ Huy...\n');
SCH = struct('name', 'SCH', 'pos', [0, 0, 0]);
fprintf('  ✓ SCH tại: [%.0f, %.0f, %.0f]\n', SCH.pos);

%% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% BƯỚC 3: TẠO ĐỐI TƯỢNG BẢO VỆ (SỬ DỤNG CLASS)
%% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fprintf('[3/6] Tạo đối tượng bảo vệ...\n');
protected1 = ProtectedObject('Căn cứ quân sự', 'Military Base', [-8000, -8000, 0], 1.0, 5000);
protected2 = ProtectedObject('Sở chỉ huy', 'Command Center', [0, -10000, 0], 0.95, 5000);
protected3 = ProtectedObject('Nhà máy điện', 'Power Plant', [8000, -8000, 0], 0.8, 4000);
protected_objects = [protected1, protected2, protected3];
fprintf('  ✓ Đã tạo %d đối tượng bảo vệ\n', length(protected_objects));

%% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% BƯỚC 4: TẠO ĐƠN VỊ HỎA LỰC (SỬ DỤNG CLASS)
%% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fprintf('[4/6] Tạo đơn vị hỏa lực...\n');
fire1 = FireUnit('OE-1', 'S-125', [0, 10000, 0], 3500, 50000, 100, 18000, 2);
fire2 = FireUnit('OE-2', 'S-125', [-15000, 5000, 0], 3500, 60000, 100, 18000, 3);
fire_units = [fire1, fire2];
fprintf('  ✓ OE-1: Tầm %.0f km, %d kênh\n', fire1.range_max/1000, fire1.channels);
fprintf('  ✓ OE-2: Tầm %.0f km, %d kênh\n', fire2.range_max/1000, fire2.channels);

%% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% BƯỚC 5: TẠO MỤC TIÊU (SỬ DỤNG CLASS)
%% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fprintf('[5/6] Tạo mục tiêu...\n');

waypoints1 = [0, 70000; 0, 60000; 0, 50000; 0, 40000; 0, 30000; 0, 20000; 0, 10000];
target1 = Target(1, 'B52-01', 'MB ném bom chiến lược', 500, 18000, 15, 3, ...
    'Ném bom chiến lược', 'Chủ động', 4, waypoints1, [1, 0, 0], 's');
target1.priority_from_command = true;

waypoints2 = [-40000, 60000; -25000, 45000; -15000, 30000; -10000, 15000; -5000, 5000; 0, 0];
target2 = Target(2, 'F-16-01', 'Tiêm kích chiến thuật', 700, 10000, 3, 8.5, ...
    'Tấn công SCH', 'Không', 1, waypoints2, [1, 0.3, 0], '^');

waypoints3 = [40000, 50000; 30000, 40000; 20000, 30000; 10000, 20000; 5000, 10000; 0, 0];
target3 = Target(3, 'TLHT-01', 'Tên lửa hành trình', 1000, 5000, 0.5, 1.5, ...
    'Tiêu diệt hậu phương', 'Không', 1, waypoints3, [1, 0.5, 0], '>');

targets = [target1, target2, target3];
fprintf('  ✓ Đã tạo %d mục tiêu\n', length(targets));

%% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% BƯỚC 6: TẠO TÌNH HUỐNG VÀ ĐÁNH GIÁ (SỬ DỤNG CLASS)
%% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fprintf('[6/6] Tạo tình huống và đánh giá...\n');

% Tạo AirSituation
situation = AirSituation(SCH, targets, fire_units, protected_objects);

% Đánh giá tất cả mục tiêu (Thuật toán 11 khối)
situation.evaluateAllTargets();

% Lấy danh sách ưu tiên
prioritized = situation.getPrioritizedTargets();

fprintf('\n');
fprintf('═══════════════════════════════════════════════════════\n');
fprintf('  KẾT QUẢ ĐÁNH GIÁ MỨC ĐỘ QUAN TRỌNG (Bⱼ)\n');
fprintf('═══════════════════════════════════════════════════════\n');
for i = 1:length(prioritized)
    t = prioritized(i);
    priority_normalized = t.Bj / 10;
    color = ColorMapping(priority_normalized, cfg);
    
    fprintf('  %d. %s (%-20s)\n', i, t.name, t.type);
    fprintf('     Bⱼ = %.2f/10 | Priority = %.2f%%\n', t.Bj, priority_normalized*100);
    fprintf('     Màu: RGB(%.1f, %.1f, %.1f) | ', color(1), color(2), color(3));
    
    if priority_normalized >= 0.8
        fprintf('CỰC NGUY HIỂM\n');
    elseif priority_normalized >= 0.6
        fprintf('NGUY HIỂM CAO\n');
    elseif priority_normalized >= 0.4
        fprintf('NGUY HIỂM TRUNG BÌNH\n');
    elseif priority_normalized >= 0.2
        fprintf('NGUY HIỂM THẤP\n');
    else
        fprintf('ÍT NGUY HIỂM\n');
    end
    fprintf('\n');
end

%% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
% DEMO CÁC ALGORITHMS
%% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fprintf('═══════════════════════════════════════════════════════\n');
fprintf('  DEMO CÁC ALGORITHM MODULES\n');
fprintf('═══════════════════════════════════════════════════════\n\n');

% Lấy mục tiêu đầu tiên để demo
demo_target = targets(2).toStruct();
demo_target.vel = [200, 150, 0];  % Thêm vận tốc

fprintf('Mục tiêu demo: %s\n\n', demo_target.name);

% KHỐI 1: Đánh giá chuyển động
fprintf('• KHỐI 1: Đánh giá tham số chuyển động\n');
params = Block1_EvaluateMotion(demo_target, 1);
fprintf('  Vị trí: (%.0f, %.0f, %.0f) m\n', params.x, params.y, params.H);
fprintf('  Vận tốc: vₓ=%.1f, vᵧ=%.1f m/s\n', params.vx, params.vy);
fprintf('  Hướng bay Q: %.1f°\n\n', params.Q_deg);

% KHỐI 2: Kiểm tra vùng
fprintf('• KHỐI 2: Kiểm tra vùng phân phối\n');
in_zone = Block2_CheckZone(demo_target.pos, SCH.pos, ...
    cfg.distribution_range_min, cfg.distribution_range_max);
fprintf('  Trong vùng: %s\n\n', mat2str(in_zone));

% KHỐI 4: Nhận dạng
fprintf('• KHỐI 4: Nhận dạng loại mục tiêu\n');
type_info = Block4_RecognizeType(demo_target, []);
fprintf('  Loại: %s (độ tin cậy: %.0f%%)\n\n', type_info.category, type_info.confidence*100);

% KHỐI 4'-5': Tính pᵢⱼ, τᵢⱼ
fprintf('• KHỐI 4''-5'': Tính tham số không-thời gian\n');
protected_struct = protected_objects(1).toStruct();
fire_struct = fire_units(1).toStruct();
[pij, tauij] = CalculateCourseParams(demo_target, protected_struct, fire_struct);
fprintf('  pᵢⱼ = %.0f m\n', pij);
fprintf('  τᵢⱼ = %.1f s\n\n', tauij);

% Dự báo quỹ đạo
fprintf('• Dự báo quỹ đạo (30s)\n');
future_pos = PredictTrajectory(demo_target, 30, 'linear');
fprintf('  Vị trí dự báo: (%.0f, %.0f, %.0f) m\n\n', future_pos);

% Phát hiện cơ động
fprintf('• Phát hiện cơ động\n');
is_maneuvering = DetectManeuver(demo_target, 2.0);
fprintf('  Đang cơ động: %s\n\n', mat2str(is_maneuvering));

fprintf('═══════════════════════════════════════════════════════\n');
fprintf('✓ DEMO HOÀN THÀNH!\n');
fprintf('═══════════════════════════════════════════════════════\n\n');
