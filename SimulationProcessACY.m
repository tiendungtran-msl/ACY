%% ============================================================
%% HỆ THỐNG TỰ ĐỘNG HÓA CHỈ HUY PHÒNG KHÔNG
%% ============================================================
% Tác giả: Trần Tiến Dũng
% Ngày: 2025-11-04
% Mô tả: Hàm chính điều phối hệ thống mô phỏng
%% ============================================================


% Hàm main - Entry point của chương trình

% Khởi tạo môi trường
clear; clc; close all;

fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════╗\n');
fprintf('║            HỆ THỐNG CHỈ HUY PHÒNG KHÔNG              ║\n');
fprintf('╚══════════════════════════════════════════════════════╝\n');
fprintf('\n');

%% BƯỚC 1: Khởi tạo dữ liệu
fprintf('[1/6] Đang khởi tạo dữ liệu...\n');
[SCH, targets_protect, fire_units, targets] = initializeData();

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

fprintf('\n✓ Hệ thống đã sẵn sàng!\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
fprintf('▶ Nhấn "BẮT ĐẦU" để khởi động mô phỏng\n');
fprintf('☐ Tích checkbox để đánh dấu ưu tiên từ cấp trên\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n');
