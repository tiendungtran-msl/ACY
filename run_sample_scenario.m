%% ============================================================
%% WRAPPER: KHỞI ĐỘNG MÔ PHỎNG VỚI KỊCH BẢN MẪU
%% ============================================================
% Tác giả: Trần Tiến Dũng
% Ngày: 2025-11-12
% Mô tả: Script wrapper để chạy mô phỏng với kịch bản mẫu
%% ============================================================

% Khởi tạo môi trường
clear; clc; close all;

fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════╗\n');
fprintf('║       MÔ PHỎNG VỚI KỊCH BẢN MẪU (4 MỤC TIÊU)        ║\n');
fprintf('╚══════════════════════════════════════════════════════╝\n');
fprintf('\n');

%% BƯỚC 0: Tải cấu hình
fprintf('[0/6] Đang tải cấu hình...\n');
cfg = config();

%% BƯỚC 1: Tải kịch bản mẫu
fprintf('[1/6] Đang tải kịch bản mẫu...\n');
[SCH, targets_protect, fire_units, targets] = SampleScenario();

%% BƯỚC 2: Tạo đường cong chuyển động
fprintf('[2/6] Đang tạo đường cong chuyển động...\n');
targets = createSmoothPaths(targets);

%% BƯỚC 3: Thiết lập giao diện
fprintf('[3/6] Đang thiết lập giao diện...\n');
[fig, ax_main, ax_3d] = setupGUI();

%% BƯỚC 4: Vẽ các thành phần tĩnh
fprintf('[4/6] Đang vẽ môi trường...\n');
drawStaticElements(ax_main, ax_3d, SCH, targets_protect, fire_units);
drawPlannedPaths(ax_main, ax_3d, targets);

%% BƯỚC 5: Tạo bảng điều khiển
fprintf('[5/6] Đang tạo bảng điều khiển...\n');
[target_tables, control_buttons, target_checkboxes] = ...
    createControlPanel(fig, targets);

%% BƯỚC 6: Khởi tạo trạng thái mô phỏng
fprintf('[6/6] Đang khởi tạo trạng thái...\n');
sim_state = initializeSimulationState(fig, targets, SCH, ...
    targets_protect, fire_units, ax_main, ax_3d, ...
    target_tables, control_buttons, target_checkboxes);

% Cập nhật bảng thông tin ban đầu
updateAllTargetTables(sim_state);

fprintf('\n✓ Kịch bản mẫu đã sẵn sàng!\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('KỊCH BẢN:\n');
fprintf('  • 4 mục tiêu với mức độ ưu tiên khác nhau\n');
fprintf('  • 2 đơn vị hỏa lực (OE-1, OE-2)\n');
fprintf('  • 3 đối tượng bảo vệ quan trọng\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('▶ Nhấn "BẮT ĐẦU" để khởi động mô phỏng\n');
fprintf('☐ Tích checkbox để thay đổi ưu tiên\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n');
